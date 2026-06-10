# Scrapoo Operations Runbook

Last updated: 2026-04-14
Scope: Local and CI-like operations for FastAPI API, Celery worker, Redis, PostgreSQL, and Streamlit dashboard.

## 1. Start the stack

```bash
docker compose up --build -d
```

Verify services:

```bash
docker compose ps
```

Expected services:
- api
- worker
- beat
- postgres
- redis
- dashboard

## 2. Health checks

API health:

```bash
curl -sS "http://localhost:8000/api/v1/health/"
```

Expected payload:

```json
{"status":"ok"}
```

Dashboard availability:

```bash
curl -sS -I "http://localhost:8501" | head -n 1
```

Expected status line includes `200 OK`.

## 3. Stop / restart

Stop without deleting volumes:

```bash
docker compose down
```

Stop and remove volumes (destructive for local DB data):

```bash
docker compose down -v
```

Restart only API + worker:

```bash
docker compose up -d api worker
```

## 4. Scrape operations

Enqueue scrape task:

```bash
curl -X POST "http://localhost:8000/api/v1/movies/scrape" \
  -H "Content-Type: application/json" \
  -d '{"from_page":1,"max_pages":1,"max_films":1,"include_people":true,"include_movies":true}'
```

Poll status:

```bash
curl -sS "http://localhost:8000/api/v1/movies/scrape/<task_id>"
```

If the result contains `blocked_by_antibot=true`, CSFD returned an anti-bot challenge page instead of film HTML. In that case the worker is healthy, but live CSFD extraction cannot continue. Check `antibot_urls` and `antibot_reason` in the task result, keep scheduled CSFD scraping disabled, and use TMDB ingestion or previously collected CSFD data until upstream access is available again.

Periodic scheduling (Celery beat):

```bash
docker compose logs --tail=200 beat
```

Look for entries that indicate due tasks are being sent (for example, scheduled crawl dispatches).

## 5. Task failure diagnostics (alerting/logging path)

Primary signal:
- `GET /api/v1/movies/scrape/{task_id}` returning `state=FAILURE` with `error` message.

Operational triage steps:

1. Check worker logs:

```bash
docker compose logs --tail=200 worker
```

2. Check API logs:

```bash
docker compose logs --tail=200 api
```

3. If network/sitemap fetch failures appear, validate connectivity from API container:

```bash
docker compose exec -T api python -c "import urllib.request; print(urllib.request.urlopen('https://static.pmgstatic.com/sitemaps/www.csfd.sk/sitemap.xml', timeout=15).status)"
```

4. Re-run a minimal scrape to confirm recovery:

```bash
curl -X POST "http://localhost:8000/api/v1/movies/scrape" \
  -H "Content-Type: application/json" \
  -d '{"from_page":1,"max_pages":1,"max_films":1,"include_people":false,"include_movies":true}'
```

## 6. Common issues

Issue: `ReactorNotRestartable` in scraping path
- Current architecture uses subprocess helper (`python -m app.services.csfd_scraper`) to isolate Twisted reactor per run.
- If this reappears, inspect worker logs and confirm helper subprocess invocation paths.

Issue: CSFD scrape returns `blocked_by_antibot=true`
- CSFD served an anti-bot challenge page, commonly titled `Making sure you're not a bot!`.
- The scrape task stops early and records `antibot_urls` to avoid repeatedly requesting pages that cannot be parsed.
- This is an upstream access limitation, not an API, Celery, Redis, or database failure.
- Keep `SCRAPE_SCHEDULE_MINUTES=0` while this persists and prefer TMDB ingestion for fresh data.

Issue: API starts but DB calls fail
- Verify `DATABASE_URL` env inside containers.
- Confirm postgres container is healthy and reachable.

Issue: Dashboard loads but shows empty charts
- Verify API URL configured for dashboard container (`SCRAPOO_API_URL=http://api:8000/api/v1`).
- Validate analytics endpoints directly from host.
