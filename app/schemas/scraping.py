from typing import List, Optional

from pydantic import BaseModel, Field


class ScrapeMoviesRequest(BaseModel):
    from_page: Optional[int] = Field(
        default=None,
        ge=1,
        description="1-based index of the sitemap to start from.",
    )
    max_pages: Optional[int] = Field(
        default=None,
        ge=1,
        le=250,
        description="Maximum number of sitemap files to process once from_page is applied.",
    )
    max_films: Optional[int] = Field(
        default=None,
        ge=1,
        le=10000,
        description="Upper bound for number of films to crawl; stops before max_pages if reached first.",
    )
    include_people: bool = Field(
        default=True,
        description="Also crawl linked person pages (actors and directors).",
    )
    include_movies: bool = Field(
        default=True,
        description="When false, movie URLs are ignored (primarily for future creator-only crawls).",
    )


class ScrapeJobResponse(BaseModel):
    task_id: str
    from_page: Optional[int] = None
    max_pages: Optional[int] = None
    max_films: Optional[int] = None
    include_people: bool
    include_movies: bool
    sitemaps: List[str] = Field(default_factory=list)
    queued: int = Field(
        default=0,
        description="Number of sitemap XML files queued for the worker.",
    )
