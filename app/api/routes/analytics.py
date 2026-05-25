from __future__ import annotations

import asyncio
from collections import Counter
from typing import Sequence

from fastapi import APIRouter, Query
from tortoise.functions import Count

from app.models import Country, Film, Person
from app.schemas import (
    AnalyticsOverview,
    ActorProjectionAnalytics,
    CollaborationAnalytics,
    ClusteringAnalytics,
    CoreAnalytics,
    CountriesAnalytics,
    CountryShareStats,
    CountryStats,
    DegreeDistributionBucket,
    GraphEdgeMetric,
    GraphNodeMetric,
    GraphStats,
    PeopleAnalytics,
    PersonStats,
    PathAnalytics,
    PowerLawAnalytics,
    ReleaseAnalytics,
    ReleaseBucketStats,
    RolePeopleStats,
)
from app.services.graph_analytics import compute_actor_projection_analysis, compute_collaboration_metrics

router = APIRouter()


@router.get("/overview", response_model=AnalyticsOverview, summary="High-level scraping analytics")
async def analytics_overview(limit: int = Query(5, ge=1, le=20)) -> AnalyticsOverview:
    bounded_limit = max(1, min(limit, 20))
    total_films_task = Film.all().count()
    total_people_task = Person.all().count()
    top_actors_task = _top_people_by_role("actor", bounded_limit)
    top_directors_task = _top_people_by_role("director", bounded_limit)
    top_countries_task = _top_countries(bounded_limit)

    total_films, total_people, top_actors, top_directors, top_countries = await asyncio.gather(
        total_films_task,
        total_people_task,
        top_actors_task,
        top_directors_task,
        top_countries_task,
    )

    return AnalyticsOverview(
        total_films=total_films,
        total_people=total_people,
        top_actors=top_actors,
        top_directors=top_directors,
        prolific_countries=top_countries,
    )


@router.get(
    "/people",
    response_model=PeopleAnalytics,
    summary="Role-based person analytics",
)
async def analytics_people(
    roles: list[str] = Query(["actor", "director"], min_items=1, max_items=5),
    limit: int = Query(5, ge=1, le=30),
    min_films: int = Query(1, ge=1, le=100),
) -> PeopleAnalytics:
    bounded_limit = max(1, min(limit, 30))
    normalized_roles = _normalize_roles(roles)
    if not normalized_roles:
        normalized_roles = ["actor"]
    tasks = [_top_people_by_role(role, bounded_limit, min_films=min_films) for role in normalized_roles]
    results = await asyncio.gather(*tasks)
    role_stats = [
        RolePeopleStats(role=role, people=stats)
        for role, stats in zip(normalized_roles, results)
        if stats
    ]
    return PeopleAnalytics(total_roles=len(role_stats), roles=role_stats)


@router.get(
    "/countries",
    response_model=CountriesAnalytics,
    summary="Film counts per country",
)
async def analytics_countries(limit: int = Query(10, ge=1, le=50)) -> CountriesAnalytics:
    bounded_limit = max(1, min(limit, 50))
    total_films_task = Film.all().count()
    total_countries_task = (
        Country.annotate(film_count=Count("films"))
        .filter(film_count__gt=0)
        .count()
    )
    top_countries_task = _top_countries(bounded_limit)
    total_films, total_countries, top_countries = await asyncio.gather(
        total_films_task,
        total_countries_task,
        top_countries_task,
    )
    breakdown = [
        CountryShareStats(
            id=country.id,
            name=country.name,
            film_count=country.film_count,
            film_share=(country.film_count / total_films) if total_films else 0.0,
        )
        for country in top_countries
    ]
    return CountriesAnalytics(
        total_countries=total_countries,
        total_films=total_films,
        countries=breakdown,
    )


@router.get(
    "/releases",
    response_model=ReleaseAnalytics,
    summary="Film release distribution",
)
async def analytics_releases(
    bucket: str = Query("decade", pattern="^(year|decade)$"),
    limit: int = Query(12, ge=1, le=120),
) -> ReleaseAnalytics:
    bucket_normalized = (bucket or "decade").lower()
    if bucket_normalized not in {"year", "decade"}:
        bucket_normalized = "decade"
    release_years = await Film.filter(release_year__not_isnull=True).values_list("release_year", flat=True)
    if not release_years:
        return ReleaseAnalytics(grouping=bucket_normalized, total_buckets=0, total_films=0, buckets=[])
    counter: Counter[str] = Counter()
    for value in release_years:
        try:
            year = int(value)
        except (TypeError, ValueError):
            continue
        if bucket_normalized == "decade":
            decade = (year // 10) * 10
            label = f"{decade}s"
        else:
            label = str(year)
        counter[label] += 1
    if not counter:
        return ReleaseAnalytics(grouping=bucket_normalized, total_buckets=0, total_films=0, buckets=[])
    sorted_buckets = sorted(counter.items(), key=lambda item: (-item[1], item[0]))
    bounded_limit = max(1, min(limit, 120))
    limited = sorted_buckets[:bounded_limit]
    buckets = [ReleaseBucketStats(label=label, film_count=count) for label, count in limited]
    return ReleaseAnalytics(
        grouping=bucket_normalized,
        total_buckets=len(counter),
        total_films=sum(counter.values()),
        buckets=buckets,
    )


@router.get(
    "/network/collaboration",
    response_model=CollaborationAnalytics,
    summary="Collaboration graph metrics",
)
async def analytics_network_collaboration(
    limit_nodes: int = Query(10, ge=1, le=50),
    limit_edges: int = Query(10, ge=1, le=50),
    min_shared_films: int = Query(2, ge=1, le=25),
) -> CollaborationAnalytics:
    result = await compute_collaboration_metrics(
        limit_nodes=limit_nodes,
        limit_edges=limit_edges,
        min_shared_films=min_shared_films,
    )
    stats = GraphStats(
        node_count=result.stats.node_count,
        edge_count=result.stats.edge_count,
        density=result.stats.density,
        average_degree=result.stats.average_degree,
    )
    top_nodes = [
        GraphNodeMetric(
            person_id=metric.person_id,
            name=metric.name,
            occupation=metric.occupation,
            value=metric.value,
        )
        for metric in result.centrality
    ]
    top_edges = [
        GraphEdgeMetric(
            source_id=metric.source_id,
            source_name=metric.source_name,
            target_id=metric.target_id,
            target_name=metric.target_name,
            weight=metric.weight,
        )
        for metric in result.collaborations
    ]
    return CollaborationAnalytics(
        stats=stats,
        top_centrality=top_nodes,
        top_collaborations=top_edges,
    )


@router.get(
    "/network/actor-projection",
    response_model=ActorProjectionAnalytics,
    summary="Actor projection graph analysis",
)
async def analytics_actor_projection(
    max_diameter_nodes: int = Query(1000, ge=2, le=5000),
    max_cast_size: int = Query(30, ge=2, le=500),
    top_core_actors: int = Query(25, ge=1, le=100),
    min_core_actor_degree: int = Query(1, ge=0, le=500),
) -> ActorProjectionAnalytics:
    result = await compute_actor_projection_analysis(
        max_diameter_nodes=max_diameter_nodes,
        max_cast_size=max_cast_size,
        top_core_actors=top_core_actors,
        min_core_actor_degree=min_core_actor_degree,
    )
    return ActorProjectionAnalytics(
        stats=GraphStats(
            node_count=result.stats.node_count,
            edge_count=result.stats.edge_count,
            density=result.stats.density,
            average_degree=result.stats.average_degree,
        ),
        movie_count=result.movie_count,
        largest_component_count=result.largest_component_count,
        power_law=PowerLawAnalytics(
            alpha=result.power_law.alpha,
            xmin=result.power_law.xmin,
            r_squared=result.power_law.r_squared,
            degree_distribution=[
                DegreeDistributionBucket(degree=bucket.degree, count=bucket.count)
                for bucket in result.power_law.degree_distribution
            ],
        ),
        clustering=ClusteringAnalytics(
            average_clustering=result.clustering.average_clustering,
            transitivity=result.clustering.transitivity,
        ),
        path=PathAnalytics(
            largest_component_nodes=result.path.largest_component_nodes,
            largest_component_share=result.path.largest_component_share,
            average_shortest_path_length=result.path.average_shortest_path_length,
            diameter=result.path.diameter,
            log_node_count=result.path.log_node_count,
            average_path_to_log_ratio=result.path.average_path_to_log_ratio,
            sampled=result.path.sampled,
        ),
        core=CoreAnalytics(
            max_core_number=result.core.max_core_number,
            core_size_by_k=[
                DegreeDistributionBucket(degree=bucket.degree, count=bucket.count)
                for bucket in result.core.core_size_by_k
            ],
            top_actors=[
                GraphNodeMetric(
                    person_id=actor.person_id,
                    name=actor.name,
                    occupation=actor.occupation,
                    value=actor.value,
                )
                for actor in result.core.top_actors
            ],
        ),
    )


async def _top_people_by_role(role: str, limit: int, *, min_films: int = 1) -> list[PersonStats]:
    role_normalized = role.lower()
    people = (
        await Person.filter(film_roles__role__iexact=role_normalized)
        .annotate(film_count=Count("film_roles"))
        .order_by("-film_count", "name")
        .limit(limit)
    )
    stats: list[PersonStats] = []
    for person in people:
        film_count = getattr(person, "film_count", 0) or 0
        if film_count < min_films:
            continue
        stats.append(
            PersonStats(
                id=person.id,
                name=person.name,
                occupation=person.occupation,
                film_count=film_count,
            )
        )
    return stats


async def _top_countries(limit: int, *, min_films: int = 1) -> list[CountryStats]:
    countries = (
        await Country.filter(films__id__not_isnull=True)
        .annotate(film_count=Count("films"))
        .order_by("-film_count", "name")
        .limit(limit)
    )
    stats: list[CountryStats] = []
    for country in countries:
        film_count = getattr(country, "film_count", 0) or 0
        if film_count < min_films:
            continue
        stats.append(
            CountryStats(
                id=country.id,
                name=country.name,
                film_count=film_count,
            )
        )
    return stats


def _normalize_roles(roles: Sequence[str] | None) -> list[str]:
    if not roles:
        return []
    seen: set[str] = set()
    normalized: list[str] = []
    for role in roles:
        cleaned = (role or "").strip().lower()
        if not cleaned or cleaned in seen:
            continue
        normalized.append(cleaned)
        seen.add(cleaned)
    return normalized
