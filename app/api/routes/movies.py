from typing import List

from fastapi import APIRouter, HTTPException, status

from app.core.config import settings
from app.models import Film
from app.schemas import FilmCreate, FilmRead, ScrapeJobResponse, ScrapeMoviesRequest
from app.tasks.scraping import run_scraping_job

router = APIRouter()


@router.get("/", response_model=List[FilmRead], summary="List latest films")
async def list_films(limit: int = 50) -> List[FilmRead]:
    fields = [
        "id",
        "title",
        "original_title",
        "country_id",
        "language",
        "release_year",
        "rating",
        "num_votes",
        "genre_id",
        "url",
    ]
    records = (
        await Film.all()
        .order_by("-id")
        .limit(limit)
        .values(*fields)
    )
    return [FilmRead(**record) for record in records]


@router.post("/", response_model=FilmRead, summary="Create a film record")
async def create_film(payload: FilmCreate) -> FilmRead:
    if payload.url:
        existing = await Film.get_or_none(url=payload.url)
        if existing:
            raise HTTPException(status_code=409, detail="Film already exists")

    film = await Film.create(**payload.model_dump())
    record = await Film.filter(id=film.id).values(
        "id",
        "title",
        "original_title",
        "country_id",
        "language",
        "release_year",
        "rating",
        "num_votes",
        "genre_id",
        "url",
    )
    return FilmRead(**record[0])


@router.post(
    "/scrape",
    response_model=ScrapeJobResponse,
    summary="Enqueue a Scrapy crawl",
    status_code=status.HTTP_202_ACCEPTED,
)
async def enqueue_scrape(payload: ScrapeMoviesRequest) -> ScrapeJobResponse:
    seeds = payload.urls or [settings.MAGIC_URL]
    normalized = [str(url).strip() for url in seeds if str(url).strip()]
    if not normalized:
        raise HTTPException(status_code=400, detail="At least one seed URL is required")

    task = run_scraping_job.delay(
        normalized,
        payload.max_listing_pages,
        payload.include_people,
    )

    return ScrapeJobResponse(
        task_id=task.id,
        seeds=normalized,
        include_people=payload.include_people,
        max_listing_pages=payload.max_listing_pages,
        queued=len(normalized),
    )
