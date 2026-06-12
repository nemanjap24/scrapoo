from __future__ import annotations

import unittest
from collections.abc import Iterable

from tortoise import Tortoise, connections

from app.core.config import settings
from app.models import Film, Person, PersonInFilm
from app.services.graph_analytics import GraphAnalysisResult, compute_actor_projection_analysis


class TestGraphAnalyticsControlledDatasets(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self) -> None:
        await Tortoise.init(db_url="sqlite://:memory:", modules={"models": settings.TORTOISE_MODELS})
        await Tortoise.generate_schemas()

    async def asyncTearDown(self) -> None:
        await connections.close_all(discard=True)

    async def test_three_actor_path_graph_metrics(self) -> None:
        await _create_actor_edges([("A", "B"), ("B", "C")])
        result = await _analyze()

        self.assertEqual(result.movie_count, 2)
        self.assert_graph_summary(
            result,
            nodes=3,
            edges=2,
            density=2 / 3,
            average_degree=4 / 3,
            largest_component=3,
            average_clustering=0.0,
            transitivity=0.0,
            max_core_number=1,
            diameter=2,
            average_path=4 / 3,
        )
        self.assertEqual(_edge_weights(result), [1, 1])

    async def test_two_triangles_sharing_edge_graph_metrics(self) -> None:
        await _create_actor_films(
            [
                ("Film ABC", ["A", "B", "C"]),
                ("Film BCD", ["B", "C", "D"]),
            ]
        )
        result = await _analyze()

        self.assertEqual(result.movie_count, 2)
        self.assert_graph_summary(
            result,
            nodes=4,
            edges=5,
            density=5 / 6,
            average_degree=5 / 2,
            largest_component=4,
            average_clustering=5 / 6,
            transitivity=3 / 4,
            max_core_number=2,
            diameter=2,
            average_path=7 / 6,
        )
        self.assertEqual(_edge_weights(result), [1, 1, 1, 1, 2])

    async def test_c5_cycle_graph_metrics(self) -> None:
        await _create_actor_edges(
            [
                ("A", "B"),
                ("B", "C"),
                ("C", "D"),
                ("D", "E"),
                ("E", "A"),
            ]
        )
        result = await _analyze()

        self.assertEqual(result.movie_count, 5)
        self.assert_graph_summary(
            result,
            nodes=5,
            edges=5,
            density=1 / 2,
            average_degree=2.0,
            largest_component=5,
            average_clustering=0.0,
            transitivity=0.0,
            max_core_number=2,
            diameter=2,
            average_path=3 / 2,
        )
        self.assertEqual(_edge_weights(result), [1, 1, 1, 1, 1])

    async def test_k5_complete_graph_metrics(self) -> None:
        await _create_actor_films([("Film ABCDE", ["A", "B", "C", "D", "E"])])
        result = await _analyze()

        self.assertEqual(result.movie_count, 1)
        self.assert_graph_summary(
            result,
            nodes=5,
            edges=10,
            density=1.0,
            average_degree=4.0,
            largest_component=5,
            average_clustering=1.0,
            transitivity=1.0,
            max_core_number=4,
            diameter=1,
            average_path=1.0,
        )
        self.assertEqual(_edge_weights(result), [1] * 10)

    async def test_k23_complete_bipartite_graph_metrics(self) -> None:
        await _create_actor_edges(
            [
                ("A", "C"),
                ("A", "D"),
                ("A", "E"),
                ("B", "C"),
                ("B", "D"),
                ("B", "E"),
            ]
        )
        result = await _analyze()

        self.assertEqual(result.movie_count, 6)
        self.assert_graph_summary(
            result,
            nodes=5,
            edges=6,
            density=3 / 5,
            average_degree=12 / 5,
            largest_component=5,
            average_clustering=0.0,
            transitivity=0.0,
            max_core_number=2,
            diameter=2,
            average_path=7 / 5,
        )
        self.assertEqual(_edge_weights(result), [1] * 6)

    def assert_graph_summary(
        self,
        result: GraphAnalysisResult,
        *,
        nodes: int,
        edges: int,
        density: float,
        average_degree: float,
        largest_component: int,
        average_clustering: float,
        transitivity: float,
        max_core_number: int,
        diameter: int | None,
        average_path: float | None,
    ) -> None:
        self.assertEqual(result.stats.node_count, nodes)
        self.assertEqual(result.stats.edge_count, edges)
        self.assertAlmostEqual(result.stats.density, density)
        self.assertAlmostEqual(result.stats.average_degree, average_degree)
        self.assertEqual(result.largest_component_count, largest_component)
        self.assertAlmostEqual(result.clustering.average_clustering, average_clustering)
        self.assertAlmostEqual(result.clustering.transitivity, transitivity)
        self.assertEqual(result.core.max_core_number, max_core_number)
        self.assertEqual(result.path.diameter, diameter)
        if average_path is None:
            self.assertIsNone(result.path.average_shortest_path_length)
        else:
            self.assertAlmostEqual(result.path.average_shortest_path_length, average_path)


async def _analyze() -> GraphAnalysisResult:
    return await compute_actor_projection_analysis(
        max_diameter_nodes=10,
        max_cast_size=10,
        top_core_actors=10,
        min_core_actor_degree=0,
    )


async def _create_actor_films(films: Iterable[tuple[str, list[str]]]) -> None:
    people_by_key: dict[str, Person] = {}
    for title, actor_keys in films:
        film = await Film.create(title=title, release_year=2026)
        for actor_key in actor_keys:
            person = people_by_key.get(actor_key)
            if person is None:
                person = await Person.create(
                    name=f"Actor {actor_key}",
                    url=f"https://example.test/person/{actor_key.lower()}",
                    occupation="actor",
                )
                people_by_key[actor_key] = person
            await PersonInFilm.create(films=film, persons=person, role="actor")


async def _create_actor_edges(edges: Iterable[tuple[str, str]]) -> None:
    films = [
        (f"Film {source}{target}", [source, target])
        for source, target in edges
    ]
    await _create_actor_films(films)


def _edge_weights(result: GraphAnalysisResult) -> list[int]:
    return sorted(edge.weight for edge in result.graph_edges)


if __name__ == "__main__":
    unittest.main()
