# sitemap_collector

Standalone script/module to collect URLs from robots.txt -> sitemaps -> nested sitemaps.

## FastAPI + Scrapy stack (WIP)

The project is migrating to a FastAPI + Scrapy + Celery architecture. To run the local stack
with Docker Compose (API, Celery worker, PostgreSQL, Redis, Streamlit dashboard):

```bash
docker compose up --build
```

- API: http://localhost:8000 (FastAPI docs at `/docs`).
- PostgreSQL: exposed on port 5432 (default credentials in `docker-compose.yml`).
- Redis: exposed on port 6379 for Celery broker/result backend.
- Dashboard: http://localhost:8501 (Streamlit UI powered by the analytics endpoints).

Set custom secrets via `.env` or override the compose environment variables before running.

### Triggering Scrapy crawls

Once the stack is up, you can enqueue CSFD crawls directly from the API:

```bash
curl -X POST http://localhost:8000/api/v1/movies/scrape \
	-H "Content-Type: application/json" \
	-d '{
			"from_page": 1,
			"max_pages": 1,
			"max_films": 1000,
			"include_people": true,
			"include_movies": true
		}'
```

The endpoint now resolves CSFD sitemap files from `https://static.pmgstatic.com/sitemaps/www.csfd.sk/sitemap.xml`,
queues the selected sitemap URLs, and lets the Celery worker expand them into individual film pages. The worker
then crawls each film via Scrapy and persists the results in PostgreSQL (optionally capturing linked people).

Available POST body options:

- `from_page` _(int, optional)_ – 1-based sitemap index to start at. Skip earlier sitemaps by setting this to >1.
- `max_pages` _(int, optional)_ – number of sitemap files to process after `from_page`. Hard capped at 250.
- `max_films` _(int, optional)_ – stops the crawl once this many film detail pages have been visited, even if there
  are still sitemaps left in the window.
- `include_people` _(bool, default true)_ – when true, every discovered actor/director also gets a dedicated person
  crawl; when false only the inline person stubs from film pages are emitted.
- `include_movies` _(bool, default true)_ – future-proof flag for creator-only runs. Leave true unless you
  deliberately want to ignore film URLs.

After enqueueing a scrape, poll task state via:

- `GET /api/v1/movies/scrape/{task_id}`
  - Returns Celery state (`PENDING`, `STARTED`, `SUCCESS`, `FAILURE`), completion flags, and task result/error payload.

#### Worker internals (important when toggling `include_people`)

- Every scrape job shells out to `python -m app.services.csfd_scraper`. That helper process spins up Twisted's
  reactor, runs the Scrapy spider, and prints the collected payloads as JSON. Because a brand-new process is used
  per job, Celery never attempts to restart a reactor inside its own worker pool, eliminating the
  `twisted.internet.error.ReactorNotRestartable` crashes. When the helper exits with a non-zero code, the API task
  surfaces its stdout/stderr for quick diagnosis.
- Films always emit creator/person stubs inline, regardless of the `include_people` flag. Those stubs give us
  director/actor slugs, names, and URLs directly from the film page so we can persist relationships quickly.
- Setting `include_people=true` additionally queues each encountered person for a dedicated detail-page crawl.
  When `include_people=false`, no extra person requests are scheduled—only the inline stubs from the film remain,
  which is sufficient for speeding up ingestion when full biographies are not needed.
- Crawls stream seeds in configurable batches so long-running jobs stay predictable. Adjust `SCRAPE_CHUNK_SIZE`
  (default 200) to control how many film URLs each helper process tackles before persistence runs.

### Core data endpoints (current response shape)

- `GET /api/v1/movies?limit=1`
  - Returns film records aligned with the Tortoise `Film` model.
  - Genres are represented as a many-to-many list in `genres`.
  - There is no singular `genre`/`genre_id` field in this API shape.

Example response item:

```json
{
  "id": 57,
  "title": "Hana a jej sestry",
  "original_title": "Hannah and Her Sisters",
  "country_id": 6,
  "language": "Unknown",
  "release_year": 1986,
  "rating": null,
  "num_votes": null,
  "url": "https://www.csfd.sk/film/38-hana-a-jej-sestry/prehlad/",
  "country": { "id": 6, "name": "USA" },
  "genres": [],
  "directors": [],
  "actors": []
}
```

- `GET /api/v1/people?limit=1`
  - Returns people with computed `film_count` and linked `films` entries.

Example response item:

```json
{
  "id": 3571,
  "name": "Soon Yi Previn",
  "occupation": "Actor",
  "url": "https://www.csfd.sk/tvorca/587986-soon-yi-previn/",
  "birth_date": null,
  "film_count": 0,
  "films": []
}
```

### Analytics overview endpoint

- `GET /api/v1/analytics/overview?limit=5` aggregates crawl results:
  - `total_films` / `total_people` give collection sizes.
  - `top_actors` and `top_directors` return the most prolific people (by film count) for their roles.
  - `prolific_countries` highlight countries with the highest number of films in the database.
- Adjust `limit` (1–20) to control how many entries each list contains.

### Additional analytics endpoints

- `GET /api/v1/analytics/people?roles=actor&roles=director&limit=5&min_films=1`
  - Query multiple roles (default actor+director) and see the most prolific people per role.
  - `limit` (1–30) caps how many people each role returns; `min_films` filters out lightly credited entries.
- `GET /api/v1/analytics/countries?limit=10`
  - Returns the busiest production countries plus their share of the total film catalog.
- `GET /api/v1/analytics/releases?bucket=decade&limit=12`
  - Summarizes how many films were released per year or decade (use `bucket=year` for yearly breakdowns).
- `GET /api/v1/analytics/network/collaboration?limit_nodes=10&limit_edges=10&min_shared_films=2`
  - Computes a NetworkX-powered collaboration graph: returns graph stats, the most central creators, and
    the strongest partnerships (weighted by shared films).

### Streamlit dashboard

- Already runs as part of `docker compose up` (see http://localhost:8501).
- For standalone use, install dependencies (`pip install -r requirements.txt`), set `SCRAPOO_API_URL`
  if needed (default `http://localhost:8000/api/v1`), then run `streamlit run dashboard/streamlit_app.py`.
- The UI surfaces the same analytics (overview, roles, countries, releases, collaboration graph) with Plotly charts
  plus an interactive PyVis-powered network visualization of the strongest collaborations.

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
