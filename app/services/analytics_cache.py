from __future__ import annotations

import logging
from typing import Optional

import redis.asyncio as redis
from redis.exceptions import RedisError

from app.core.config import settings

logger = logging.getLogger(__name__)

_redis_client: redis.Redis | None = None


def _get_client() -> redis.Redis:
    global _redis_client
    if _redis_client is None:
        _redis_client = redis.from_url(
            settings.ANALYTICS_CACHE_REDIS_URL,
            decode_responses=True,
            socket_connect_timeout=1.0,
            socket_timeout=1.0,
        )
    return _redis_client


async def get_cached_json(key: str) -> Optional[str]:
    if settings.ANALYTICS_CACHE_TTL_SECONDS <= 0:
        return None
    try:
        return await _get_client().get(key)
    except RedisError as exc:
        logger.warning("Analytics cache read failed for %s: %s", key, exc)
        return None


async def set_cached_json(key: str, value: str) -> None:
    ttl = settings.ANALYTICS_CACHE_TTL_SECONDS
    if ttl <= 0:
        return
    try:
        await _get_client().setex(key, ttl, value)
    except RedisError as exc:
        logger.warning("Analytics cache write failed for %s: %s", key, exc)


async def close_analytics_cache() -> None:
    global _redis_client
    if _redis_client is None:
        return
    await _redis_client.aclose()
    _redis_client = None
