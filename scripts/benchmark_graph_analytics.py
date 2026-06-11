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
        default=10,
        help="Forwarded to the actor-projection analytics endpoint.",
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

    settings.ANALYTICS_CACHE_TTL_SECONDS = 0
    results: list[BenchmarkResult] = []

    for size in sizes:
        for run in range(1, runs + 1):
            result = await run_benchmark(
                films=size,
                run=run,
                database_url=args.database_url,
                max_cast_size=max(2, args.max_cast_size),
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
) -> BenchmarkResult:
    await Tortoise.init(db_url=database_url, modules={"models": settings.TORTOISE_MODELS})
    await Tortoise.generate_schemas()
    try:
        payloads = generate_movies(films)

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


def generate_movies(count: int) -> list[dict]:
    return [
        {
            "title": f"Benchmark film {index}",
            "year": 2000 + (index % 25),
            "rating": round(0.5 + ((index % 50) / 100), 2),
            "actors": [
                f"{100000 + index}-benchmark-actor-{index}",
                f"{100001 + index}-benchmark-actor-{index + 1}",
            ],
            "directors": [f"{200000 + index}-benchmark-director-{index}"],
            "genres": ["Drama" if index % 2 == 0 else "Thriller"],
            "country": "Slovensko" if index % 2 == 0 else "Cesko",
            "csfd_url": f"https://www.csfd.sk/film/{300000 + index}-benchmark-film-{index}/prehlad/",
        }
        for index in range(count)
    ]


def print_result(result: BenchmarkResult) -> None:
    print(
        "size={films} run={run} films_saved={saved} people={people} relations={relations} "
        "nodes={nodes} edges={edges} persist={persist:.4f}s analysis={analysis:.4f}s "
        "films_per_second={rate:.2f}".format(
            films=result.films_requested,
            run=result.run,
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
    print("| Films | Runs | Avg persist (s) | Avg analysis (s) | Avg films/s | Avg nodes | Avg edges |")
    print("|---:|---:|---:|---:|---:|---:|---:|")
    for size in sorted({result.films_requested for result in results}):
        group = [result for result in results if result.films_requested == size]
        print(
            "| {films} | {runs} | {persist:.4f} | {analysis:.4f} | {rate:.2f} | {nodes:.1f} | {edges:.1f} |".format(
                films=size,
                runs=len(group),
                persist=statistics.mean(result.persist_seconds for result in group),
                analysis=statistics.mean(result.analysis_seconds for result in group),
                rate=statistics.mean(result.films_per_second for result in group),
                nodes=statistics.mean(result.graph_nodes for result in group),
                edges=statistics.mean(result.graph_edges for result in group),
            )
        )


if __name__ == "__main__":
    asyncio.run(main())
