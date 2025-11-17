from typing import List, Optional

from pydantic import BaseModel, Field, HttpUrl, field_validator


class ScrapeMoviesRequest(BaseModel):
    urls: Optional[List[HttpUrl]] = Field(
        default=None,
        description="Absolute URLs to CSFD listing or film pages. Defaults to MAGIC_URL when omitted.",
    )
    max_listing_pages: int = Field(
        default=1,
        ge=1,
        le=25,
        description="How many pagination steps to traverse when seeding from listing pages.",
    )
    include_people: bool = Field(
        default=False,
        description="Also crawl linked person pages when available.",
    )

    @field_validator("urls", mode="before")
    @classmethod
    def _strip_whitespace(cls, value):  # noqa: D401 - short helper
        if value is None:
            return value
        cleaned: List[str] = []
        for item in value:
            if isinstance(item, str):
                cleaned.append(item.strip())
            else:
                cleaned.append(item)
        return cleaned


class ScrapeJobResponse(BaseModel):
    task_id: str
    seeds: List[str]
    include_people: bool
    max_listing_pages: int
    queued: int
