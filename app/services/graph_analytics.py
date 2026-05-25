from __future__ import annotations

from collections import Counter, defaultdict
from dataclasses import dataclass
from itertools import combinations
from math import log
from typing import Dict, Iterable, List, Tuple

import networkx as nx
import numpy as np

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


@dataclass
class DegreeBucket:
    degree: int
    count: int


@dataclass
class ClusteringMetric:
    average_clustering: float
    transitivity: float


@dataclass
class PathMetric:
    largest_component_nodes: int
    largest_component_share: float
    average_shortest_path_length: float | None
    diameter: int | None
    log_node_count: float | None
    average_path_to_log_ratio: float | None
    sampled: bool


@dataclass
class CoreMetric:
    max_core_number: int
    core_size_by_k: List[DegreeBucket]
    top_actors: List[NodeMetric]


@dataclass
class PowerLawMetric:
    alpha: float | None
    xmin: int | None
    r_squared: float | None
    degree_distribution: List[DegreeBucket]


@dataclass
class GraphAnalysisResult:
    stats: CollaborationStats
    movie_count: int
    largest_component_count: int
    power_law: PowerLawMetric
    clustering: ClusteringMetric
    path: PathMetric
    core: CoreMetric


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


async def compute_actor_projection_analysis(
    *,
    max_diameter_nodes: int = 1000,
    max_cast_size: int = 30,
    top_core_actors: int = 25,
    min_core_actor_degree: int = 1,
) -> GraphAnalysisResult:
    """Analyze the actor projection graph: actors are linked when they share a film."""

    max_diameter_nodes = max(2, max_diameter_nodes)
    max_cast_size = max(2, max_cast_size)
    top_core_actors = max(1, top_core_actors)
    min_core_actor_degree = max(0, min_core_actor_degree)

    film_members = await _load_film_memberships(role="actor")
    film_members = {
        film_id: members
        for film_id, members in film_members.items()
        if 2 <= len(set(members)) <= max_cast_size
    }
    graph = _build_projection_graph(film_members)
    stats = _compute_graph_stats(graph)
    largest_components = sorted(nx.connected_components(graph), key=len, reverse=True) if graph else []
    largest_component_count = len(largest_components[0]) if largest_components else 0

    if graph.number_of_nodes() == 0:
        return GraphAnalysisResult(
            stats=stats,
            movie_count=0,
            largest_component_count=0,
            power_law=PowerLawMetric(alpha=None, xmin=None, r_squared=None, degree_distribution=[]),
            clustering=ClusteringMetric(average_clustering=0.0, transitivity=0.0),
            path=PathMetric(
                largest_component_nodes=0,
                largest_component_share=0.0,
                average_shortest_path_length=None,
                diameter=None,
                log_node_count=None,
                average_path_to_log_ratio=None,
                sampled=False,
            ),
            core=CoreMetric(max_core_number=0, core_size_by_k=[], top_actors=[]),
        )

    person_meta = await _load_person_meta(graph.nodes)
    return GraphAnalysisResult(
        stats=stats,
        movie_count=len(film_members),
        largest_component_count=largest_component_count,
        power_law=_compute_power_law_metric(graph),
        clustering=_compute_clustering_metric(graph),
        path=_compute_path_metric(graph, max_diameter_nodes=max_diameter_nodes),
        core=_compute_core_metric(
            graph,
            person_meta,
            limit=top_core_actors,
            min_degree=min_core_actor_degree,
        ),
    )


async def _load_film_memberships(role: str | None = None) -> Dict[int, List[int]]:
    memberships = defaultdict(list)
    query = PersonInFilm.all()
    if role:
        query = query.filter(role__iexact=role)
    rows = await query.values_list("films_id", "persons_id")
    for film_id, person_id in rows:
        if film_id is None or person_id is None:
            continue
        memberships[int(film_id)].append(int(person_id))
    return memberships


def _build_projection_graph(film_members: Dict[int, List[int]]) -> nx.Graph:
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
    return graph


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


def _compute_power_law_metric(graph: nx.Graph) -> PowerLawMetric:
    degrees = [degree for _, degree in graph.degree() if degree > 0]
    distribution = [
        DegreeBucket(degree=int(degree), count=int(count))
        for degree, count in sorted(Counter(degrees).items())
    ]
    if len(distribution) < 2:
        return PowerLawMetric(alpha=None, xmin=None, r_squared=None, degree_distribution=distribution)

    xmin = max(1, int(np.percentile(degrees, 50)))
    tail = np.array([degree for degree in degrees if degree >= xmin], dtype=float)
    if len(tail) < 2 or xmin <= 0:
        return PowerLawMetric(alpha=None, xmin=xmin, r_squared=None, degree_distribution=distribution)

    # Continuous MLE approximation for the tail exponent. Good enough for a dashboard signal;
    # rigorous power-law testing would need a dedicated fitting package.
    denominator = float(np.sum(np.log(tail / xmin)))
    alpha = 1.0 + (len(tail) / denominator) if denominator > 0 else None

    xs = np.array([bucket.degree for bucket in distribution if bucket.degree >= xmin], dtype=float)
    ys = np.array([bucket.count for bucket in distribution if bucket.degree >= xmin], dtype=float)
    r_squared = None
    if len(xs) >= 2 and np.all(xs > 0) and np.all(ys > 0):
        log_x = np.log(xs)
        log_y = np.log(ys)
        slope, intercept = np.polyfit(log_x, log_y, 1)
        predictions = slope * log_x + intercept
        residual = float(np.sum((log_y - predictions) ** 2))
        total = float(np.sum((log_y - np.mean(log_y)) ** 2))
        r_squared = 1.0 - (residual / total) if total > 0 else None

    return PowerLawMetric(
        alpha=float(alpha) if alpha is not None else None,
        xmin=xmin,
        r_squared=float(r_squared) if r_squared is not None else None,
        degree_distribution=distribution,
    )


def _compute_clustering_metric(graph: nx.Graph) -> ClusteringMetric:
    if graph.number_of_nodes() == 0:
        return ClusteringMetric(average_clustering=0.0, transitivity=0.0)
    return ClusteringMetric(
        average_clustering=float(nx.average_clustering(graph)),
        transitivity=float(nx.transitivity(graph)),
    )


def _compute_path_metric(graph: nx.Graph, *, max_diameter_nodes: int) -> PathMetric:
    if graph.number_of_nodes() == 0:
        return PathMetric(0, 0.0, None, None, None, None, False)
    largest_nodes = max(nx.connected_components(graph), key=len)
    subgraph = graph.subgraph(largest_nodes)
    node_count = subgraph.number_of_nodes()
    if node_count < 2:
        return PathMetric(node_count, node_count / graph.number_of_nodes(), None, None, None, None, False)

    sampled = node_count > max_diameter_nodes
    if sampled:
        average_path = _sample_average_shortest_path_length(subgraph, sample_sources=25)
        diameter = None
    else:
        average_path = float(nx.average_shortest_path_length(subgraph))
        diameter = int(nx.diameter(subgraph))
    log_node_count = log(node_count)
    return PathMetric(
        largest_component_nodes=node_count,
        largest_component_share=node_count / graph.number_of_nodes(),
        average_shortest_path_length=average_path,
        diameter=diameter,
        log_node_count=log_node_count,
        average_path_to_log_ratio=(average_path / log_node_count) if log_node_count > 0 else None,
        sampled=sampled,
    )


def _sample_average_shortest_path_length(graph: nx.Graph, *, sample_sources: int) -> float:
    nodes = sorted(graph.nodes)
    if len(nodes) <= sample_sources:
        selected_nodes = nodes
    else:
        step = max(1, len(nodes) // sample_sources)
        selected_nodes = nodes[::step][:sample_sources]
    total_distance = 0
    pair_count = 0
    for node in selected_nodes:
        lengths = nx.single_source_shortest_path_length(graph, node)
        total_distance += sum(distance for target, distance in lengths.items() if target != node)
        pair_count += max(0, len(lengths) - 1)
    return (total_distance / pair_count) if pair_count else 0.0


def _compute_core_metric(
    graph: nx.Graph,
    person_meta: Dict[int, Tuple[str | None, str | None]],
    *,
    limit: int,
    min_degree: int,
) -> CoreMetric:
    if graph.number_of_nodes() == 0:
        return CoreMetric(max_core_number=0, core_size_by_k=[], top_actors=[])
    core_numbers = nx.core_number(graph) if graph.number_of_edges() else {node: 0 for node in graph.nodes}
    max_core = max(core_numbers.values()) if core_numbers else 0
    sizes = [
        DegreeBucket(degree=int(core), count=int(count))
        for core, count in sorted(Counter(core_numbers.values()).items())
    ]
    ranked = sorted(
        core_numbers.items(),
        key=lambda item: (-item[1], -graph.degree[item[0]], _safe_name(person_meta.get(int(item[0]))), int(item[0])),
    )
    top_actors: List[NodeMetric] = []
    for person_id, core_number in ranked:
        if graph.degree[person_id] < min_degree:
            continue
        name, occupation = person_meta.get(int(person_id), (None, None))
        top_actors.append(
            NodeMetric(
                person_id=int(person_id),
                name=name,
                occupation=occupation,
                value=float(core_number),
            )
        )
        if len(top_actors) >= limit:
            break
    return CoreMetric(max_core_number=int(max_core), core_size_by_k=sizes, top_actors=top_actors)


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
