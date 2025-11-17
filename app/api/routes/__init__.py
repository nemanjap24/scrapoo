from fastapi import APIRouter

from . import health, movies

api_router = APIRouter()
api_router.include_router(health.router, prefix="/health", tags=["health"])
api_router.include_router(movies.router, prefix="/movies", tags=["movies"])
