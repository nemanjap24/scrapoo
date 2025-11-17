"""Celery tasks for orchestrating Scrapy crawls and persisting results."""

from __future__ import annotations

import asyncio
from typing import Iterable, Sequence

from tortoise import Tortoise

from app.core.celery_app import celery_app
from app.core.config import settings
from app.models import Film
from app.services.csfd_scraper import crawl_movies


@celery_app.task(name="tasks.scraping.scrape_movies")
def run_scraping_job(
    urls: Sequence[str],
    max_listing_pages: int = 1,
    include_people: bool = False,
) -> dict:
    """Crawl the provided URLs and upsert the resulting movies."""

    seeds = _normalize_urls(urls)
    batch = crawl_movies(
        seeds,
        max_listing_pages=max_listing_pages,
        include_people=include_people,
        request_delay=settings.REQUEST_DELAY,
    )

    saved_movies = asyncio.run(_persist_movies(batch.movies))
    return {
        "seeds": seeds,
        "movies_saved": saved_movies,
        "people_collected": len(batch.people),
    }


def _normalize_urls(urls: Sequence[str]) -> list[str]:
    normalized: list[str] = []
    for url in urls:
        if not url:
            continue
        cleaned = url.strip()
        if cleaned:
            normalized.append(cleaned)
    return list(dict.fromkeys(normalized))


async def _persist_movies(movies: Iterable[dict]) -> int:
    if not movies:
        return 0

    await Tortoise.init(db_url=settings.DATABASE_URL, modules={"models": settings.TORTOISE_MODELS})

    saved = 0
    try:
        for payload in movies:
            data = _coerce_film_payload(payload)
            if not data:
                continue
            lookup_url = data.get("url")
            if lookup_url:
                await Film.update_or_create(url=lookup_url, defaults=data)
            else:
                await Film.create(**data)
            saved += 1
    finally:
        await Tortoise.close_connections()
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

    return {
        "title": title,
        "original_title": payload.get("title"),
        "release_year": year,
        "rating": rating,
        "url": payload.get("csfd_url"),
    }
