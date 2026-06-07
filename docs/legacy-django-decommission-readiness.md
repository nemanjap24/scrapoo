# Legacy Django Decommission Readiness Checklist

Last updated: 2026-04-14 (initial baseline populated)
Owner: Backend team
Scope: Final decision for deleting legacy Django code from this repository.

## Decision Rule

GO means all mandatory gates are PASS and no critical open incidents exist.
NO-GO means at least one mandatory gate is FAIL, UNKNOWN, or not yet verified.

## Mandatory Gates (all must pass)

### Gate 1: FastAPI feature parity

Status: [x] PASS  [ ] FAIL  [ ] UNKNOWN

Acceptance criteria:
- Movies endpoints provide create, list, and scrape enqueue functionality.
- People endpoints provide list and detail functionality.
- Analytics endpoints provide overview, people, countries, releases, and collaboration graph.
- No business-critical endpoint still depends on Django views or models.

Evidence to collect:
- API smoke test report from app/tests/test_api_smoke.py.
- Manual endpoint checks against running Docker stack.

### Gate 2: Data model consistency

Status: [x] PASS  [ ] FAIL  [ ] UNKNOWN

Acceptance criteria:
- FastAPI routes and schemas match Tortoise models and live PostgreSQL schema.
- No route references legacy relation names.
- Response shapes are documented and match runtime output.

Evidence to collect:
- Current schema docs in docs/db-schema-current.puml and docs/db-schema-domain.puml.
- Route and schema review results.

### Gate 3: Background processing parity

Status: [x] PASS  [ ] FAIL  [ ] UNKNOWN

Acceptance criteria:
- Scrape enqueue works through Celery worker.
- Task status endpoint returns accurate lifecycle states.
- Failure path returns useful diagnostics.

Evidence to collect:
- Successful enqueue and polling run.
- At least one intentionally failed run with validated error payload.

Evidence captured (2026-04-14):
- Success path task_id `cbda81ea-0626-4098-8087-c78abd949632` reached `SUCCESS` with chunk/result payload.
- Failure path task_id `4ba78d50-33f9-41f2-bf2e-844fe1cfc90f` reached `FAILURE` with actionable error message:
	`Failed to fetch https://invalid.invalid/not-found-sitemap.xml: <urlopen error [Errno -2] Name or service not known>`.

### Gate 4: Test pipeline health

Status: [x] PASS  [ ] FAIL  [ ] UNKNOWN

Acceptance criteria:
- Clean FastAPI test flow passes locally in Docker.
- GitHub Actions workflow for FastAPI stack passes on target branch.
- Legacy Django tests are excluded from the FastAPI decommission gate.

Evidence to collect:
- scripts/test_fastapi_stack.sh output.
- Workflow run from .github/workflows/fastapi-tests.yml.

### Gate 5: Operational readiness

Status: [x] PASS  [ ] FAIL  [ ] UNKNOWN

Acceptance criteria:
- Runbook exists for starting, stopping, and troubleshooting API, worker, Redis, and Postgres.
- Dashboard works against FastAPI analytics endpoints.
- Alerting/logging path is defined for task failures.

Evidence to collect:
- Verified compose startup and health checks.
- Basic operational notes in project docs.

Evidence captured (2026-04-14):
- `docker compose ps` confirms api/worker/postgres/redis/dashboard are up.
- API health check returned `{"status":"ok"}` from `/api/v1/health/`.
- Dashboard availability check returned HTTP `200 OK` on `http://localhost:8501`.
- Operations runbook added: `docs/operations-runbook.md` (startup, stop, troubleshooting, task-failure diagnostics).

### Gate 6: Rollback and recovery

Status: [x] PASS  [ ] FAIL  [ ] UNKNOWN

Acceptance criteria:
- Rollback path is documented if post-delete regressions appear.
- Backup/restore plan for PostgreSQL is documented and tested.
- Critical seed crawl can be replayed quickly.

Evidence to collect:
- Written rollback instructions.
- One tested restore rehearsal report.

Evidence captured (2026-04-14):
- Backup artifact created: `docs/evidence/backup-rehearsal-2026-04-14.sql` (~184KB).
- Restore rehearsal executed into temporary DB `scrapoo_restore_test`; validation query returned `film_count=37`.
- Rehearsal DB cleanup completed (`DROP DATABASE scrapoo_restore_test`).
- Rollback/recovery runbook added: `docs/rollback-recovery.md`.
- Critical seed replay verified via task `79ba118a-abad-4652-8ee7-a7426bc4d336` (`SUCCESS`).

## Optional but strongly recommended gates

### Gate 7: Scheduling maturity

Status: [x] PASS  [ ] FAIL  [ ] SKIPPED

Acceptance criteria:
- Periodic crawl scheduling is implemented and monitored.

Evidence captured (2026-04-14):
- `scrapoo-beat` service added and running via Docker Compose.
- Beat log confirms periodic dispatch:
	`Scheduler: Sending due task schedule-default-crawl (tasks.scraping.schedule_default_crawl)`.
- Worker log confirms execution chain:
	`tasks.scraping.schedule_default_crawl` -> `tasks.scraping.scrape_movies` -> `succeeded`.

### Gate 8: Expanded integration coverage

Status: [ ] PASS  [ ] FAIL  [x] SKIPPED

Acceptance criteria:
- Integration tests cover scrape success, scrape failure, and analytics consistency after ingestion.

## Final Sign-off

Engineering lead: ____________________  Date: __________
Product/Research owner: ______________  Date: __________
Ops/Infra owner: _____________________  Date: __________

Final decision: [x] GO  [ ] NO-GO

If NO-GO, blocking items:
1. None.
