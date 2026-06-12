# Scrapoo

[![FastAPI Stack Tests](https://github.com/nemanjap24/scrapoo/actions/workflows/fastapi-tests.yml/badge.svg)](https://github.com/nemanjap24/scrapoo/actions/workflows/fastapi-tests.yml)

Scrapoo is a FastAPI, Scrapy, Celery and Streamlit application for collecting film data, storing it in PostgreSQL, and analysing actor collaboration graphs. It supports two separated data sources:

- CSFD data in the main `scrapoo` database.
- TMDB data in the separate `scrapoo_tmdb` database.

The same analytics API and dashboard can be used for both sources through the `source=csfd|tmdb` parameter.

## Run Locally

```bash
docker compose up --build
```

Services:

- API: <http://localhost:8000> with FastAPI docs at `/docs`
- Dashboard: <http://localhost:8501>
- PostgreSQL: `localhost:5432`
- TMDB PostgreSQL: `localhost:5433`
- Redis: `localhost:6379`
- Celery worker and Celery beat for background jobs

Optional TMDB configuration can be provided through `.env`:

```env
TMDB_API_KEY=
TMDB_ACCESS_TOKEN=
```

TMDB requests are rate-limited by `TMDB_REQUESTS_PER_WINDOW` and `TMDB_RATE_LIMIT_WINDOW_SECONDS`.

## Dashboard

The Streamlit dashboard runs at <http://localhost:8501>. It contains:

- `Overview`: collection totals, top actors/directors, prolific countries
- `People`: role-based person statistics
- `Countries`: film share by production country
- `Releases`: release distribution by year or decade
- `Graph Analysis`: actor projection graph analysis
- `Scraping`: CSFD/TMDB job submission and job status tracking

`Graph Analysis` is the main analytical view. It shows:

- core actor network sample
- Leiden communities and modularity
- clustering and transitivity
- average shortest path in the largest connected component
- k-core structure and top core actors

The dashboard hides empty analytics gracefully. If the selected source has no films, it shows:

```text
Databáza je prázdna a nemáme žiadne filmy.
```

For standalone dashboard use:

```bash
pip install -r requirements.txt
SCRAPOO_API_URL=http://localhost:8000/api/v1 streamlit run dashboard/streamlit_app.py
```

## API

### Health

- `GET /api/v1/health/`

### Movies

- `GET /api/v1/movies?limit=50`
- `POST /api/v1/movies`
- `POST /api/v1/movies/scrape`
- `GET /api/v1/movies/scrape/{task_id}`
- `POST /api/v1/movies/tmdb/scrape`
- `GET /api/v1/movies/tmdb/scrape/{task_id}`

CSFD scrape example:

```bash
curl -X POST http://localhost:8000/api/v1/movies/scrape \
  -H "Content-Type: application/json" \
  -d '{
    "from_page": 1,
    "max_pages": 1,
    "max_films": 1000,
    "skip_existing": true
  }'
```

TMDB import example:

```bash
curl -X POST http://localhost:8000/api/v1/movies/tmdb/scrape \
  -H "Content-Type: application/json" \
  -d '{
    "limit": 1000,
    "language": "en-US"
  }'
```

### People

- `GET /api/v1/people?limit=50`
- `GET /api/v1/people/{person_id}`
- `POST /api/v1/people/enrich`
- `GET /api/v1/people/enrich/{task_id}`

### Analytics

All analytics endpoints accept `source=csfd` or `source=tmdb`.

- `GET /api/v1/analytics/overview?source=csfd&limit=10`
- `GET /api/v1/analytics/people?source=csfd&roles=actor&roles=director&limit=10&min_films=1`
- `GET /api/v1/analytics/countries?source=csfd&limit=10`
- `GET /api/v1/analytics/releases?source=csfd&bucket=decade&limit=12`
- `GET /api/v1/analytics/network/actor-projection?source=csfd&max_diameter_nodes=1000&max_cast_size=30`

The actor projection endpoint builds a graph where vertices are actors and an edge means that two actors appeared in at least one shared film. The default dashboard settings keep the graph practical and interpretable:

- `max_cast_size=30` limits very large casts so one movie does not create an oversized clique.
- `max_diameter_nodes=1000` switches large shortest-path calculations to sampling.
- `top_core_actors=25` limits the displayed core actor sample.
- `min_core_actor_degree=1` filters low-degree actors from the core actor table.

## Background Jobs

Celery worker processes long-running CSFD scraping, TMDB ingestion and person enrichment jobs. Celery beat can schedule periodic CSFD crawls through these environment variables:

- `SCRAPE_SCHEDULE_MINUTES` (`0` disables scheduling)
- `SCRAPE_SCHEDULE_FROM_PAGE`
- `SCRAPE_SCHEDULE_MAX_PAGES`
- `SCRAPE_SCHEDULE_MAX_FILMS`
- `SCRAPE_SCHEDULE_INCLUDE_PEOPLE`
- `SCRAPE_SCHEDULE_INCLUDE_MOVIES`
- `SCRAPE_PARALLEL_CHUNKS`

Useful logs:

```bash
docker compose logs --tail=200 api
docker compose logs --tail=200 worker
docker compose logs --tail=200 beat
docker compose logs --tail=200 dashboard
```

## Testing

Run the FastAPI test stack inside the API container:

```bash
docker compose exec -T api sh scripts/test_fastapi_stack.sh
```

Or run individual tests:

```bash
docker compose exec -T api python -m unittest app.tests.test_api_smoke
docker compose exec -T api python -m unittest app.tests.test_graph_analytics_controlled_datasets
docker compose exec -T api python -m unittest app.tests.test_e2e_functional_requirements
```

## License

MIT-style: use in your research, cite as needed.
