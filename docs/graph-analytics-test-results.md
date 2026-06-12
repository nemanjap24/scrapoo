# Testovanie grafovych analyz

## Umiestnenie implementacie

Grafova analytika je implementovana v `app/services/graph_analytics.py`.
Najdolezitejsie funkcie su:

- `compute_actor_projection_analysis()` - hlavna analyza hereckej projekcie grafu,
- `compute_collaboration_metrics()` - jednoduchsia metrika spoluprace osob,
- `_load_film_memberships()` - nacitanie vztahov film-osoba z ORM,
- `_build_projection_graph()` - konstrukcia neorientovaneho vazeneho grafu,
- `_compute_graph_stats()` - pocet uzlov, hran, hustota a priemerny stupen,
- `_compute_clustering_metric()` - priemerne zhlukovanie a tranzitivita,
- `_compute_path_metric()` - metriky najvacsej komponenty, priemerna cesta a diameter,
- `_compute_core_metric()` - core number.

API endpointy su v `app/api/routes/analytics.py`:

- `GET /api/v1/analytics/network/collaboration`,
- `GET /api/v1/analytics/network/actor-projection`.

Dashboard vola rovnake endpointy v `dashboard/streamlit_app.py`, hlavne vo funkciach
`render_network()` a `render_graph_analysis()`.

## Testovaci plan

Testovanie pouziva male kontrolovane datasety vytvarane cez Tortoise ORM v izolovanej
SQLite databaze v pamati. Testy su v `app/tests/test_graph_analytics_controlled_datasets.py`.
Kazdy scenar vytvori filmy, hercov a vztahy `PersonInFilm` s rolou `actor`, nasledne zavola
`compute_actor_projection_analysis()`.

Overovane metriky:

- pocet uzlov,
- pocet hran,
- hustota grafu,
- priemerny stupen,
- velkost najvacsej komponenty,
- priemerne zhlukovanie,
- tranzitivita,
- diameter najvacsej komponenty,
- priemerna najkratsia cesta v najvacsej komponente,
- maximalny core number,
- vaha hrany pri opakovanej spolupraci.

## Ocakavane vysledky

| Scenar | Filmy a obsadenie | Uzly | Hrany | Hustota | Priemerny stupen | Najvacsia komponenta | Clustering | Tranzitivita | Diameter | Priemerna cesta | Max core | Vahy hran |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Cesta troch hercov P3 | AB, BC | 3 | 2 | 2/3 | 4/3 | 3 | 0 | 0 | 2 | 4/3 | 1 | [1, 1] |
| Dva trojuholniky spojene hranou | ABC, BCD | 4 | 5 | 5/6 | 5/2 | 4 | 5/6 | 3/4 | 2 | 7/6 | 2 | [1, 1, 1, 1, 2] |
| Cyklus C5 | AB, BC, CD, DE, EA | 5 | 5 | 1/2 | 2 | 5 | 0 | 0 | 2 | 3/2 | 2 | [1, 1, 1, 1, 1] |
| Kompletny graf K5 | ABCDE | 5 | 10 | 1 | 4 | 5 | 1 | 1 | 1 | 1 | 4 | 10x [1] |
| Kompletny bipartitny graf K2,3 | AC, AD, AE, BC, BD, BE | 5 | 6 | 3/5 | 12/5 | 5 | 0 | 0 | 2 | 7/5 | 2 | 6x [1] |

## Spustenie

Samostatne grafove testy:

```bash
docker compose exec -T api python -m unittest app.tests.test_graph_analytics_controlled_datasets
```

Grafove testy spolu s existujucimi E2E testami:

```bash
docker compose exec -T api python -m unittest app.tests.test_graph_analytics_controlled_datasets app.tests.test_e2e_functional_requirements
```

Overeny vysledok:

```text
Ran 5 tests in 0.223s
OK

Ran 12 tests in 0.676s
OK
```
