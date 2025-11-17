# sitemap_collector

Standalone script/module to collect URLs from robots.txt -> sitemaps -> nested sitemaps.

## FastAPI + Scrapy stack (WIP)

The project is migrating to a FastAPI + Scrapy + Celery architecture. To run the local stack
with Docker Compose (API, Celery worker, PostgreSQL, Redis):

```bash
docker compose up --build
```

- API: http://localhost:8000 (FastAPI docs at `/docs`).
- PostgreSQL: exposed on port 5432 (default credentials in `docker-compose.yml`).
- Redis: exposed on port 6379 for Celery broker/result backend.

Set custom secrets via `.env` or override the compose environment variables before running.

### Triggering Scrapy crawls

Once the stack is up, you can enqueue CSFD crawls directly from the API:

```bash
curl -X POST http://localhost:8000/api/v1/movies/scrape \
	-H "Content-Type: application/json" \
	-d '{
				"urls": ["https://www.csfd.sk/rebricky/vlastny-vyber/?page=1"],
				"max_listing_pages": 2,
				"include_people": false
			}'
```

The endpoint responds with the Celery task id plus the seeds that were queued. The worker
scrapes each film detail page via Scrapy and stores/updates the resulting metadata in PostgreSQL.

## Legacy sitemap collector module

Features

- Fetches `robots.txt` and discovers sitemap files (supports nested sitemapindex files).
- Fetches sitemap XML or `.xml.gz`, extracts `<loc>` URLs.
- Concurrent sitemap downloading and parsing (ThreadPoolExecutor).
- Supports output in JSON or CSV formats.
- Can save only film URLs (`/film/`) and creator URLs (`/tvorca/`).
- Optionally rotates existing output files into `archive/` to avoid overwriting.
- Basic logging with `--verbose` and `--quiet`.

Usage

Run the module from the project root:

```bash
python3 -m scraper.sitemap_collector [robots_url] [options]
```

Options of interest

- `--out, -o`: output file path (json or csv depending on `--format`).
- `--format`: `json` (default) or `csv`.
- `--workers, -w`: number of concurrent workers (default 8).
- `--verbose, -v`: verbose logging (INFO/DEBUG messages).
- `--quiet`: reduce logging output.
- `--only-film-creator`: only save URLs that include `/film/` or `/tvorca/`.
- `--rotate-existing`: if the output file exists, move it into `archive/` with a timestamp before writing.

Examples

Save JSON with only films and creators, rotate existing file:

```bash
python3 -m scraper.sitemap_collector --only-film-creator --rotate-existing --out csfd_films_creators.json
```

Save CSV with types (film/creator/other):

```bash
python3 -m scraper.sitemap_collector --format csv --out all_urls.csv
```

Notes & research usage

- The script will retry network requests without SSL verification if local CA bundles are missing. This is only intended for research environments; for production, ensure proper certificate verification.
- For very large sites (millions of URLs) prefer using lower verbosity and larger `--workers`, and consider running on a machine with enough memory/disk.

License

- MIT-style: use in your research, cite as needed.
