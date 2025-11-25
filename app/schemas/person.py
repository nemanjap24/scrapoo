from __future__ import annotations

from datetime import date
from typing import List, Optional

from pydantic import BaseModel, Field


class FilmAppearance(BaseModel):
    film_id: int
    title: Optional[str] = None
    role: Optional[str] = None
    release_year: Optional[int] = None

    class Config:
        from_attributes = True


class PersonRead(BaseModel):
    id: int
    name: Optional[str] = None
    occupation: Optional[str] = None
    url: Optional[str] = None
    birth_date: Optional[date] = None
    film_count: int = 0
    films: List[FilmAppearance] = Field(default_factory=list)

    class Config:
        from_attributes = True
