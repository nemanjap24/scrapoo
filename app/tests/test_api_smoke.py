from __future__ import annotations

import unittest
from uuid import uuid4

from fastapi.testclient import TestClient

from app.main import app


class TestApiSmoke(unittest.TestCase):
    def test_root(self) -> None:
        with TestClient(app) as client:
            response = client.get("/")
            self.assertEqual(response.status_code, 200)
            payload = response.json()
            self.assertEqual(payload.get("message"), "Scrapoo FastAPI backend")

    def test_health(self) -> None:
        with TestClient(app) as client:
            response = client.get("/api/v1/health/")
            self.assertEqual(response.status_code, 200)
            self.assertEqual(response.json().get("status"), "ok")

    def test_movies_list_shape(self) -> None:
        with TestClient(app) as client:
            response = client.get("/api/v1/movies/", params={"limit": 1})
            self.assertEqual(response.status_code, 200)
            payload = response.json()
            self.assertIsInstance(payload, list)
            if payload:
                item = payload[0]
                self.assertIn("genres", item)
                self.assertNotIn("genre", item)
                self.assertNotIn("genre_id", item)

    def test_people_list_shape(self) -> None:
        with TestClient(app) as client:
            response = client.get("/api/v1/people/", params={"limit": 1})
            self.assertEqual(response.status_code, 200)
            payload = response.json()
            self.assertIsInstance(payload, list)
            if payload:
                item = payload[0]
                self.assertIn("films", item)
                self.assertIn("film_count", item)

    def test_scrape_status_pending_for_unknown_task(self) -> None:
        with TestClient(app) as client:
            response = client.get("/api/v1/movies/scrape/00000000-0000-0000-0000-000000000000")
            self.assertEqual(response.status_code, 200)
            payload = response.json()
            self.assertEqual(payload.get("state"), "PENDING")
            self.assertFalse(payload.get("ready"))
            self.assertFalse(payload.get("successful"))

    def test_tmdb_scrape_status_pending_for_unknown_task(self) -> None:
        with TestClient(app) as client:
            response = client.get("/api/v1/movies/tmdb/scrape/00000000-0000-0000-0000-000000000000")
            self.assertEqual(response.status_code, 200)
            payload = response.json()
            self.assertEqual(payload.get("state"), "PENDING")
            self.assertFalse(payload.get("ready"))
            self.assertFalse(payload.get("successful"))

    def test_create_duplicate_film_returns_conflict(self) -> None:
        unique_url = f"https://example.test/film/{uuid4()}/"
        payload = {
            "title": "API konflikt test",
            "release_year": 2026,
            "url": unique_url,
        }

        with TestClient(app) as client:
            first_response = client.post("/api/v1/movies/", json=payload)
            self.assertEqual(first_response.status_code, 200)

            duplicate_response = client.post("/api/v1/movies/", json=payload)
            self.assertEqual(duplicate_response.status_code, 409)
            self.assertEqual(duplicate_response.json().get("detail"), "Film already exists")

    def test_get_unknown_person_returns_not_found(self) -> None:
        with TestClient(app) as client:
            response = client.get("/api/v1/people/999999999")
            self.assertEqual(response.status_code, 404)
            self.assertEqual(response.json().get("detail"), "Person not found")

    def test_scrape_request_validation_rejects_out_of_range_values(self) -> None:
        with TestClient(app) as client:
            response = client.post(
                "/api/v1/movies/scrape",
                json={
                    "from_page": 0,
                    "max_pages": 251,
                    "max_films": 10001,
                },
            )
            self.assertEqual(response.status_code, 422)

    def test_analytics_source_validation_rejects_unknown_source(self) -> None:
        with TestClient(app) as client:
            response = client.get("/api/v1/analytics/overview", params={"source": "unknown"})
            self.assertEqual(response.status_code, 422)


if __name__ == "__main__":
    unittest.main()
