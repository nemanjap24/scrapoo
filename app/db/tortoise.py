from typing import Sequence

from fastapi import FastAPI
from tortoise.contrib.fastapi import register_tortoise

from app.core.config import settings


def init_tortoise(app: FastAPI, models: Sequence[str] | None = None) -> None:
    """Register Tortoise ORM on the FastAPI application."""

    register_tortoise(
        app,
        db_url=settings.DATABASE_URL,
        modules={"models": list(models or settings.TORTOISE_MODELS)},
        generate_schemas=True,
        add_exception_handlers=True,
    )
