from fastapi import FastAPI

from app.api.routes import api_router
from app.core.config import settings
from app.db.tortoise import init_tortoise
from app.services.analytics_cache import close_analytics_cache

app = FastAPI(title=settings.PROJECT_NAME, version=settings.VERSION)
app.include_router(api_router, prefix=settings.API_V1_PREFIX)

# Register database (generate schema automatically for the new stack)
init_tortoise(app)


@app.on_event("shutdown")
async def shutdown_cache() -> None:
    await close_analytics_cache()


@app.get("/", tags=["root"], summary="Root endpoint")
async def root() -> dict[str, str]:
    return {"message": "Scrapoo FastAPI backend"}
