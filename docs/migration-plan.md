# Migration Plan: Django + BeautifulSoup → FastAPI + Scrapy + Tortoise ORM

_Last updated: 2025-11-16_

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

1. **Scaffold new stack (current step)**

   - Add FastAPI app skeleton (`app/`), Tortoise ORM models, config, and health endpoint.
   - Create Scrapy project shell with pipelines, settings, and Celery wiring stubs.
   - Produce cleaned `requirements.txt`, Docker Compose draft, and developer docs.

2. **Feature Parity (API + scraping)**

   - Reimplement core endpoints (movies, people, analytics summaries) in FastAPI.
   - Port BeautifulSoup logic into Scrapy spiders + pipelines storing via Tortoise ORM.
   - Introduce Celery tasks for scheduled crawls and job status tracking.

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

1. Land FastAPI + Tortoise skeleton (health endpoint) on `migrate-to-new-architecture`.
2. Commit cleaned requirements and developer run instructions.
3. Configure local PostgreSQL (docker-compose) and connection secrets.
4. Begin Scrapy project bootstrap with Celery orchestration stubs.
