"""Scrapy-powered helpers for crawling CSFD movie pages.

This module wraps a purpose-built Spider so Celery tasks (or other callers)
can programmatically crawl listing or film detail pages and receive
plain-Python payloads.
"""
from __future__ import annotations

import argparse
import base64
import json
import subprocess
import sys
from dataclasses import dataclass, field
from typing import Callable, Dict, Iterable, List, Optional

import scrapy
from scrapy.crawler import CrawlerProcess

from app.core.config import settings


@dataclass
class ScrapeBatch:
    movies: List[Dict]
    people: List[Dict]


@dataclass
class _Collector:
    movies: List[Dict] = field(default_factory=list)
    people: List[Dict] = field(default_factory=list)

    def __call__(self, item: Dict) -> None:
        payload = dict(item)
        item_type = payload.pop("item_type", "movie")
        if item_type == "person":
            self.people.append(payload)
        else:
            self.movies.append(payload)

    def build(self) -> ScrapeBatch:
        return ScrapeBatch(movies=self.movies[:], people=self.people[:])


class CSFDSpider(scrapy.Spider):  # pragma: no cover - exercised via Celery integration tests
    name = "scrapoo-csfd"

    def __init__(
        self,
        start_urls: Iterable[str],
        item_callback: Optional[Callable[[Dict], None]] = None,
        max_listing_pages: int = 1,
        include_people: bool = False,
        *args,
        **kwargs,
    ) -> None:
        super().__init__(*args, **kwargs)
        self.start_urls = list(start_urls)
        self.item_callback = item_callback
        self.max_listing_pages = max(0, max_listing_pages)
        self.include_people = include_people
        self._listing_pages_seen = 0
        self._seen_movies: set[str] = set()
        self._emitted_people: set[str] = set()

    def parse(self, response: scrapy.http.Response):  # type: ignore[override]
        url = response.url
        if "/film/" in url:
            yield from self.parse_film(response)
            return
        if any(token in url for token in ("rebricky", "zebricky", "top", "vlastny-vyber")):
            yield from self.parse_listing(response)
            return
        # Fallback: detect listing markup
        if response.css("a.film-title-name"):
            yield from self.parse_listing(response)
        else:
            yield from self.parse_film(response)

    def parse_listing(self, response: scrapy.http.Response):
        film_links = response.css("a.film-title-name::attr(href)").getall()
        for href in film_links:
            url = response.urljoin(href)
            yield response.follow(url, callback=self.parse_film)

        if self._listing_pages_seen >= self.max_listing_pages:
            return

        self._listing_pages_seen += 1
        next_href = response.css("a.page-next::attr(href)").get()
        if next_href:
            yield response.follow(next_href, callback=self.parse_listing)

    def parse_film(self, response: scrapy.http.Response):
        csfd_id = self._extract_csfd_id(response.url)
        if not csfd_id or csfd_id in self._seen_movies:
            return
        self._seen_movies.add(csfd_id)

        title = (response.css("h1::text").get() or "").strip()
        country_name = self._extract_country_from_origin(response) or self._extract_country_from_names(response)
        original_title = self._extract_original_title(response, country_name)
        year_text = response.css("div.origin span::text").get()
        year = year_text.strip().strip(", ") if year_text else None
        description = (response.css("div.plot-full::text").get() or "").strip()
        genres = [g.strip() for g in response.css("div.genres a::text, div.genres span.genre::text").getall() if g.strip()]
        rating = None
        rating_text = response.css("div.rating-average::text").get()
        if rating_text:
            cleaned = rating_text.strip().replace("%", "")
            try:
                rating = float(cleaned) / 100.0
            except Exception:  # pragma: no cover - depends on upstream format
                rating = None

        poster_url = response.css("div.film-posters img::attr(src)").get()
        creators = response.css("div.creators")
        director_entries = self._extract_people(
            response,
            creators,
            labels=("Réžia", "Režie", "Réžia:", "Režie:"),
            role="director",
        )
        actor_entries = self._extract_people(
            response,
            creators,
            labels=("Hrajú", "Hrají", "Hrajú:", "Hrají:"),
            role="actor",
        )
        directors = [person["slug"] for person in director_entries]
        actors = [person["slug"] for person in actor_entries]

        movie = {
            "item_type": "movie",
            "csfd_id": csfd_id,
            "csfd_url": response.url,
            "title": title,
            "original_title": original_title or title,
            "year": year,
            "description": description,
            "genres": genres,
            "rating": rating,
            "poster_url": poster_url,
            "directors": directors,
            "actors": actors,
            "country": country_name,
        }
        for person in director_entries + actor_entries:
            self._emit_person_stub(person)
        self._emit(movie)
        yield movie

        if self.include_people:
            for slug in directors:
                yield response.follow(
                    url=response.urljoin(f"/tvorca/{slug}/"),
                    callback=self.parse_person,
                    cb_kwargs={"fallback_slug": slug, "role": "director"},
                )
            for slug in actors:
                yield response.follow(
                    url=response.urljoin(f"/tvorca/{slug}/"),
                    callback=self.parse_person,
                    cb_kwargs={"fallback_slug": slug, "role": "actor"},
                )

    def parse_person(
        self,
        response: scrapy.http.Response,
        fallback_slug: str | None = None,
        role: str | None = None,
    ):
        csfd_id = fallback_slug or self._extract_person_id(response.url)
        name = (response.css("h1::text").get() or "").strip()
        birth_date = (response.css("div.birth-date::text").get() or "").strip()
        bio = (response.css("div.biography::text").get() or "").strip()

        person = {
            "item_type": "person",
            "csfd_id": csfd_id,
            "name": name,
            "birth_date": birth_date or None,
            "bio": bio or None,
            "csfd_url": response.url,
            "occupation": role.title() if role else None,
        }
        self._emit(person)
        yield person

    def _emit(self, payload: Dict) -> None:
        if not self.item_callback:
            return
        try:
            self.item_callback(dict(payload))
        except Exception:  # pragma: no cover - defensive
            self.logger.exception("item_callback failed")

    @staticmethod
    def _extract_csfd_id(url: str) -> Optional[str]:
        if "/film/" not in url:
            return None
        slug = url.split("/film/", 1)[-1]
        slug = slug.split("/", 1)[0]
        return slug.split("-", 1)[0]

    @staticmethod
    def _extract_person_id(url: str) -> Optional[str]:
        for token in ("/tvorca/", "/tvurce/"):
            if token in url:
                slug = url.split(token, 1)[-1]
                return slug.strip("/")
        return None

    def _extract_original_title(
        self,
        response: scrapy.http.Response,
        country_name: Optional[str],
    ) -> Optional[str]:
        entries = response.css("ul.film-names li")
        if not entries:
            return None
        target = None
        if country_name:
            target = self._find_entry_by_country(entries, country_name)
        if not target:
            target = entries[0]
        return self._clean_original_title(target)

    @staticmethod
    def _find_entry_by_country(entries, country_name: str):
        normalized = country_name.strip()
        if "/" in normalized:
            normalized = normalized.split("/", 1)[0]
        normalized = normalized.lower()
        for entry in entries:
            flag_title = entry.css("img.flag::attr(title)").get() or entry.css("img.flag::attr(alt)").get()
            if not flag_title:
                continue
            flag_value = flag_title.strip().lower()
            if flag_value == normalized:
                return entry
        return None

    @staticmethod
    def _extract_country_from_names(response: scrapy.http.Response) -> Optional[str]:
        primary_flag = response.css("ul.film-names li img.flag::attr(title)").get()
        if not primary_flag:
            primary_flag = response.css("ul.film-names li img.flag::attr(alt)").get()
        return primary_flag.strip() if primary_flag else None

    @staticmethod
    def _clean_original_title(entry) -> Optional[str]:
        raw_parts = entry.xpath("text()[normalize-space()]").getall() or []
        if not raw_parts:
            raw_parts = entry.xpath(".//text()[normalize-space()]").getall()
        cleaned: List[str] = []
        for part in raw_parts:
            chunk = part.strip()
            if not chunk:
                continue
            lowered = chunk.lower()
            if "viac" in lowered or "menej" in lowered:
                continue
            cleaned.append(chunk)
        if not cleaned:
            return None
        text = " ".join(cleaned)
        if "(" in text:
            text = text.split("(", 1)[0].strip()
        return text or None

    @staticmethod
    def _extract_country_from_origin(response: scrapy.http.Response) -> Optional[str]:
        origin_parts = [part.strip() for part in response.css("div.origin ::text").getall() if part.strip()]
        if not origin_parts:
            return None
        candidate = origin_parts[0]
        if "/" in candidate:
            candidate = candidate.split("/", 1)[0].strip()
        if "," in candidate:
            candidate = candidate.split(",", 1)[0].strip()
        return candidate or None

    def _extract_people(
        self,
        response: scrapy.http.Response,
        creators,
        labels: Iterable[str],
        *,
        role: str,
        limit: Optional[int] = None,
    ) -> List[Dict[str, Optional[str]]]:
        if not creators:
            return []
        label_xpath = " or ".join([f"contains(., '{label}')" for label in labels])
        sections = creators.xpath(f".//div[h4[{label_xpath}]]")
        if not sections:
            return []
        links = sections.xpath(".//a")
        people: List[Dict[str, str]] = []
        seen: set[str] = set()
        for link in links:
            href = link.xpath("@href").get()
            if not href:
                continue
            slug = self._extract_person_slug_from_href(href)
            if not slug or slug in seen:
                continue
            seen.add(slug)
            name = " ".join([text.strip() for text in link.xpath(".//text()").getall() if text.strip()])
            url = response.urljoin(href)
            people.append(
                {
                    "slug": slug,
                    "name": name or None,
                    "url": url,
                    "role": role,
                }
            )
            if limit and len(people) >= limit:
                break
        return people

    def _emit_person_stub(self, person: Dict[str, Optional[str]]) -> None:
        slug = (person.get("slug") or "").strip()
        if not slug or slug in self._emitted_people:
            return
        name = (person.get("name") or "").strip()
        url = person.get("url") or self._build_person_url(slug)
        role = (person.get("role") or "actor").title()
        payload = {
            "item_type": "person",
            "csfd_id": slug,
            "name": name or None,
            "csfd_url": url,
            "occupation": role,
        }
        self._emitted_people.add(slug)
        self._emit(payload)

    @staticmethod
    def _build_person_url(slug: str) -> str:
        base_url = str(settings.BASE_URL).rstrip("/")
        return f"{base_url}/tvorca/{slug}/"

    @staticmethod
    def _extract_person_slug_from_href(href: str) -> Optional[str]:
        """Return the slug portion from typical \n+        /tvorca/<slug>/prehlad/ style URLs."""

        if not href:
            return None
        normalized = href.strip()
        if not normalized:
            return None
        # Remove query/fragment noise without importing urlsplit at top-level repeatedly
        for token in ("#", "?"):
            if token in normalized:
                normalized = normalized.split(token, 1)[0]
        normalized = normalized.strip()
        parts = [segment for segment in normalized.strip("/").split("/") if segment]
        if not parts:
            return None
        try:
            if "tvorca" in parts:
                idx = parts.index("tvorca")
            elif "tvurce" in parts:
                idx = parts.index("tvurce")
            else:
                return None
        except ValueError:
            return None
        slug_index = idx + 1
        if slug_index >= len(parts):
            return None
        candidate = parts[slug_index].strip()
        if not candidate or candidate == "prehlad":
            return None
        return candidate


def crawl_movies(
    start_urls: Iterable[str],
    *,
    max_listing_pages: int = 1,
    include_people: bool = True,
    request_delay: Optional[float] = None,
) -> ScrapeBatch:
    """Run the CSFD spider and return collected payloads.

    We shell out to a helper invocation (`python -m app.services.csfd_scraper`) so
    each crawl gets its own fresh Twisted reactor, sidestepping
    ReactorNotRestartable without having to spawn multiprocessing children from
    Celery's daemonized pool workers."""

    start_urls_list = list(start_urls)
    download_delay = settings.REQUEST_DELAY if request_delay is None else request_delay
    payload = {
        "start_urls": start_urls_list,
        "max_listing_pages": max(0, max_listing_pages),
        "include_people": include_people,
        "download_delay": download_delay,
    }
    encoded = base64.b64encode(json.dumps(payload).encode("utf-8")).decode("ascii")
    cmd = [sys.executable, "-m", "app.services.csfd_scraper", "--crawl-payload", encoded]
    completed = subprocess.run(cmd, capture_output=True, text=True)
    if completed.returncode != 0:
        raise RuntimeError(
            "Scrapy crawl failed in helper process:\n"
            f"STDOUT:\n{completed.stdout}\nSTDERR:\n{completed.stderr}"
        )
    try:
        parsed = json.loads(completed.stdout or "{}")
    except json.JSONDecodeError as exc:  # pragma: no cover - defensive
        raise RuntimeError(f"Failed to parse scraper output: {exc}\nRaw: {completed.stdout}") from exc
    return ScrapeBatch(movies=parsed.get("movies", []), people=parsed.get("people", []))


def _build_spider_settings(download_delay: float) -> Dict:
    return {
        "LOG_ENABLED": False,
        "CONCURRENT_REQUESTS": settings.SCRAPY_CONCURRENT_REQUESTS,
        "CONCURRENT_REQUESTS_PER_DOMAIN": settings.SCRAPY_CONCURRENT_REQUESTS,
        "DOWNLOAD_DELAY": max(0.0, download_delay),
        "USER_AGENT": "ScrapooCrawler/1.0 (+https://github.com/nemanjap24/scrapoo)",
        "ROBOTSTXT_OBEY": False,
        "AUTOTHROTTLE_ENABLED": False,
    }


def _execute_crawl(payload: Dict) -> ScrapeBatch:
    collector = _Collector()
    spider_settings = _build_spider_settings(payload["download_delay"])
    process = CrawlerProcess(settings=spider_settings)
    process.crawl(
        CSFDSpider,
        start_urls=payload["start_urls"],
        item_callback=collector,
        max_listing_pages=payload["max_listing_pages"],
        include_people=payload["include_people"],
    )
    process.start()
    return collector.build()


def _cli_entry() -> int:
    parser = argparse.ArgumentParser(description="Internal helper to run Scrapy crawls in isolation.")
    parser.add_argument("--crawl-payload", help="Base64-encoded JSON crawl configuration.")
    args = parser.parse_args()
    if not args.crawl_payload:
        parser.print_help()
        return 1
    payload_json = base64.b64decode(args.crawl_payload.encode("ascii"))
    payload = json.loads(payload_json)
    batch = _execute_crawl(payload)
    sys.stdout.write(json.dumps({"movies": batch.movies, "people": batch.people}))
    return 0


if __name__ == "__main__":  # pragma: no cover - CLI entry
    raise SystemExit(_cli_entry())
