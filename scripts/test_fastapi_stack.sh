#!/usr/bin/env sh
set -eu

# Clean test flow for the FastAPI stack (excludes legacy Django tests).
python -m unittest -q app.tests.test_api_smoke app.tests.test_e2e_functional_requirements scraper.test_sitemap_collector
