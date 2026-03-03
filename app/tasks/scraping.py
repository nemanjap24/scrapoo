"""Celery tasks for orchestrating Scrapy crawls and persisting results."""

from __future__ import annotations

import asyncio
import logging
from typing import Iterable, Sequence

from tortoise import Tortoise, connections

from app.core.celery_app import celery_app
from app.core.config import settings
from app.models import Country, Film, Genre, Person, PersonInFilm
from app.services.csfd_scraper import crawl_movies
from app.services.sitemap_loader import expand_sitemaps

logger = logging.getLogger(__name__)


@celery_app.task(name="tasks.scraping.scrape_movies")
def run_scraping_job(
    sitemap_urls: Sequence[str],
    include_people: bool = True,
    include_movies: bool = True,
    max_films: int | None = None,
) -> dict:
    """Expand sitemap files into seeds and persist crawled movies."""

    film_seeds = expand_sitemaps(
        sitemap_urls,
        include_movies=include_movies,
        max_films=max_films,
    )
    chunk_size = max(1, settings.SCRAPE_CHUNK_SIZE)
    base_response = {
        "seeds": film_seeds,
        "sitemaps": list(sitemap_urls),
        "chunk_size": chunk_size,
    }
    if not film_seeds:
        base_response.update(
            {
                "films_saved": 0,
                "people_collected": 0,
                "chunks_processed": 0,
                "chunk_details": [],
            }
        )
        return base_response

    saved_movies, saved_people, chunk_details = asyncio.run(
        _execute_scrape_pipeline(
            film_seeds,
            include_people=include_people,
            chunk_size=chunk_size,
        )
    )

    base_response.update(
        {
            "films_saved": saved_movies,
            "people_collected": saved_people,
            "chunks_processed": len(chunk_details),
            "chunk_details": chunk_details,
        }
    )
    return base_response


async def _execute_scrape_pipeline(
    film_seeds: Sequence[str],
    *,
    include_people: bool,
    chunk_size: int,
) -> tuple[int, int, list[dict]]:
    await Tortoise.init(db_url=settings.DATABASE_URL, modules={"models": settings.TORTOISE_MODELS})
    await _ensure_film_column_capacity(getattr(Film._meta.fields_map.get("title"), "max_length", 150))
    total_films = 0
    total_people = 0
    chunk_details: list[dict] = []
    try:
        for index, chunk in enumerate(_chunked(film_seeds, chunk_size), start=1):
            meta: dict = {
                "chunk": index,
                "seed_count": len(chunk),
                "films_saved": 0,
                "people_collected": 0,
                "status": "pending",
            }
            try:
                logger.info("Starting chunk %s (%s seeds)", index, len(chunk))
                batch = crawl_movies(
                    chunk,
                    max_listing_pages=1,
                    include_people=include_people,
                    request_delay=settings.REQUEST_DELAY,
                )
            except Exception as exc:  # pragma: no cover - defensive logging edge
                meta["status"] = "failed"
                meta["error"] = str(exc)
                logger.exception("Chunk %s failed while crawling", index)
                chunk_details.append(meta)
                continue

            meta["status"] = "persisting"
            films_saved = await _persist_films(batch.movies)
            people_saved = await _persist_people(batch.people)
            meta["films_saved"] = films_saved
            meta["people_collected"] = people_saved
            meta["status"] = "completed"
            chunk_details.append(meta)
            total_films += films_saved
            total_people += people_saved
    finally:
        await Tortoise.close_connections()
    return total_films, total_people, chunk_details


async def _persist_films(movies: Iterable[dict]) -> int:
    if not movies:
        return 0

    saved = 0
    for payload in movies:
        data = _coerce_film_payload(payload)
        if not data:
            continue
        lookup_url = data.get("url")
        film: Film | None = None
        if lookup_url:
            film, _ = await Film.update_or_create(url=lookup_url, defaults=data)
        else:
            film = await Film.create(**data)
        if not film:
            continue
        await _sync_genres(film, payload.get("genres"))
        await _sync_people(film, payload.get("directors"), role="director")
        await _sync_people(film, payload.get("actors"), role="actor")
        await _sync_country(film, payload.get("country"))
        saved += 1
    return saved


async def _persist_people(people: Iterable[dict]) -> int:
    if not people:
        return 0

    saved = 0
    for payload in people:
        csfd_id = (payload.get("csfd_id") or "").strip()
        url = _canonical_person_url(payload.get("csfd_url"), csfd_id)
        if not url:
            continue
        default_name = (payload.get("name") or "").strip() or _humanize_slug(csfd_id)
        occupation = (payload.get("occupation") or "Actor").strip() or "Actor"
        person, _ = await Person.get_or_create(
            url=url,
            defaults={
                "name": default_name,
                "occupation": occupation,
            },
        )

        updates: list[str] = []
        name = (payload.get("name") or "").strip()
        if name and name != person.name:
            person.name = name
            updates.append("name")
        if occupation and person.occupation != occupation:
            person.occupation = occupation
            updates.append("occupation")
        if updates:
            await person.save(update_fields=updates)
        saved += 1
    return saved


def _coerce_film_payload(payload: dict) -> dict | None:
    title = (payload.get("title") or "").strip()
    if not title:
        return None
    max_title_length = getattr(Film._meta.fields_map.get("title"), "max_length", 150)

    year = payload.get("year")
    if isinstance(year, str):
        digits = "".join(ch for ch in year if ch.isdigit())
        year = int(digits[:4]) if digits else None

    rating = payload.get("rating")
    if isinstance(rating, str):
        try:
            rating = float(rating)
        except ValueError:
            rating = None

    title = title[:max_title_length]
    original_title = (payload.get("original_title") or title).strip()
    if original_title:
        original_title = original_title[:max_title_length]
    language = (payload.get("language") or "Unknown").strip() or "Unknown"
    url = payload.get("csfd_url") or payload.get("url")
    if not url and payload.get("csfd_id"):
        base_url = str(settings.BASE_URL).rstrip("/")
        url = f"{base_url}/film/{payload['csfd_id'].strip('/')}/"
    if not url:
        return None

    return {
        "title": title,
        "original_title": original_title,
        "release_year": year,
        "rating": rating,
        "language": language,
        "url": url,
    }


async def _sync_genres(film: Film, names: Iterable[str] | None) -> None:
    if names is None:
        return
    await film.genres.clear()

    genre_objs: list[Genre] = []
    for raw in names:
        cleaned = (raw or "").strip()
        if not cleaned:
            continue
        genre_obj, _ = await Genre.get_or_create(name=cleaned)
        genre_objs.append(genre_obj)

    if genre_objs:
        await film.genres.add(*genre_objs)


async def _sync_people(film: Film, slugs: Iterable[str] | None, *, role: str) -> None:
    if slugs is None:
        return
    await PersonInFilm.filter(films=film, role=role).delete()
    for slug in slugs:
        person = await _get_or_create_person(slug, role)
        if not person:
            continue
        await PersonInFilm.get_or_create(
            films=film,
            persons=person,
            defaults={"role": role},
        )


async def _sync_country(film: Film, country_name: str | None) -> None:
    if not country_name:
        return
    cleaned = country_name.strip()
    if not cleaned:
        return
    country_obj, _ = await Country.get_or_create(name=cleaned)
    if film.country_id == country_obj.id:
        return
    film.country = country_obj
    await film.save(update_fields=["country_id"])


async def _get_or_create_person(slug: str | None, role: str) -> Person | None:
    if not slug:
        return None
    slug_str = str(slug)
    cleaned = slug_str.strip().strip("/")
    if not cleaned or cleaned == "#":
        return None
    if cleaned.startswith("http"):
        url = cleaned
        slug_part = cleaned.rstrip("/").split("/")[-1]
    else:
        slug_part = cleaned
        if not slug_part or slug_part == "#":
            return None
        base_url = str(settings.BASE_URL).rstrip("/")
        url = f"{base_url}/tvorca/{slug_part}/"

    name = _humanize_slug(slug_part)
    defaults = {
        "name": name,
        "occupation": role.capitalize(),
        "url": url,
    }
    person, _ = await Person.get_or_create(url=url, defaults=defaults)
    # ensure required fields are populated if person already existed without them
    updated = False
    if not person.name and name:
        person.name = name
        updated = True
    if not person.occupation:
        person.occupation = role.capitalize()
        updated = True
    if updated:
        await person.save(update_fields=["name", "occupation"])
    return person


def _humanize_slug(slug: str) -> str:
    if not slug:
        return "Unknown"
    parts = slug.split("-", 1)
    candidate = parts[1] if len(parts) > 1 else parts[0]
    words = [w.capitalize() for w in candidate.replace("-", " ").split() if w]
    return " ".join(words) if words else candidate.capitalize()


def _canonical_person_url(raw_url: str | None, csfd_id: str | None) -> str | None:
    base_url = str(settings.BASE_URL).rstrip("/")
    if csfd_id:
        slug = csfd_id.strip().strip("/")
        if slug:
            return f"{base_url}/tvorca/{slug}/"
    if not raw_url:
        return None
    url = raw_url.strip()
    if not url:
        return None
    for token in ("#", "?"):
        if token in url:
            url = url.split(token, 1)[0]
    if url.startswith("//"):
        url = f"https:{url}"
    if url.startswith("/"):
        url = f"{base_url}{url}"
    url = url.rstrip("/")
    if url.endswith("/prehlad"):
        url = url[: -len("/prehlad")]
    if not url.lower().startswith("http"):
        return None
    return f"{url.strip()}/"


def _chunked(sequence: Sequence[str], size: int) -> Iterable[list[str]]:
    if size <= 0:
        return []
    total = len(sequence)
    for start in range(0, total, size):
        yield list(sequence[start : start + size])


async def _ensure_film_column_capacity(target_length: int) -> None:
    conn = connections.get("default")
    try:
        rows = await conn.execute_query_dict(
            """
            SELECT column_name, character_maximum_length
            FROM information_schema.columns
            WHERE table_name = 'film'
              AND column_name IN ('title', 'original_title')
            """
        )
    except Exception:  # pragma: no cover - informational safeguard
        return
    current_lengths = {row["column_name"]: row.get("character_maximum_length") for row in rows}
    statements: list[str] = []
    for column in ("title", "original_title"):
        current = current_lengths.get(column) or 0
        if current < target_length:
            statements.append(f'ALTER TABLE "film" ALTER COLUMN "{column}" TYPE VARCHAR({target_length});')
    if statements:
        await conn.execute_script("\n".join(statements))
