from __future__ import annotations

import unittest

from scrapy.http import HtmlResponse, Request
from tortoise import Tortoise, connections

from app.api.routes.analytics import analytics_actor_projection
from app.core.config import settings
from app.models import Country, Film, Genre, Person, PersonInFilm
from app.services.csfd_scraper import CSFDSpider
from app.tasks.scraping import _persist_films, _persist_people


def _film_response(url: str, body: str) -> HtmlResponse:
    request = Request(url=url)
    return HtmlResponse(url=url, request=request, body=body.encode("utf-8"), encoding="utf-8")


class TestFunctionalRequirementsE2E(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self) -> None:
        self._cache_ttl = settings.ANALYTICS_CACHE_TTL_SECONDS
        settings.ANALYTICS_CACHE_TTL_SECONDS = 0
        await Tortoise.init(db_url="sqlite://:memory:", modules={"models": settings.TORTOISE_MODELS})
        await Tortoise.generate_schemas()

    async def asyncTearDown(self) -> None:
        settings.ANALYTICS_CACHE_TTL_SECONDS = self._cache_ttl
        await connections.close_all(discard=True)

    async def test_01_scraping_persistence_and_domain_relationships(self) -> None:
        collected: list[dict] = []
        spider = CSFDSpider(
            start_urls=["https://www.csfd.sk/film/100-testovaci-film/prehlad/"],
            item_callback=lambda item: collected.append(dict(item)),
        )
        html = """
        <html>
          <body>
            <h1>Testovaci film</h1>
            <div class="origin">Slovensko, <span>2024</span></div>
            <ul class="film-names">
              <li><img class="flag" title="Slovensko" />Originalny testovaci film</li>
            </ul>
            <div class="genres">
              <a>Drama</a>
              <a>Komedie</a>
            </div>
            <div class="rating-average">80%</div>
            <div class="creators">
              <div>
                <h4>Réžia:</h4>
                <a href="/tvorca/10-dana-reziserka/prehlad/">Dana Reziserka</a>
              </div>
              <div>
                <h4>Hrajú:</h4>
                <a href="/tvorca/20-adam-herec/prehlad/">Adam Herec</a>
                <a href="/tvorca/30-eva-herecka/prehlad/">Eva Herecka</a>
              </div>
            </div>
          </body>
        </html>
        """

        list(spider.parse_film(_film_response("https://www.csfd.sk/film/100-testovaci-film/prehlad/", html)))
        people_payloads = [item for item in collected if item.get("item_type") == "person"]
        movie_payloads = [item for item in collected if item.get("item_type") == "movie"]

        self.assertEqual(len(movie_payloads), 1)
        self.assertEqual(len(people_payloads), 3)

        people_saved = await _persist_people(people_payloads)
        films_saved = await _persist_films(movie_payloads)

        self.assertEqual(people_saved, 3)
        self.assertEqual(films_saved, 1)
        self.assertEqual(await Film.all().count(), 1)
        self.assertEqual(await Person.all().count(), 3)
        self.assertEqual(await Country.all().count(), 1)
        self.assertEqual(await Genre.all().count(), 2)
        self.assertEqual(await PersonInFilm.all().count(), 3)

        film = await Film.get(title="Testovaci film").prefetch_related(
            "country",
            "genres",
            "person_in_films__persons",
        )
        self.assertEqual(film.release_year, 2024)
        self.assertEqual(film.rating, 0.8)
        self.assertEqual(film.country.name, "Slovensko")
        self.assertEqual({genre.name for genre in film.genres}, {"Drama", "Komedie"})
        roles = {
            link.persons.name: link.role
            for link in film.person_in_films
        }
        self.assertEqual(
            roles,
            {
                "Dana Reziserka": "director",
                "Adam Herec": "actor",
                "Eva Herecka": "actor",
            },
        )

    async def test_02_repeated_processing_updates_without_duplicates(self) -> None:
        movie_payload = {
            "title": "Opakovany film",
            "original_title": "Repeatable Movie",
            "year": "2025",
            "rating": 0.75,
            "genres": ["Thriller", "Drama"],
            "directors": ["40-reziser-opakovania"],
            "actors": ["50-prvy-herec", "60-druhy-herec"],
            "country": "Cesko",
            "csfd_url": "https://www.csfd.sk/film/200-opakovany-film/prehlad/",
        }

        await _persist_films([movie_payload])
        updated_payload = {
            **movie_payload,
            "rating": 0.9,
            "genres": ["Thriller", "Krimi"],
            "actors": ["50-prvy-herec", "60-druhy-herec"],
        }
        await _persist_films([updated_payload])

        self.assertEqual(await Film.all().count(), 1)
        self.assertEqual(await Country.all().count(), 1)
        self.assertEqual(await Person.all().count(), 3)
        self.assertEqual(await PersonInFilm.all().count(), 3)

        film = await Film.get(url=movie_payload["csfd_url"]).prefetch_related(
            "genres",
            "person_in_films__persons",
        )
        self.assertEqual(film.rating, 0.9)
        self.assertEqual({genre.name for genre in film.genres}, {"Thriller", "Krimi"})
        self.assertEqual(
            {
                (link.persons.url, link.role)
                for link in film.person_in_films
            },
            {
                ("https://www.csfd.sk/tvorca/40-reziser-opakovania/", "director"),
                ("https://www.csfd.sk/tvorca/50-prvy-herec/", "actor"),
                ("https://www.csfd.sk/tvorca/60-druhy-herec/", "actor"),
            },
        )

    async def test_03_actor_projection_endpoint_returns_graph_metrics(self) -> None:
        await _persist_films(
            [
                {
                    "title": "Spolocny film 1",
                    "year": 2020,
                    "actors": ["100-anna-uzol", "101-boris-uzol"],
                    "directors": [],
                    "genres": ["Drama"],
                    "country": "Slovensko",
                    "csfd_url": "https://www.csfd.sk/film/301-spolocny-film-1/prehlad/",
                },
                {
                    "title": "Spolocny film 2",
                    "year": 2021,
                    "actors": ["101-boris-uzol", "102-cyril-uzol"],
                    "directors": [],
                    "genres": ["Drama"],
                    "country": "Slovensko",
                    "csfd_url": "https://www.csfd.sk/film/302-spolocny-film-2/prehlad/",
                },
                {
                    "title": "Spolocny film 3",
                    "year": 2022,
                    "actors": ["100-anna-uzol", "102-cyril-uzol"],
                    "directors": [],
                    "genres": ["Drama"],
                    "country": "Slovensko",
                    "csfd_url": "https://www.csfd.sk/film/303-spolocny-film-3/prehlad/",
                },
            ]
        )

        response = await analytics_actor_projection(
            max_diameter_nodes=10,
            max_cast_size=10,
            top_core_actors=10,
            min_core_actor_degree=1,
            source="csfd",
        )

        self.assertEqual(response.movie_count, 3)
        self.assertEqual(response.stats.node_count, 3)
        self.assertEqual(response.stats.edge_count, 3)
        self.assertEqual(response.largest_component_count, 3)
        self.assertEqual(response.path.diameter, 1)
        self.assertAlmostEqual(response.stats.density, 1.0)
        self.assertAlmostEqual(response.stats.average_degree, 2.0)
        self.assertAlmostEqual(response.clustering.average_clustering, 1.0)
        self.assertEqual(response.core.max_core_number, 2)
        self.assertEqual({edge.weight for edge in response.graph_edges}, {1})
        self.assertEqual({node.value for node in response.graph_nodes}, {2.0})


if __name__ == "__main__":
    unittest.main()
