from __future__ import annotations

from typing import List, Optional

from celery.result import AsyncResult
from fastapi import APIRouter, HTTPException

from app.core.celery_app import celery_app
from app.models import Person
from app.schemas import (
    EnrichPeopleJobResponse,
    EnrichPeopleRequest,
    FilmAppearance,
    PersonRead,
    ScrapeJobStatusResponse,
)
from app.tasks.scraping import enrich_people_job

router = APIRouter()


@router.get("/", response_model=List[PersonRead], summary="List people with filmography")
async def list_people(limit: int = 50, occupation: Optional[str] = None) -> List[PersonRead]:
    query = (
        Person.all()
        .order_by("-id")
        .limit(limit)
        .prefetch_related("film_roles__films")
    )
    if occupation:
        query = query.filter(occupation__icontains=occupation)
    people = await query
    return [_serialize_person(person) for person in people]


@router.get("/{person_id}", response_model=PersonRead, summary="Fetch person details")
async def get_person(person_id: int) -> PersonRead:
    person = (
        await Person.filter(id=person_id)
        .prefetch_related("film_roles__films")
        .first()
    )
    if not person:
        raise HTTPException(status_code=404, detail="Person not found")
    return _serialize_person(person)


@router.post(
    "/enrich",
    response_model=EnrichPeopleJobResponse,
    summary="Enqueue slow person detail enrichment",
)
async def enqueue_people_enrichment(payload: EnrichPeopleRequest) -> EnrichPeopleJobResponse:
    task = enrich_people_job.delay(payload.limit, payload.only_missing_birth_date)
    return EnrichPeopleJobResponse(
        task_id=task.id,
        limit=payload.limit,
        only_missing_birth_date=payload.only_missing_birth_date,
    )


@router.get(
    "/enrich/{task_id}",
    response_model=ScrapeJobStatusResponse,
    summary="Get people enrichment task status",
)
async def get_people_enrichment_status(task_id: str) -> ScrapeJobStatusResponse:
    task_result = AsyncResult(task_id, app=celery_app)
    state = task_result.state
    ready = task_result.ready()
    successful = task_result.successful()
    result_payload = task_result.result if successful and isinstance(task_result.result, dict) else None
    error_payload = str(task_result.result) if ready and not successful and task_result.result is not None else None
    return ScrapeJobStatusResponse(
        task_id=task_id,
        state=state,
        ready=ready,
        successful=successful,
        result=result_payload,
        error=error_payload,
    )


def _serialize_person(person: Person) -> PersonRead:
    links_attr = getattr(person, "film_roles", None)
    link_objs = links_attr if isinstance(links_attr, list) else []
    films: List[FilmAppearance] = []
    for link in link_objs:
        film = getattr(link, "films", None)
        if not film:
            continue
        films.append(
            FilmAppearance(
                film_id=film.id,
                title=film.title,
                release_year=film.release_year,
                role=link.role,
            )
        )

    return PersonRead(
        id=person.id,
        name=person.name,
        occupation=person.occupation,
        url=person.url,
        birth_date=person.birth_date,
        film_count=len(films),
        films=films,
    )
