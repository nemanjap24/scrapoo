from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, Field


class MovieBase(BaseModel):
    csfd_id: str
    title: str
    year: Optional[int] = None
    rating: Optional[float] = None
    poster_url: Optional[str] = None
    description: Optional[str] = None
    genres: List[str] = Field(default_factory=list)
    directors: List[str] = Field(default_factory=list)
    actors: List[str] = Field(default_factory=list)
    csfd_url: Optional[str] = None


class MovieCreate(MovieBase):
    pass


class MovieRead(MovieBase):
    id: int
    scraped_at: Optional[datetime] = None
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True
