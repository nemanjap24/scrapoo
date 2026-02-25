from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from itertools import combinations
from typing import Dict, Iterable, List, Tuple

import networkx as nx

from app.models import Person, PersonInFilm


@dataclass
class CollaborationStats:
    node_count: int
    edge_count: int
    density: float
    average_degree: float


@dataclass
class NodeMetric:
    person_id: int
    name: str | None
    occupation: str | None
    value: float


@dataclass
class EdgeMetric:
    source_id: int
    source_name: str | None
    target_id: int
    target_name: str | None
    weight: int


@dataclass
class CollaborationAnalyticsResult:
    stats: CollaborationStats
    centrality: List[NodeMetric]
    collaborations: List[EdgeMetric]


async def compute_collaboration_metrics(
    *,
    limit_nodes: int = 10,
    limit_edges: int = 10,
    min_shared_films: int = 1,
) -> CollaborationAnalyticsResult:
    """Build a person collaboration graph and emit summary metrics."""

    limit_nodes = max(1, limit_nodes)
    limit_edges = max(1, limit_edges)
    min_shared_films = max(1, min_shared_films)

    film_members = await _load_film_memberships()
    if not film_members:
        empty_stats = CollaborationStats(node_count=0, edge_count=0, density=0.0, average_degree=0.0)
        return CollaborationAnalyticsResult(stats=empty_stats, centrality=[], collaborations=[])

    graph = nx.Graph()
    person_ids = {person_id for members in film_members.values() for person_id in members}
    graph.add_nodes_from(person_ids)

    for members in film_members.values():
        unique_members = list(dict.fromkeys(members))
        if len(unique_members) < 2:
            continue
        for a_id, b_id in combinations(sorted(unique_members), 2):
            if graph.has_edge(a_id, b_id):
                graph[a_id][b_id]["weight"] += 1
            else:
                graph.add_edge(a_id, b_id, weight=1)

    stats = _compute_graph_stats(graph)
    if graph.number_of_edges() == 0:
        result = CollaborationAnalyticsResult(stats=stats, centrality=[], collaborations=[])
        return result

    person_meta = await _load_person_meta(graph.nodes)
    centrality_metrics = _compute_top_centrality(graph, person_meta, limit_nodes)
    collaboration_metrics = _compute_top_edges(graph, person_meta, limit_edges, min_shared_films)

    return CollaborationAnalyticsResult(
        stats=stats,
        centrality=centrality_metrics,
        collaborations=collaboration_metrics,
    )


async def _load_film_memberships() -> Dict[int, List[int]]:
    memberships = defaultdict(list)
    rows = await PersonInFilm.all().values_list("films_id", "persons_id")
    for film_id, person_id in rows:
        if film_id is None or person_id is None:
            continue
        memberships[int(film_id)].append(int(person_id))
    return memberships


async def _load_person_meta(person_ids: Iterable[int]) -> Dict[int, Tuple[str | None, str | None]]:
    ids = list({int(pid) for pid in person_ids})
    if not ids:
        return {}
    people = await Person.filter(id__in=ids).values_list("id", "name", "occupation")
    return {int(pid): (name, occupation) for pid, name, occupation in people}


def _compute_graph_stats(graph: nx.Graph) -> CollaborationStats:
    node_count = graph.number_of_nodes()
    edge_count = graph.number_of_edges()
    density = float(nx.density(graph)) if node_count > 1 else 0.0
    degree_values = [degree for _, degree in graph.degree()]
    average_degree = (sum(degree_values) / node_count) if node_count else 0.0
    return CollaborationStats(
        node_count=node_count,
        edge_count=edge_count,
        density=density,
        average_degree=average_degree,
    )


def _compute_top_centrality(
    graph: nx.Graph,
    person_meta: Dict[int, Tuple[str | None, str | None]],
    limit_nodes: int,
) -> List[NodeMetric]:
    if graph.number_of_nodes() == 0:
        return []
    centrality_scores = nx.degree_centrality(graph)
    ranked = sorted(
        centrality_scores.items(),
        key=lambda item: (-item[1], _safe_name(person_meta.get(int(item[0]))), int(item[0])),
    )
    top_ranked = ranked[:limit_nodes]
    metrics: List[NodeMetric] = []
    for person_id, value in top_ranked:
        name, occupation = person_meta.get(int(person_id), (None, None))
        metrics.append(
            NodeMetric(
                person_id=int(person_id),
                name=name,
                occupation=occupation,
                value=float(value),
            )
        )
    return metrics


def _compute_top_edges(
    graph: nx.Graph,
    person_meta: Dict[int, Tuple[str | None, str | None]],
    limit_edges: int,
    min_shared_films: int,
) -> List[EdgeMetric]:
    edges: List[Tuple[int, int, int]] = []
    for a_id, b_id, data in graph.edges(data=True):
        weight = int(data.get("weight", 0))
        if weight < min_shared_films:
            continue
        edges.append((int(a_id), int(b_id), weight))
    if not edges:
        return []
    ranked = sorted(
        edges,
        key=lambda item: (-item[2], _safe_name(person_meta.get(item[0])), _safe_name(person_meta.get(item[1]))),
    )
    top_edges = ranked[:limit_edges]
    metrics: List[EdgeMetric] = []
    for source_id, target_id, weight in top_edges:
        source_meta = person_meta.get(source_id, (None, None))
        target_meta = person_meta.get(target_id, (None, None))
        metrics.append(
            EdgeMetric(
                source_id=source_id,
                source_name=source_meta[0],
                target_id=target_id,
                target_name=target_meta[0],
                weight=weight,
            )
        )
    return metrics


def _safe_name(meta: Tuple[str | None, str | None] | None) -> str:
    if not meta or not meta[0]:
        return ""
    return meta[0].lower()
