#!/usr/bin/env python
from __future__ import annotations

import argparse
import asyncio
import statistics
import sys
from dataclasses import dataclass
from pathlib import Path
from time import perf_counter

from tortoise import Tortoise, connections

PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from app.api.routes.analytics import analytics_actor_projection
from app.core.config import settings
from app.models import Person, PersonInFilm
from app.tasks.scraping import _persist_films


@dataclass
class BenchmarkResult:
    films_requested: int
    run: int
    actors_per_film: float
    directors_per_film: int
    actor_strategy: str
    target_people: int | None
    films_saved: int
    people_count: int
    relation_count: int
    graph_nodes: int
    graph_edges: int
    persist_seconds: float
    analysis_seconds: float
    films_per_second: float


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Benchmark Scrapoo persistence and actor-projection graph analytics "
            "on synthetic datasets."
        )
    )
    parser.add_argument(
        "--sizes",
        nargs="+",
        type=int,
        default=[20, 100, 500],
        help="Dataset sizes measured as number of generated films.",
    )
    parser.add_argument(
        "--runs",
        type=int,
        default=3,
        help="How many times to repeat each dataset size.",
    )
    parser.add_argument(
        "--database-url",
        default="sqlite://:memory:",
        help=(
            "Benchmark database URL. Defaults to isolated in-memory SQLite. "
            "Use a disposable database only."
        ),
    )
    parser.add_argument(
        "--max-cast-size",
        type=int,
        default=500,
        help="Forwarded to the actor-projection analytics endpoint.",
    )
    parser.add_argument(
        "--actors-per-film",
        type=int,
        default=2,
        help="Number of synthetic actors generated for each film.",
    )
    parser.add_argument(
        "--directors-per-film",
        type=int,
        default=1,
        help="Number of synthetic directors generated for each film.",
    )
    parser.add_argument(
        "--actor-strategy",
        choices=["chain", "unique", "pool"],
        default="chain",
        help=(
            "Actor generation strategy. 'chain' reuses neighbouring actors, "
            "'unique' creates new actors for every film, and 'pool' reuses actors "
            "from a fixed pool."
        ),
    )
    parser.add_argument(
        "--actor-pool-size",
        type=int,
        default=1000,
        help="Number of actors reused when --actor-strategy=pool.",
    )
    parser.add_argument(
        "--target-people",
        type=int,
        default=None,
        help=(
            "Optional desired total number of people. Works with "
            "--actor-strategy=unique by distributing actors across films."
        ),
    )
    parser.add_argument(
        "--markdown",
        action="store_true",
        help="Print a compact Markdown summary table after raw run results.",
    )
    return parser.parse_args()


async def main() -> None:
    args = parse_args()
    sizes = [size for size in args.sizes if size > 0]
    runs = max(1, args.runs)

    if not sizes:
        raise SystemExit("At least one positive dataset size is required.")
    if args.target_people is not None and args.actor_strategy != "unique":
        raise SystemExit("--target-people requires --actor-strategy unique.")

    settings.ANALYTICS_CACHE_TTL_SECONDS = 0
    results: list[BenchmarkResult] = []

    for size in sizes:
        for run in range(1, runs + 1):
            result = await run_benchmark(
                films=size,
                run=run,
                database_url=args.database_url,
                max_cast_size=max(2, args.max_cast_size),
                actors_per_film=max(1, args.actors_per_film),
                directors_per_film=max(0, args.directors_per_film),
                actor_strategy=args.actor_strategy,
                actor_pool_size=max(1, args.actor_pool_size),
                target_people=args.target_people,
            )
            results.append(result)
            print_result(result)

    if args.markdown:
        print()
        print_markdown_summary(results)


async def run_benchmark(
    *,
    films: int,
    run: int,
    database_url: str,
    max_cast_size: int,
    actors_per_film: int,
    directors_per_film: int,
    actor_strategy: str,
    actor_pool_size: int,
    target_people: int | None,
) -> BenchmarkResult:
    await Tortoise.init(db_url=database_url, modules={"models": settings.TORTOISE_MODELS})
    await Tortoise.generate_schemas()
    try:
        actor_counts = build_actor_counts(
            films,
            actors_per_film=actors_per_film,
            directors_per_film=directors_per_film,
            target_people=target_people,
        )
        payloads = generate_movies(
            films,
            actor_counts=actor_counts,
            directors_per_film=directors_per_film,
            actor_strategy=actor_strategy,
            actor_pool_size=actor_pool_size,
        )

        persist_started = perf_counter()
        films_saved = await _persist_films(payloads)
        persist_seconds = perf_counter() - persist_started

        analysis_started = perf_counter()
        analytics = await analytics_actor_projection(
            max_diameter_nodes=max(50, films * 2),
            max_cast_size=max_cast_size,
            top_core_actors=25,
            min_core_actor_degree=1,
            source="csfd",
        )
        analysis_seconds = perf_counter() - analysis_started

        people_count = await Person.all().count()
        relation_count = await PersonInFilm.all().count()

        return BenchmarkResult(
            films_requested=films,
            run=run,
            actors_per_film=statistics.mean(actor_counts),
            directors_per_film=directors_per_film,
            actor_strategy=actor_strategy,
            target_people=target_people,
            films_saved=films_saved,
            people_count=people_count,
            relation_count=relation_count,
            graph_nodes=analytics.stats.node_count,
            graph_edges=analytics.stats.edge_count,
            persist_seconds=persist_seconds,
            analysis_seconds=analysis_seconds,
            films_per_second=films_saved / max(0.001, persist_seconds),
        )
    finally:
        await connections.close_all(discard=True)


def generate_movies(
    count: int,
    *,
    actor_counts: list[int],
    directors_per_film: int,
    actor_strategy: str,
    actor_pool_size: int,
) -> list[dict]:
    movies: list[dict] = []
    actor_offset = 0
    for index in range(count):
        actors_per_film = actor_counts[index]
        movies.append(
            {
                "title": f"Benchmark film {index}",
                "year": 2000 + (index % 25),
                "rating": round(0.5 + ((index % 50) / 100), 2),
                "actors": generate_actor_slugs(
                    index,
                    actors_per_film=actors_per_film,
                    actor_strategy=actor_strategy,
                    actor_pool_size=actor_pool_size,
                    actor_offset=actor_offset,
                ),
                "directors": [
                    f"{200000000 + (index * max(1, directors_per_film)) + director_index}"
                    f"-benchmark-director-{index}-{director_index}"
                    for director_index in range(directors_per_film)
                ],
                "genres": ["Drama" if index % 2 == 0 else "Thriller"],
                "country": "Slovensko" if index % 2 == 0 else "Cesko",
                "csfd_url": f"https://www.csfd.sk/film/{300000 + index}-benchmark-film-{index}/prehlad/",
            }
        )
        actor_offset += actors_per_film
    return movies


def build_actor_counts(
    films: int,
    *,
    actors_per_film: int,
    directors_per_film: int,
    target_people: int | None,
) -> list[int]:
    if target_people is None:
        return [actors_per_film for _ in range(films)]

    director_total = films * directors_per_film
    actor_total = target_people - director_total
    if actor_total < films:
        raise SystemExit(
            "--target-people is too low for the selected film and director counts; "
            "at least one actor per film is required."
        )
    base_count, extra_count = divmod(actor_total, films)
    return [
        base_count + (1 if index < extra_count else 0)
        for index in range(films)
    ]


def generate_actor_slugs(
    film_index: int,
    *,
    actors_per_film: int,
    actor_strategy: str,
    actor_pool_size: int,
    actor_offset: int,
) -> list[str]:
    if actor_strategy == "unique":
        actor_ids = [
            100000000 + actor_offset + actor_index
            for actor_index in range(actors_per_film)
        ]
    elif actor_strategy == "pool":
        actor_ids = [
            100000000 + ((film_index * actors_per_film) + actor_index) % actor_pool_size
            for actor_index in range(actors_per_film)
        ]
    else:
        actor_ids = [
            100000000 + film_index + actor_index
            for actor_index in range(actors_per_film)
        ]
    return [
        f"{actor_id}-benchmark-actor-{actor_id}"
        for actor_id in actor_ids
    ]


def print_result(result: BenchmarkResult) -> None:
    print(
        "size={films} run={run} avg_actors_per_film={actors:.2f} directors_per_film={directors} "
        "actor_strategy={strategy} target_people={target} films_saved={saved} "
        "people={people} relations={relations} "
        "nodes={nodes} edges={edges} persist={persist:.4f}s analysis={analysis:.4f}s "
        "films_per_second={rate:.2f}".format(
            films=result.films_requested,
            run=result.run,
            actors=result.actors_per_film,
            directors=result.directors_per_film,
            strategy=result.actor_strategy,
            target=result.target_people or "",
            saved=result.films_saved,
            people=result.people_count,
            relations=result.relation_count,
            nodes=result.graph_nodes,
            edges=result.graph_edges,
            persist=result.persist_seconds,
            analysis=result.analysis_seconds,
            rate=result.films_per_second,
        )
    )


def print_markdown_summary(results: list[BenchmarkResult]) -> None:
    print(
        "| Films | Runs | Avg actors/film | Directors/film | Strategy | Target people | Avg people | Avg relations | "
        "Avg persist (s) | Avg analysis (s) | Avg films/s | Avg nodes | Avg edges |"
    )
    print("|---:|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|")
    for size in sorted({result.films_requested for result in results}):
        group = [result for result in results if result.films_requested == size]
        print(
            "| {films} | {runs} | {actors:.2f} | {directors} | {strategy} | {target} | {people:.1f} | {relations:.1f} | "
            "{persist:.4f} | {analysis:.4f} | {rate:.2f} | {nodes:.1f} | {edges:.1f} |".format(
                films=size,
                runs=len(group),
                actors=group[0].actors_per_film,
                directors=group[0].directors_per_film,
                strategy=group[0].actor_strategy,
                target=group[0].target_people or "",
                people=statistics.mean(result.people_count for result in group),
                relations=statistics.mean(result.relation_count for result in group),
                persist=statistics.mean(result.persist_seconds for result in group),
                analysis=statistics.mean(result.analysis_seconds for result in group),
                rate=statistics.mean(result.films_per_second for result in group),
                nodes=statistics.mean(result.graph_nodes for result in group),
                edges=statistics.mean(result.graph_edges for result in group),
            )
        )


if __name__ == "__main__":
    asyncio.run(main())
