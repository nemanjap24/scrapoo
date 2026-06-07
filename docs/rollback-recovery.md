# Rollback and Recovery Guide

Last updated: 2026-04-14
Scope: Recovery and rollback procedures for the FastAPI stack after failed deployments or data incidents.

## 1. Application rollback (code/config)

Use a non-destructive Git rollback by checking out the previous known-good revision and redeploying containers.

Identify recent commits:

```bash
git log --oneline -n 10
```

Switch to known-good commit on a hotfix branch:

```bash
git checkout -b rollback/<date>-hotfix <known_good_commit_sha>
```

Rebuild and restart stack:

```bash
docker compose up --build -d
```

Validate health:

```bash
curl -sS "http://localhost:8000/api/v1/health/"
curl -sS -I "http://localhost:8501" | head -n 1
```

## 2. Database backup procedure

Create SQL backup from running postgres container:

```bash
docker compose exec -T postgres pg_dump -U scrapoo -d scrapoo > docs/evidence/backup-<date>.sql
```

Recommended verification:
- Ensure dump file is non-empty.
- Store copy in external backup location (outside repository workspace).

## 3. Database restore rehearsal (non-destructive)

Restore backup into temporary test database:

```bash
docker compose exec -T postgres psql -U scrapoo -d postgres -c "DROP DATABASE IF EXISTS scrapoo_restore_test;"
docker compose exec -T postgres psql -U scrapoo -d postgres -c "CREATE DATABASE scrapoo_restore_test;"
docker compose exec -T postgres psql -U scrapoo -d scrapoo_restore_test < docs/evidence/backup-<date>.sql
```

Validate restored data:

```bash
docker compose exec -T postgres psql -U scrapoo -d scrapoo_restore_test -c "SELECT COUNT(*) AS film_count FROM film;"
```

Clean rehearsal database:

```bash
docker compose exec -T postgres psql -U scrapoo -d postgres -c "DROP DATABASE scrapoo_restore_test;"
```

## 4. Critical seed replay after incident

After rollback/restore, replay minimal crawl seed to confirm ingestion path:

```bash
curl -X POST "http://localhost:8000/api/v1/movies/scrape" \
  -H "Content-Type: application/json" \
  -d '{"from_page":1,"max_pages":1,"max_films":1,"include_people":false,"include_movies":true}'
```

Poll task status until terminal state:

```bash
curl -sS "http://localhost:8000/api/v1/movies/scrape/<task_id>"
```

Expected: `state=SUCCESS` with non-empty chunk/result payload.

## 5. Rehearsal evidence (2026-04-14)

- Backup artifact created: `docs/evidence/backup-rehearsal-2026-04-14.sql`.
- Restore rehearsal validated in temporary DB (`scrapoo_restore_test`) with `film_count=37`.
- Critical seed replay task: `79ba118a-abad-4652-8ee7-a7426bc4d336` reached `SUCCESS`.
