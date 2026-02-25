from typing import List, Optional

from pydantic import BaseModel, Field


class CountryRef(BaseModel):
    id: int
    name: Optional[str] = None

    class Config:
        from_attributes = True


class GenreRef(BaseModel):
    id: int
    name: Optional[str] = None

    class Config:
        from_attributes = True


class PersonSummary(BaseModel):
    id: int
    name: Optional[str] = None
    url: Optional[str] = None
    occupation: Optional[str] = None

    class Config:
        from_attributes = True


class FilmBase(BaseModel):
    title: str = Field(..., max_length=80)
    original_title: str = Field(..., max_length=80)
    country_id: Optional[int] = None
    language: str = Field(..., max_length=50)
    release_year: Optional[int] = None
    rating: Optional[float] = None
    num_votes: Optional[int] = None
    genre_id: Optional[int] = None
    url: str = Field(..., max_length=100)


class FilmCreate(FilmBase):
    pass


class FilmRead(FilmBase):
    id: int
    country: Optional[CountryRef] = None
    genre: Optional[GenreRef] = None
    genres: List[GenreRef] = Field(default_factory=list)
    directors: List[PersonSummary] = Field(default_factory=list)
    actors: List[PersonSummary] = Field(default_factory=list)

    class Config:
        from_attributes = True
