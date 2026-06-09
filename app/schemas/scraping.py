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
        default=False,
        description="Also crawl linked person pages (actors and directors). Disabled by default so film collection stays fast.",
    )
    include_movies: bool = Field(
        default=True,
        description="When false, movie URLs are ignored (primarily for future creator-only crawls).",
    )
    skip_existing: bool = Field(
        default=False,
        description="When true, skip film URLs that already exist in the database before crawling.",
    )


class ScrapeJobResponse(BaseModel):
    task_id: str
    from_page: Optional[int] = None
    max_pages: Optional[int] = None
    max_films: Optional[int] = None
    include_people: bool
    include_movies: bool
    skip_existing: bool = False
    sitemaps: List[str] = Field(default_factory=list)
    queued: int = Field(
        default=0,
        description="Number of sitemap XML files queued for the worker.",
    )


class ScrapeJobStatusResponse(BaseModel):
    task_id: str
    state: str = Field(description="Celery task state (PENDING, STARTED, SUCCESS, FAILURE, etc.).")
    ready: bool = Field(description="True when Celery reports the task as finished.")
    successful: bool = Field(description="True only when task state is SUCCESS.")
    result: Optional[dict] = Field(
        default=None,
        description="Task payload returned on success.",
    )
    error: Optional[str] = Field(
        default=None,
        description="Error details when task failed.",
    )


class EnrichPeopleRequest(BaseModel):
    limit: int = Field(
        default=100,
        ge=1,
        le=10000,
        description="Maximum number of existing people to enrich in this job.",
    )
    only_missing_birth_date: bool = Field(
        default=True,
        description="When true, enrich only people whose birth_date is still empty.",
    )


class EnrichPeopleJobResponse(BaseModel):
    task_id: str
    limit: int
    only_missing_birth_date: bool


class TMDBScrapeRequest(BaseModel):
    limit: int = Field(
        default=30000,
        ge=1,
        le=30000,
        description="Maximum number of TMDB movies to import, sorted by TMDB popularity descending.",
    )
    language: str = Field(
        default="en-US",
        min_length=2,
        max_length=10,
        description="TMDB response language.",
    )
    include_adult: bool = Field(
        default=False,
        description="Forwarded to TMDB discover/movie include_adult.",
    )
    actor_limit: Optional[int] = Field(
        default=None,
        ge=1,
        le=1000,
        description="Optional cap for actors saved per movie. Leave empty to persist the full TMDB cast list.",
    )


class TMDBScrapeJobResponse(BaseModel):
    task_id: str
    limit: int
    language: str
    include_adult: bool
    actor_limit: Optional[int] = None
