"""TMDB API client and payload mapping helpers."""

from __future__ import annotations

import logging
import time
from collections import deque
from dataclasses import dataclass
from datetime import date
from typing import Any, Iterable

import httpx

from app.core.config import settings

logger = logging.getLogger(__name__)


class TMDBConfigurationError(RuntimeError):
    """Raised when TMDB credentials are not configured."""


class TMDBRequestError(RuntimeError):
    """Raised when TMDB returns an unrecoverable API response."""


@dataclass(slots=True)
class TMDBIngestionBatch:
    movies: list[dict]
    pages_requested: int
    movie_details_requested: int
    requests_made: int


class TMDBRateLimiter:
    """Sliding-window limiter scoped to TMDB HTTP requests."""

    def __init__(self, max_requests: int, window_seconds: float) -> None:
        self.max_requests = max(1, int(max_requests))
        self.window_seconds = max(0.1, float(window_seconds))
        self._request_times: deque[float] = deque()

    def wait(self) -> None:
        now = time.monotonic()
        while self._request_times and now - self._request_times[0] >= self.window_seconds:
            self._request_times.popleft()

        if len(self._request_times) >= self.max_requests:
            sleep_for = self.window_seconds - (now - self._request_times[0])
            if sleep_for > 0:
                time.sleep(sleep_for)
            now = time.monotonic()
            while self._request_times and now - self._request_times[0] >= self.window_seconds:
                self._request_times.popleft()

        self._request_times.append(time.monotonic())


class TMDBClient:
    def __init__(
        self,
        *,
        api_key: str | None = None,
        access_token: str | None = None,
        base_url: str | None = None,
        requests_per_window: int | None = None,
        rate_limit_window_seconds: float | None = None,
        timeout_seconds: float = 30.0,
    ) -> None:
        self.api_key = (api_key or settings.TMDB_API_KEY or "").strip() or None
        self.access_token = (access_token or settings.TMDB_ACCESS_TOKEN or "").strip() or None
        if not self.api_key and not self.access_token:
            raise TMDBConfigurationError("Set TMDB_API_KEY or TMDB_ACCESS_TOKEN before starting TMDB ingestion")

        self.base_url = (base_url or settings.TMDB_API_BASE_URL).rstrip("/")
        self.rate_limiter = TMDBRateLimiter(
            requests_per_window or settings.TMDB_REQUESTS_PER_WINDOW,
            rate_limit_window_seconds or settings.TMDB_RATE_LIMIT_WINDOW_SECONDS,
        )
        self.timeout_seconds = timeout_seconds
        self.requests_made = 0

    def fetch_top_movies_with_credits(
        self,
        *,
        limit: int = 3000,
        language: str = "en-US",
        include_adult: bool = False,
        actor_limit: int | None = None,
    ) -> TMDBIngestionBatch:
        target = max(1, int(limit))
        movies: list[dict] = []
        pages_requested = 0
        movie_details_requested = 0

        with httpx.Client(timeout=self.timeout_seconds) as client:
            page = 1
            while len(movies) < target:
                listing = self._get(
                    client,
                    "/discover/movie",
                    params={
                        "include_adult": str(include_adult).lower(),
                        "include_video": "false",
                        "language": language,
                        "page": page,
                        "sort_by": "popularity.desc",
                    },
                )
                pages_requested += 1
                results = listing.get("results") or []
                if not results:
                    break

                for movie in results:
                    if len(movies) >= target:
                        break
                    tmdb_id = movie.get("id")
                    if not tmdb_id:
                        continue
                    details = self._get(
                        client,
                        f"/movie/{tmdb_id}",
                        params={
                            "append_to_response": "credits",
                            "language": language,
                        },
                    )
                    movie_details_requested += 1
                    movies.append(_map_movie(details, actor_limit=actor_limit))

                total_pages = int(listing.get("total_pages") or page)
                if page >= total_pages:
                    break
                page += 1

        return TMDBIngestionBatch(
            movies=movies,
            pages_requested=pages_requested,
            movie_details_requested=movie_details_requested,
            requests_made=self.requests_made,
        )

    def _get(self, client: httpx.Client, path: str, *, params: dict[str, Any] | None = None) -> dict:
        request_params = dict(params or {})
        headers = {"accept": "application/json"}
        if self.access_token:
            headers["Authorization"] = f"Bearer {self.access_token}"
        elif self.api_key:
            request_params["api_key"] = self.api_key

        url = f"{self.base_url}{path}"
        for attempt in range(1, 4):
            self.rate_limiter.wait()
            self.requests_made += 1
            response = client.get(url, params=request_params, headers=headers)
            if response.status_code == 429:
                retry_after = _parse_retry_after(response.headers.get("Retry-After"))
                logger.warning("TMDB rate limited request to %s; sleeping %.2fs", path, retry_after)
                time.sleep(retry_after)
                continue
            if response.status_code >= 500 and attempt < 3:
                time.sleep(float(attempt))
                continue
            if response.status_code >= 400:
                raise TMDBRequestError(f"TMDB request failed for {path}: {response.status_code} {response.text[:300]}")
            return response.json()

        raise TMDBRequestError(f"TMDB request failed for {path}: exceeded retry attempts")


def _map_movie(payload: dict, *, actor_limit: int | None = None) -> dict:
    tmdb_id = payload.get("id")
    release_year = _release_year(payload.get("release_date"))
    credits = payload.get("credits") or {}
    cast = credits.get("cast") or []
    crew = credits.get("crew") or []

    if actor_limit is not None:
        cast = cast[: max(0, int(actor_limit))]

    return {
        "title": payload.get("title") or payload.get("original_title") or f"TMDB movie {tmdb_id}",
        "original_title": payload.get("original_title") or payload.get("title"),
        "language": payload.get("original_language") or "Unknown",
        "year": release_year,
        "rating": payload.get("vote_average"),
        "num_votes": payload.get("vote_count"),
        "url": f"https://www.themoviedb.org/movie/{tmdb_id}" if tmdb_id else None,
        "genres": [genre.get("name") for genre in payload.get("genres") or [] if genre.get("name")],
        "country": _first_country_name(payload.get("production_countries") or []),
        "actors": [_map_person(person, "actor") for person in cast if person.get("id")],
        "directors": [
            _map_person(person, "director")
            for person in crew
            if person.get("id") and (person.get("job") or "").lower() == "director"
        ],
    }


def _map_person(payload: dict, role: str) -> dict:
    person_id = payload.get("id")
    return {
        "name": payload.get("name") or payload.get("original_name") or f"TMDB person {person_id}",
        "occupation": role.capitalize(),
        "url": f"https://www.themoviedb.org/person/{person_id}",
    }


def _release_year(raw: object) -> int | None:
    if isinstance(raw, date):
        return raw.year
    if not isinstance(raw, str) or len(raw) < 4:
        return None
    try:
        return int(raw[:4])
    except ValueError:
        return None


def _first_country_name(countries: Iterable[dict]) -> str | None:
    for country in countries:
        name = (country.get("name") or "").strip()
        if name:
            return name
    return None


def _parse_retry_after(raw: str | None) -> float:
    if not raw:
        return 10.0
    try:
        return max(1.0, float(raw))
    except ValueError:
        return 10.0
