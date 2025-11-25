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
    include_people: bool = Field(
        default=False,
        description="Also crawl linked person pages when available.",
    )
    include_movies: bool = Field(
        default=True,
        description="When false, movie URLs are ignored (primarily for future creator-only crawls).",
    )


class ScrapeJobResponse(BaseModel):
    task_id: str
    from_page: Optional[int] = None
    max_pages: Optional[int] = None
    include_people: bool
    include_movies: bool
    sitemaps: List[str] = Field(default_factory=list)
    queued: int = Field(
        default=0,
        description="Number of sitemap XML files queued for the worker.",
    )
