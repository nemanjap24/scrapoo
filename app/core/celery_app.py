from celery import Celery

from app.core.config import settings

celery_app = Celery(
    "scrapoo",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND,
)

celery_app.conf.update(
    task_track_started=True,
    task_serializer="json",
    result_serializer="json",
    accept_content=["json"],
    timezone="UTC",
    enable_utc=True,
    broker_connection_retry_on_startup=True,
)

if settings.SCRAPE_SCHEDULE_MINUTES > 0:
    celery_app.conf.beat_schedule = {
        "schedule-default-crawl": {
            "task": "tasks.scraping.schedule_default_crawl",
            "schedule": settings.SCRAPE_SCHEDULE_MINUTES * 60,
        }
    }


@celery_app.task(name="tasks.health.ping")
def ping() -> str:
    """Simple health task used by docker-compose readiness checks."""
    return "pong"


# Import task modules to register them with this Celery app
try:  # pragma: no cover - defensive import for early scaffolding
    from app.tasks import scraping  # noqa: F401
except Exception:
    pass
