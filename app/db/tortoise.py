from typing import Sequence

from fastapi import FastAPI
from tortoise.contrib.fastapi import register_tortoise

from app.core.config import settings


def init_tortoise(app: FastAPI, models: Sequence[str] | None = None) -> None:
    """Register Tortoise ORM on the FastAPI application."""

    register_tortoise(
        app,
        config={
            "connections": {
                "default": settings.DATABASE_URL,
                "tmdb": settings.TMDB_DATABASE_URL,
            },
            "apps": {
                "models": {
                    "models": list(models or settings.TORTOISE_MODELS),
                    "default_connection": "default",
                },
            },
        },
        generate_schemas=True,
        add_exception_handlers=True,
    )
