"""Celery tasks for orchestrating Scrapy crawls and persisting results."""

from __future__ import annotations

import asyncio
import logging
import re
import time
from datetime import date
from typing import Iterable, Sequence

from celery import group
from celery.result import allow_join_result
from tortoise import Tortoise, connections

from app.core.celery_app import celery_app
from app.core.config import settings
from app.models import Country, Film, Genre, Person, PersonInFilm
from app.services.csfd_scraper import CSFDSpider, crawl_movies, crawl_people
from app.services.sitemap_loader import SitemapResolutionError, expand_sitemaps, resolve_sitemaps

logger = logging.getLogger(__name__)


@celery_app.task(name="tasks.scraping.schedule_default_crawl")
def schedule_default_crawl() -> dict:
    """Periodic entrypoint that enqueues a default sitemap crawl."""

    try:
        sitemap_urls = resolve_sitemaps(
            from_page=settings.SCRAPE_SCHEDULE_FROM_PAGE,
            max_pages=settings.SCRAPE_SCHEDULE_MAX_PAGES,
        )
    except SitemapResolutionError as exc:
        logger.exception("Scheduled crawl failed while resolving sitemaps")
        return {
            "scheduled": False,
            "error": str(exc),
        }

    if not sitemap_urls:
        return {
            "scheduled": False,
            "error": "No sitemap URLs available for scheduled crawl",
        }

    task = run_scraping_job.delay(
        sitemap_urls,
        settings.SCRAPE_SCHEDULE_INCLUDE_PEOPLE,
        settings.SCRAPE_SCHEDULE_INCLUDE_MOVIES,
        settings.SCRAPE_SCHEDULE_MAX_FILMS,
    )
    return {
        "scheduled": True,
        "task_id": task.id,
        "sitemaps": sitemap_urls,
    }


@celery_app.task(name="tasks.scraping.scrape_movies")
def run_scraping_job(
    sitemap_urls: Sequence[str],
    include_people: bool = False,
    include_movies: bool = True,
    max_films: int | None = None,
    skip_existing: bool = False,
) -> dict:
    """Expand sitemap files into seeds and persist crawled movies."""

    started_at = time.monotonic()
    film_seeds = expand_sitemaps(
        sitemap_urls,
        include_movies=include_movies,
        max_films=max_films,
    )
    discovered_seed_count = len(film_seeds)
    if skip_existing and film_seeds:
        film_seeds = asyncio.run(_filter_existing_film_urls(film_seeds))
    chunk_size = max(1, settings.SCRAPE_CHUNK_SIZE)
    parallel_chunks = max(1, settings.SCRAPE_PARALLEL_CHUNKS)
    base_response = {
        "seeds": film_seeds,
        "sitemaps": list(sitemap_urls),
        "chunk_size": chunk_size,
        "parallel_chunks": parallel_chunks,
        "skip_existing": skip_existing,
        "seeds_discovered": discovered_seed_count,
        "seeds_skipped_existing": discovered_seed_count - len(film_seeds),
    }
    if not film_seeds:
        base_response.update(
            {
                "films_saved": 0,
                "people_collected": 0,
                "chunks_processed": 0,
                "chunk_details": [],
                "duration_seconds": _elapsed_seconds(started_at),
                "films_per_second": 0.0,
            }
        )
        return base_response

    saved_movies, saved_people, chunk_details = asyncio.run(
        _execute_scrape_pipeline(
            film_seeds,
            include_people=include_people,
            chunk_size=chunk_size,
            parallel_chunks=parallel_chunks,
        )
    )

    base_response.update(
        {
            "films_saved": saved_movies,
            "people_collected": saved_people,
            "chunks_processed": len(chunk_details),
            "chunk_details": chunk_details,
            "duration_seconds": _elapsed_seconds(started_at),
            "films_per_second": _rate(saved_movies, started_at),
        }
    )
    return base_response


@celery_app.task(name="tasks.scraping.enrich_people")
def enrich_people_job(
    limit: int = 100,
    only_missing_birth_date: bool = True,
) -> dict:
    """Enrich existing person stubs by crawling their detail pages."""

    normalized_limit = max(1, int(limit or 100))
    started_at = time.monotonic()
    saved_people, selected_people, chunk_details = asyncio.run(
        _execute_people_enrichment(
            limit=normalized_limit,
            only_missing_birth_date=only_missing_birth_date,
        )
    )
    return {
        "people_selected": selected_people,
        "people_enriched": saved_people,
        "chunk_size": max(1, settings.SCRAPE_CHUNK_SIZE),
        "chunks_processed": len(chunk_details),
        "chunk_details": chunk_details,
        "duration_seconds": _elapsed_seconds(started_at),
        "people_per_second": _rate(saved_people, started_at),
    }


@celery_app.task(name="tasks.scraping.scrape_movie_chunk")
def scrape_movie_chunk(
    chunk_index: int,
    seed_urls: Sequence[str],
    include_people: bool = False,
) -> dict:
    """Crawl one chunk of film URLs and return payloads for parent persistence."""

    started_at = time.monotonic()
    seeds = list(seed_urls)
    meta: dict = {
        "chunk": chunk_index,
        "seed_count": len(seeds),
        "films_saved": 0,
        "people_collected": 0,
        "status": "pending",
    }
    try:
        logger.info("Starting crawl chunk %s (%s seeds)", chunk_index, len(seeds))
        batch = crawl_movies(
            seeds,
            max_listing_pages=1,
            include_people=include_people,
            request_delay=settings.REQUEST_DELAY,
        )
    except Exception as exc:  # pragma: no cover - defensive logging edge
        meta["status"] = "failed"
        meta["error"] = str(exc)
        meta["duration_seconds"] = _elapsed_seconds(started_at)
        logger.exception("Chunk %s failed while crawling", chunk_index)
        return {
            "meta": meta,
            "movies": [],
            "people": [],
        }

    meta["status"] = "crawled"
    meta["films_crawled"] = len(batch.movies)
    meta["people_crawled"] = len(batch.people)
    meta["crawl_duration_seconds"] = _elapsed_seconds(started_at)
    meta["crawl_films_per_second"] = _rate(len(batch.movies), started_at)
    return {
        "meta": meta,
        "movies": batch.movies,
        "people": batch.people,
    }


async def _execute_scrape_pipeline(
    film_seeds: Sequence[str],
    *,
    include_people: bool,
    chunk_size: int,
    parallel_chunks: int,
) -> tuple[int, int, list[dict]]:
    await Tortoise.init(db_url=settings.DATABASE_URL, modules={"models": settings.TORTOISE_MODELS})
    await _ensure_film_column_capacity(getattr(Film._meta.fields_map.get("title"), "max_length", 150))
    await _ensure_url_column_capacity(255)
    total_films = 0
    total_people = 0
    chunk_details: list[dict] = []
    try:
        chunks = list(enumerate(_chunked(film_seeds, chunk_size), start=1))
        for wave in _chunked(chunks, parallel_chunks):
            wave_started_at = time.monotonic()
            logger.info("Dispatching %s scrape chunks in parallel", len(wave))
            chunk_group = group(
                scrape_movie_chunk.s(index, chunk, include_people)
                for index, chunk in wave
            )
            async_result = chunk_group.apply_async()
            with allow_join_result():
                crawl_results = async_result.get()

            for result in sorted(crawl_results, key=lambda item: item.get("meta", {}).get("chunk", 0)):
                meta = dict(result.get("meta") or {})
                chunk_started_at = time.monotonic()
                if meta.get("status") == "failed":
                    chunk_details.append(meta)
                    continue

                meta["status"] = "persisting"
                people_saved = await _persist_people(result.get("people") or [])
                films_saved = await _persist_films(result.get("movies") or [])
                meta["films_saved"] = films_saved
                meta["people_collected"] = people_saved
                meta["status"] = "completed"
                meta["persist_duration_seconds"] = _elapsed_seconds(chunk_started_at)
                meta["duration_seconds"] = round(
                    float(meta.get("crawl_duration_seconds") or 0.0) + meta["persist_duration_seconds"],
                    3,
                )
                meta["films_per_second"] = round(
                    films_saved / max(0.001, meta["duration_seconds"]),
                    3,
                )
                chunk_details.append(meta)
                total_films += films_saved
                total_people += people_saved

            logger.info("Completed scrape chunk wave in %.3fs", time.monotonic() - wave_started_at)
    finally:
        await Tortoise.close_connections()
    return total_films, total_people, chunk_details


async def _filter_existing_film_urls(film_seeds: Sequence[str]) -> list[str]:
    await Tortoise.init(db_url=settings.DATABASE_URL, modules={"models": settings.TORTOISE_MODELS})
    try:
        existing_urls = set(
            await Film.filter(url__in=list(film_seeds)).values_list("url", flat=True)
        )
        return [url for url in film_seeds if url not in existing_urls]
    finally:
        await Tortoise.close_connections()


async def _execute_people_enrichment(
    *,
    limit: int,
    only_missing_birth_date: bool,
) -> tuple[int, int, list[dict]]:
    await Tortoise.init(db_url=settings.DATABASE_URL, modules={"models": settings.TORTOISE_MODELS})
    await _ensure_url_column_capacity(255)
    total_people = 0
    chunk_details: list[dict] = []
    try:
        query = Person.all().order_by("id")
        if only_missing_birth_date:
            query = query.filter(birth_date__isnull=True)
        people = await query.limit(limit)
        seed_urls = [CSFDSpider.build_person_overview_url(person.url) for person in people if person.url]
        chunk_size = max(1, settings.SCRAPE_CHUNK_SIZE)

        for index, chunk in enumerate(_chunked(seed_urls, chunk_size), start=1):
            chunk_started_at = time.monotonic()
            meta: dict = {
                "chunk": index,
                "seed_count": len(chunk),
                "people_enriched": 0,
                "status": "pending",
            }
            try:
                logger.info("Starting people enrichment chunk %s (%s seeds)", index, len(chunk))
                batch = crawl_people(
                    chunk,
                    request_delay=settings.REQUEST_DELAY,
                )
            except Exception as exc:  # pragma: no cover - defensive logging edge
                meta["status"] = "failed"
                meta["error"] = str(exc)
                meta["duration_seconds"] = _elapsed_seconds(chunk_started_at)
                logger.exception("People enrichment chunk %s failed while crawling", index)
                chunk_details.append(meta)
                continue

            meta["status"] = "persisting"
            people_saved = await _persist_people(batch.people)
            meta["people_enriched"] = people_saved
            meta["status"] = "completed"
            meta["duration_seconds"] = _elapsed_seconds(chunk_started_at)
            meta["people_per_second"] = _rate(people_saved, chunk_started_at)
            chunk_details.append(meta)
            total_people += people_saved
    finally:
        await Tortoise.close_connections()
    return total_people, len(seed_urls), chunk_details


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
        occupation = (payload.get("occupation") or "").strip()
        person, created = await Person.get_or_create(
            url=url,
            defaults={
                "name": default_name,
                "occupation": occupation or "Actor",
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
        birth_date = _parse_birth_date(payload.get("birth_date"))
        if birth_date and person.birth_date != birth_date:
            person.birth_date = birth_date
            updates.append("birth_date")
        if updates:
            await person.save(update_fields=updates)
        if created or updates:
            saved += 1
    return saved


def _parse_birth_date(raw: object) -> date | None:
    if isinstance(raw, date):
        return raw
    if not isinstance(raw, str):
        return None
    text = raw.strip()
    if not text:
        return None

    iso_match = re.search(r"\b(\d{4})-(\d{1,2})-(\d{1,2})\b", text)
    if iso_match:
        year, month, day = (int(part) for part in iso_match.groups())
        try:
            return date(year, month, day)
        except ValueError:
            return None

    dotted_match = re.search(r"\b(\d{1,2})\.\s*(\d{1,2})\.\s*(\d{4})\b", text)
    if dotted_match:
        day, month, year = (int(part) for part in dotted_match.groups())
        try:
            return date(year, month, day)
        except ValueError:
            return None

    return None


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
        slug = slug.split("/", 1)[0]
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


def _elapsed_seconds(started_at: float) -> float:
    return round(max(0.0, time.monotonic() - started_at), 3)


def _rate(count: int, started_at: float) -> float:
    elapsed = max(0.001, time.monotonic() - started_at)
    return round(max(0, count) / elapsed, 3)


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


async def _ensure_url_column_capacity(target_length: int) -> None:
    conn = connections.get("default")
    table_columns = {
        "film": ("url",),
        "person": ("url",),
        "movie_link": ("url",),
    }
    try:
        rows = await conn.execute_query_dict(
            """
            SELECT table_name, column_name, character_maximum_length
            FROM information_schema.columns
            WHERE table_name IN ('film', 'person', 'movie_link')
              AND column_name = 'url'
            """
        )
    except Exception:  # pragma: no cover - informational safeguard
        return

    current_lengths = {
        (row["table_name"], row["column_name"]): row.get("character_maximum_length")
        for row in rows
    }
    statements: list[str] = []
    for table, columns in table_columns.items():
        for column in columns:
            current = current_lengths.get((table, column)) or 0
            if current < target_length:
                statements.append(f'ALTER TABLE "{table}" ALTER COLUMN "{column}" TYPE VARCHAR({target_length});')
    if statements:
        await conn.execute_script("\n".join(statements))
