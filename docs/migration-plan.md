# Migration Plan: Django + BeautifulSoup → FastAPI + Scrapy + Tortoise ORM

_Last updated: 2025-11-17_

## Goals

- Replace the legacy Django monolith with a modular FastAPI service stack.
- Swap BeautifulSoup-based scrapers for Scrapy spiders with pipelines and Celery orchestration.
- Adopt Tortoise ORM (async) for the new PostgreSQL database layer; database will be created from scratch.
- Provide analytics (NetworkX) and visualization endpoints fed by scraping jobs.

## Constraints & Assumptions

- No legacy data migration is required (database will be repopulated from new crawls).
- PostgreSQL is the only supported database target (local + prod); SQLite is no longer used even in dev.
- We keep the existing Django code until the FastAPI version serves the required endpoints.
- Incremental delivery: each milestone must be independently deployable and reversible.

## Milestones

1. **Scaffold new stack (complete)**

   - ✅ FastAPI app skeleton (`app/`), Tortoise ORM models, config, and health endpoint are in place.
   - ✅ Scrapy spider, Celery worker, and persistence services run via Docker Compose (API + worker + Postgres + Redis).
   - ✅ Requirements, environment docs, and developer bootstrap instructions landed in the repo.

2. **Feature Parity (API + scraping) — in progress**

   - ✅ Movies endpoint backed by Tortoise models with nested serializers.
   - ✅ Scrapy crawler feeds Celery task `tasks.scraping.scrape_movies`, persisting films/genres/people.
   - ⏳ People endpoints + analytics summaries still pending.
   - ⏳ Scheduling + job status tracking to follow once API surface is stable.

3. **Analytics & visualization**

   - Build NetworkX service for collaboration graphs, centrality metrics, etc.
   - Add endpoints for analytics snapshots and integrate Plotly/Pyvis exports.

4. **Ops & decommission**
   - Finalize Docker deployment (API, crawler workers, Redis, Postgres).
   - Update CI/CD (pytest, mypy, formatting, crawler smoke tests).
   - Remove Django modules once FastAPI stack passes acceptance tests.

## Rollback Strategy

- Keep Django app running behind a feature flag until FastAPI covers production traffic.
- Maintain separate databases (legacy vs. new) until verification is complete.
- Each milestone merged via PR with automated tests; revert PR to roll back.

## Open Questions

- Frontend strategy (pure API vs. new UI bundle).
- Scheduling cadence and retention policy for crawl results.

## Next Actions

1. Finish people- and analytics-focused FastAPI endpoints, including serializers and tests.
2. Add crawl scheduling + job status tracking (Celery beat or custom scheduler) with API surface for monitoring.
3. Introduce analytics/visualization service (NetworkX metrics + export endpoints) with seed datasets.
4. Harden CI/CD: pytest suite for API + tasks, linting, and crawler smoke test in Docker.
