"""Celery tasks for orchestrating Scrapy crawls and persisting results."""

from __future__ import annotations

import asyncio
from typing import Iterable, Sequence

from tortoise import Tortoise

from app.core.celery_app import celery_app
from app.core.config import settings
from app.models import Country, Film, Genre, Person, PersonInFilm
from app.services.csfd_scraper import crawl_movies
from app.services.sitemap_loader import expand_sitemaps


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
    if not film_seeds:
        return {
            "seeds": [],
            "films_saved": 0,
            "people_collected": 0,
            "sitemaps": list(sitemap_urls),
        }

    batch = crawl_movies(
        film_seeds,
        max_listing_pages=1,
        include_people=include_people,
        request_delay=settings.REQUEST_DELAY,
    )

    saved_movies, saved_people = asyncio.run(_persist_batch(batch.movies, batch.people))
    return {
        "seeds": film_seeds,
        "films_saved": saved_movies,
        "people_collected": saved_people,
        "sitemaps": list(sitemap_urls),
    }


async def _persist_batch(movies: Iterable[dict], people: Iterable[dict]) -> tuple[int, int]:
    await Tortoise.init(db_url=settings.DATABASE_URL, modules={"models": settings.TORTOISE_MODELS})
    try:
        films_saved = await _persist_films(movies)
        people_saved = await _persist_people(people)
    finally:
        await Tortoise.close_connections()
    return films_saved, people_saved


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
        url = payload.get("csfd_url")
        csfd_id = (payload.get("csfd_id") or "").strip()
        if not url and csfd_id:
            base_url = str(settings.BASE_URL).rstrip("/")
            url = f"{base_url}/tvorca/{csfd_id.strip('/')}/"
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

    original_title = (payload.get("original_title") or title).strip()
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

    connection = Tortoise.get_connection("default")
    await connection.execute_query("DELETE FROM film_genre WHERE film=$1", [film.id])

    inserts: list[tuple[int, int]] = []
    for raw in names:
        cleaned = (raw or "").strip()
        if not cleaned:
            continue
        genre_obj, _ = await Genre.get_or_create(name=cleaned)
        inserts.append((film.id, genre_obj.id))

    if inserts:
        await connection.execute_many(
            "INSERT INTO film_genre (film, genre) VALUES ($1, $2)",
            inserts,
        )


async def _sync_people(film: Film, slugs: Iterable[str] | None, *, role: str) -> None:
    if slugs is None:
        return
    await PersonInFilm.filter(film=film, role=role).delete()
    for slug in slugs:
        person = await _get_or_create_person(slug, role)
        if not person:
            continue
        await PersonInFilm.get_or_create(
            film=film,
            person=person,
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
    await film.save(update_fields=["country"])


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
