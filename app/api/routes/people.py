from __future__ import annotations

from typing import List, Optional

from fastapi import APIRouter, HTTPException

from app.models import Person
from app.schemas import FilmAppearance, PersonRead

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
