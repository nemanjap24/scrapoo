from fastapi import APIRouter

from . import analytics, health, movies, people

api_router = APIRouter()
api_router.include_router(health.router, prefix="/health", tags=["health"])
api_router.include_router(movies.router, prefix="/movies", tags=["movies"])
api_router.include_router(people.router, prefix="/people", tags=["people"])
api_router.include_router(analytics.router, prefix="/analytics", tags=["analytics"])
