from __future__ import annotations

import unittest

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


if __name__ == "__main__":
    unittest.main()
