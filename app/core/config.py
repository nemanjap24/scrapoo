from pydantic import HttpUrl, field_validator, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application configuration loaded from environment variables or .env."""

    PROJECT_NAME: str = "Scrapoo API"
    VERSION: str = "0.1.0"
    API_V1_PREFIX: str = "/api/v1"

    DATABASE_URL: str | None = None
    DB_NAME: str = "scrapoo"
    DB_USER: str = "scrapoo"
    DB_PASSWORD: str = "scrapoo"
    DB_HOST: str = "localhost"
    DB_PORT: int = 5432
    TORTOISE_MODELS: list[str] = ["app.models.entities"]

    CELERY_BROKER_URL: str = "redis://localhost:6379/0"
    CELERY_RESULT_BACKEND: str = "redis://localhost:6379/1"

    SCRAPY_SETTINGS_MODULE: str = "crawler.settings"
    BASE_URL: HttpUrl = "https://www.csfd.sk"
    MAGIC_URL: HttpUrl = (
        "https://www.csfd.sk/rebricky/vlastny-vyber/?page=1&filter="
        "rlW0rKOyVwbjYPWipzyanJ4vBz51oTjfVzqyoaWyVwcoKFjvrJIupy9zpz9gVwblZQRjYPW5"
        "MJSlK3EiVwblZQVjYPWuL3EipvV6J10fVzEcpzIwqT9lVwcoKK0"
    )
    SITEMAP_INDEX_URL: HttpUrl = "https://static.pmgstatic.com/sitemaps/www.csfd.sk/sitemap.xml"
    REQUEST_DELAY: float = 0.0
    SCRAPY_CONCURRENT_REQUESTS: int = 32
    SCRAPE_CHUNK_SIZE: int = 200

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=False,
    )

    @field_validator("REQUEST_DELAY", mode="before")
    @classmethod
    def _sanitize_delay(cls, value: float | str | None) -> float:
        if value is None:
            return cls.model_fields["REQUEST_DELAY"].default
        if isinstance(value, (int, float)):
            return max(0.0, float(value))
        cleaned = value.split("#", 1)[0].strip()
        if not cleaned:
            return cls.model_fields["REQUEST_DELAY"].default
        return max(0.0, float(cleaned))

    @model_validator(mode="after")
    def _ensure_database_url(self) -> "Settings":
        if not self.DATABASE_URL:
            self.DATABASE_URL = (
                f"postgres://{self.DB_USER}:{self.DB_PASSWORD}@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"
            )
        return self

    @field_validator("SCRAPE_CHUNK_SIZE", mode="before")
    @classmethod
    def _sanitize_chunk_size(cls, value: int | str | None) -> int:
        default = cls.model_fields["SCRAPE_CHUNK_SIZE"].default
        if value is None:
            return default
        if isinstance(value, int):
            return max(1, value)
        cleaned = value.split("#", 1)[0].strip()
        if not cleaned:
            return default
        try:
            parsed = int(float(cleaned))
        except ValueError:
            return default
        return max(1, parsed)


settings = Settings()
