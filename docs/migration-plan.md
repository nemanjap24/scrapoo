# Migration Plan: Django + BeautifulSoup → FastAPI + Scrapy + Tortoise ORM

_Last updated: 2026-04-14_

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
   - ✅ Scraper now shells out to an isolated helper process (fixes Twisted reactor restarts) and normalizes
     person URLs/IDs so duplicates such as `/prehlad` variants collapse into a single record.
   - ✅ People endpoints aligned with Tortoise relations (`film_roles` / `person_in_films`) and available via API.
   - ✅ Scrape job status tracking is available at `GET /api/v1/movies/scrape/{task_id}`.
   - ⏳ Scheduling (periodic crawl orchestration) still pending.

3. **Analytics & visualization**
   - ✅ Initial NetworkX service for collaboration graphs with degree centrality + partnership stats.
   - ✅ Streamlit dashboard powered by the analytics API (overview, roles, countries, releases, network).
   - Add endpoints for analytics snapshots and integrate Plotly/Pyvis exports.

4. **Ops & decommission**
   - Finalize Docker deployment (API, crawler workers, Redis, Postgres).
   - ✅ Introduced clean FastAPI-focused test flow that excludes legacy Django tests
     (`scripts/test_fastapi_stack.sh` => `app.tests.test_api_smoke` + `scraper.test_sitemap_collector`).
   - Update CI/CD (pytest/mypy formatting and crawler smoke tests).
   - Remove Django modules once FastAPI stack passes acceptance tests.

## Rollback Strategy

- Keep Django app running behind a feature flag until FastAPI covers production traffic.
- Maintain separate databases (legacy vs. new) until verification is complete.
- Each milestone merged via PR with automated tests; revert PR to roll back.

## Open Questions

- Frontend strategy (pure API vs. new UI bundle).
- Scheduling cadence and retention policy for crawl results.

## Recent Progress

- Migrated Scrapy execution to a subprocess helper (`python -m app.services.csfd_scraper`) so each crawl gets a
  fresh Twisted reactor and Celery never crashes with `ReactorNotRestartable`.
- Canonicalized person URLs during persistence, guaranteeing that credits like `…/alexandr-nikitin/` and
  `…/alexandr-nikitin/prehlad/` resolve to the same `Person` row; dramatically reduces duplicate people counts.
- README now documents all scrape payload options and the helper-process behavior to align developer expectations.
- Analytics router now exposes role leaderboards, country share stats, release-year/decade distributions, and collaboration graph metrics powered by NetworkX.
- Streamlit dashboard consumes those endpoints to offer interactive charts without a separate frontend stack.
- Scrapy jobs now process sitemap seeds in configurable batches (`SCRAPE_CHUNK_SIZE`) so long crawls stay stable and per-chunk metrics are available for monitoring.
- Added scrape task polling endpoint (`GET /api/v1/movies/scrape/{task_id}`) for operational visibility.
- Added FastAPI smoke tests plus a clean Docker test entrypoint that avoids executing legacy Django tests.

## Next Actions

1. Add crawl scheduling (Celery beat or custom scheduler) with an API/reporting surface.
2. Expand automated tests beyond smoke coverage (API integration + task failure paths).
3. Harden CI/CD: pytest/mypy/format checks and containerized smoke tests in pipeline.
4. Define and execute legacy Django decommission checklist once acceptance criteria are green.
