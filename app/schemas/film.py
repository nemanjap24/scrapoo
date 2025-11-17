from typing import Optional

from pydantic import BaseModel, Field


class FilmBase(BaseModel):
    title: str = Field(..., max_length=50)
    original_title: Optional[str] = Field(default=None, max_length=50)
    country_id: Optional[int] = None
    language: Optional[str] = Field(default=None, max_length=50)
    release_year: Optional[int] = None
    rating: Optional[float] = None
    num_votes: Optional[int] = None
    genre_id: Optional[int] = None
    url: Optional[str] = Field(default=None, max_length=100)


class FilmCreate(FilmBase):
    pass


class FilmRead(FilmBase):
    id: int

    class Config:
        from_attributes = True
