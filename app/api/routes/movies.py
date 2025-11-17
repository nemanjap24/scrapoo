from typing import List

from fastapi import APIRouter, HTTPException, status

from app.core.config import settings
from app.models import Film
from app.schemas import FilmCreate, FilmRead, PersonSummary, ScrapeJobResponse, ScrapeMoviesRequest
from app.tasks.scraping import run_scraping_job

router = APIRouter()


@router.get("/", response_model=List[FilmRead], summary="List latest films")
async def list_films(limit: int = 50) -> List[FilmRead]:
    films = (
        await Film.all()
        .order_by("-id")
        .limit(limit)
        .prefetch_related("country", "genre", "genres", "person_links__person")
    )
    return [_serialize_film(film) for film in films]


@router.post("/", response_model=FilmRead, summary="Create a film record")
async def create_film(payload: FilmCreate) -> FilmRead:
    if payload.url:
        existing = await Film.get_or_none(url=payload.url)
        if existing:
            raise HTTPException(status_code=409, detail="Film already exists")

    film = await Film.create(**payload.model_dump())
    await film.fetch_related("country", "genre", "genres", "person_links__person")
    return _serialize_film(film)


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


def _serialize_film(film: Film) -> FilmRead:
    links_attr = getattr(film, "person_links", None)
    person_links = links_attr if isinstance(links_attr, list) else []
    directors: List[PersonSummary] = []
    actors: List[PersonSummary] = []
    for link in person_links:
        person = getattr(link, "person", None)
        if not person:
            continue
        summary = PersonSummary.model_validate(person)
        role = (link.role or "").lower()
        if "director" in role:
            directors.append(summary)
        elif "actor" in role:
            actors.append(summary)

    genres_attr = getattr(film, "genres", None)
    genre_objs = genres_attr if isinstance(genres_attr, list) else []
    return FilmRead(
        id=film.id,
        title=film.title,
        original_title=film.original_title,
        country_id=film.country_id,
        language=film.language,
        release_year=film.release_year,
        rating=film.rating,
        num_votes=film.num_votes,
        genre_id=film.genre_id,
        url=film.url,
        country=getattr(film, "country", None),
        genre=getattr(film, "genre", None),
        genres=genre_objs,
        directors=directors,
        actors=actors,
    )
