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

    async def test_empty_graph_returns_zero_metrics(self) -> None:
        result = await _analyze()

        self.assertEqual(result.movie_count, 0)
        self.assertEqual(result.stats.node_count, 0)
        self.assertEqual(result.stats.edge_count, 0)
        self.assertEqual(result.stats.density, 0.0)
        self.assertEqual(result.stats.average_degree, 0.0)
        self.assertEqual(result.largest_component_count, 0)
        self.assertEqual(result.clustering.average_clustering, 0.0)
        self.assertEqual(result.clustering.transitivity, 0.0)
        self.assertEqual(result.core.max_core_number, 0)
        self.assertEqual(result.path.diameter, None)
        self.assertEqual(result.graph_nodes, [])
        self.assertEqual(result.graph_edges, [])

    async def test_single_edge_graph_metrics(self) -> None:
        await _create_actor_films([("Film AB", ["A", "B"])])
        result = await _analyze()

        self.assertEqual(result.movie_count, 1)
        self.assert_graph_summary(
            result,
            nodes=2,
            edges=1,
            density=1.0,
            average_degree=1.0,
            largest_component=2,
            average_clustering=0.0,
            transitivity=0.0,
            max_core_number=1,
            diameter=1,
            average_path=1.0,
        )
        self.assertEqual(_edge_weights(result), [1])

    async def test_three_actor_chain_graph_metrics(self) -> None:
        await _create_actor_films(
            [
                ("Film AB", ["A", "B"]),
                ("Film BC", ["B", "C"]),
            ]
        )
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

    async def test_triangle_graph_metrics(self) -> None:
        await _create_actor_films([("Film ABC", ["A", "B", "C"])])
        result = await _analyze()

        self.assertEqual(result.movie_count, 1)
        self.assert_graph_summary(
            result,
            nodes=3,
            edges=3,
            density=1.0,
            average_degree=2.0,
            largest_component=3,
            average_clustering=1.0,
            transitivity=1.0,
            max_core_number=2,
            diameter=1,
            average_path=1.0,
        )
        self.assertEqual(_edge_weights(result), [1, 1, 1])

    async def test_two_disconnected_components_graph_metrics(self) -> None:
        await _create_actor_films(
            [
                ("Film AB", ["A", "B"]),
                ("Film CD", ["C", "D"]),
            ]
        )
        result = await _analyze()

        self.assertEqual(result.movie_count, 2)
        self.assert_graph_summary(
            result,
            nodes=4,
            edges=2,
            density=1 / 3,
            average_degree=1.0,
            largest_component=2,
            average_clustering=0.0,
            transitivity=0.0,
            max_core_number=1,
            diameter=1,
            average_path=1.0,
        )
        self.assertAlmostEqual(result.path.largest_component_share, 0.5)
        self.assertEqual(_edge_weights(result), [1, 1])

    async def test_repeated_collaboration_builds_weighted_edge(self) -> None:
        await _create_actor_films(
            [
                ("Film AB 1", ["A", "B"]),
                ("Film AB 2", ["A", "B"]),
            ]
        )
        result = await _analyze()

        self.assertEqual(result.movie_count, 2)
        self.assert_graph_summary(
            result,
            nodes=2,
            edges=1,
            density=1.0,
            average_degree=1.0,
            largest_component=2,
            average_clustering=0.0,
            transitivity=0.0,
            max_core_number=1,
            diameter=1,
            average_path=1.0,
        )
        self.assertEqual(_edge_weights(result), [2])

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


def _edge_weights(result: GraphAnalysisResult) -> list[int]:
    return sorted(edge.weight for edge in result.graph_edges)


if __name__ == "__main__":
    unittest.main()
