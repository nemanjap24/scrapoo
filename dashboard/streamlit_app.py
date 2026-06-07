from __future__ import annotations

import os
import tempfile
from typing import Any, Dict, Optional

import httpx
import pandas as pd
import plotly.express as px
from pyvis.network import Network
import streamlit as st
from streamlit.components.v1 import html as components_html

API_BASE_URL = os.getenv("SCRAPOO_API_URL", "http://localhost:8000/api/v1")
DEFAULT_TIMEOUT = float(os.getenv("SCRAPOO_API_TIMEOUT", "30"))
DATA_SOURCES = {
    "CSFD": "csfd",
    "TMDB": "tmdb",
}


@st.cache_data(ttl=60)
def fetch_json(path: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    url = f"{API_BASE_URL}{path}"
    with httpx.Client(timeout=DEFAULT_TIMEOUT) as client:
        response = client.get(url, params=params or {})
        response.raise_for_status()
        return response.json()


def with_source(params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    selected = st.session_state.get("data_source", "csfd")
    merged = dict(params or {})
    merged["source"] = selected
    return merged


def render_overview() -> None:
    data = fetch_json("/analytics/overview", params=with_source({"limit": 10}))
    st.subheader("Collection Totals")
    cols = st.columns(2)
    cols[0].metric("Films", f"{data['total_films']:,}")
    cols[1].metric("People", f"{data['total_people']:,}")
    st.subheader("Top Directors")
    st.dataframe(pd.DataFrame(data["top_directors"]))
    st.subheader("Top Actors")
    st.dataframe(pd.DataFrame(data["top_actors"]))
    st.subheader("Prolific Countries")
    fig = px.bar(data["prolific_countries"], x="name", y="film_count", title="Films by Country")
    st.plotly_chart(fig, use_container_width=True)


def render_people() -> None:
    roles = st.multiselect("Roles", ["actor", "director"], default=["actor", "director"])
    limit = st.slider("Max people per role", min_value=5, max_value=30, value=10)
    min_films = st.slider("Minimum shared films", min_value=1, max_value=25, value=2)
    if not roles:
        st.info("Select at least one role to continue.")
        return
    params = {"roles": roles, "limit": limit, "min_films": min_films}
    data = fetch_json("/analytics/people", params=with_source(params))
    for role_stats in data.get("roles", []):
        st.subheader(f"{role_stats['role'].title()}s")
        df = pd.DataFrame(role_stats["people"])
        fig = px.bar(df, x="name", y="film_count", title=f"{role_stats['role'].title()} output")
        st.plotly_chart(fig, use_container_width=True)
        st.dataframe(df)


def render_countries() -> None:
    limit = st.slider("Countries to show", min_value=5, max_value=30, value=10)
    data = fetch_json("/analytics/countries", params=with_source({"limit": limit}))
    st.subheader("Country Share")
    df = pd.DataFrame(data["countries"])
    fig = px.pie(df, values="film_count", names="name", title="Film Share by Country")
    st.plotly_chart(fig, use_container_width=True)
    st.dataframe(df)


def render_releases() -> None:
    bucket = st.selectbox("Grouping", options=["decade", "year"], index=0)
    limit = st.slider("Buckets to show", min_value=5, max_value=40, value=12)
    data = fetch_json("/analytics/releases", params=with_source({"bucket": bucket, "limit": limit}))
    st.subheader("Release Distribution")
    df = pd.DataFrame(data["buckets"])
    fig = px.bar(df, x="label", y="film_count", title=f"Films per {bucket}")
    st.plotly_chart(fig, use_container_width=True)
    st.dataframe(df)


def _render_network_graph(nodes: list[Dict[str, Any]], edges: list[Dict[str, Any]]) -> None:
    if not nodes or not edges:
        st.info("Not enough data to visualize the network yet.")
        return
    net = Network(height="600px", width="100%", bgcolor="#0E1117", font_color="#FAFAFA")
    net.barnes_hut()
    present_nodes: dict[int, Dict[str, Any]] = {}
    for node in nodes:
        label = node.get("name") or f"Person {node['person_id']}"
        title_parts = [label]
        occupation = node.get("occupation")
        if occupation:
            title_parts.append(occupation)
        value = float(node.get("value", 0.0))
        title_parts.append(f"Centrality: {value:.3f}")
        net.add_node(
            node["person_id"],
            label=label,
            title=" | ".join(title_parts),
            value=max(value, 0.001),
        )
        present_nodes[int(node["person_id"])] = {
            "label": label,
            "occupation": occupation,
        }
    for edge in edges:
        source_label = edge.get("source_name") or f"Person {edge['source_id']}"
        target_label = edge.get("target_name") or f"Person {edge['target_id']}"
        for identifier, label in (
            (edge["source_id"], source_label),
            (edge["target_id"], target_label),
        ):
            if int(identifier) not in present_nodes:
                net.add_node(identifier, label=label, title=label, value=0.5)
                present_nodes[int(identifier)] = {"label": label, "occupation": None}
        net.add_edge(
            edge["source_id"],
            edge["target_id"],
            value=edge.get("weight", 1),
            title=f"{edge.get('weight', 1)} shared films: {source_label} ↔ {target_label}",
        )
    with tempfile.NamedTemporaryFile(mode="w+", suffix=".html", delete=False) as tmp_file:
        net.save_graph(tmp_file.name)
        tmp_file.seek(0)
        html_content = tmp_file.read()
    components_html(html_content, height=650, scrolling=True)
    os.unlink(tmp_file.name)


def _render_community_graph(communities: Dict[str, Any]) -> None:
    nodes = communities.get("nodes", [])
    edges = communities.get("edges", [])
    if not nodes:
        st.info("No actor communities to visualize yet.")
        return

    node_ids = {int(node["community_id"]) for node in nodes}
    net = Network(height="650px", width="100%", bgcolor="#0E1117", font_color="#FAFAFA")
    net.barnes_hut(gravity=-4500, central_gravity=0.25, spring_length=180, spring_strength=0.02)

    for node in nodes:
        community_id = int(node["community_id"])
        top_names = [
            actor.get("name") or f"Person {actor['person_id']}"
            for actor in node.get("top_actors", [])
        ]
        title_parts = [
            f"Community {community_id}",
            f"Actors: {int(node['actor_count']):,}",
            f"Internal collaborations: {int(node['internal_edge_count']):,}",
            f"Internal weight: {int(node['internal_weight']):,}",
        ]
        if top_names:
            actor_list = "\n".join(f"  - {name}" for name in top_names)
            title_parts.append(f"Top actors:\n{actor_list}")
        net.add_node(
            community_id,
            label=f"C{community_id}",
            title="\n".join(title_parts),
            value=max(int(node["actor_count"]), 1),
            group=community_id,
        )

    for edge in edges:
        source = int(edge["source_community"])
        target = int(edge["target_community"])
        if source not in node_ids or target not in node_ids:
            continue
        weight = int(edge.get("weight", 1))
        net.add_edge(
            source,
            target,
            value=weight,
            title=f"{weight} cross-community collaborations",
        )

    with tempfile.NamedTemporaryFile(mode="w+", suffix=".html", delete=False) as tmp_file:
        net.save_graph(tmp_file.name)
        tmp_file.seek(0)
        html_content = tmp_file.read()
    components_html(html_content, height=700, scrolling=True)
    os.unlink(tmp_file.name)


def render_network() -> None:
    limit_nodes = st.slider("Top central people", min_value=5, max_value=50, value=10)
    limit_edges = st.slider("Top collaborations", min_value=5, max_value=50, value=10)
    min_shared = st.slider("Minimum shared films", min_value=1, max_value=10, value=2)
    params = {
        "limit_nodes": limit_nodes,
        "limit_edges": limit_edges,
        "min_shared_films": min_shared,
    }
    data = fetch_json("/analytics/network/collaboration", params=with_source(params))
    stats = data["stats"]
    cols = st.columns(3)
    cols[0].metric("Nodes", stats["node_count"])
    cols[1].metric("Edges", stats["edge_count"])
    cols[2].metric("Density", f"{stats['density']:.3f}")
    st.metric("Average Degree", f"{stats['average_degree']:.2f}")
    st.subheader("Central People")
    st.dataframe(pd.DataFrame(data["top_centrality"]))
    st.subheader("Strongest Collaborations")
    st.dataframe(pd.DataFrame(data["top_collaborations"]))
    st.subheader("Collaboration Graph")
    _render_network_graph(data["top_centrality"], data["top_collaborations"])


def _format_optional(value: Any, digits: int = 3) -> str:
    if value is None:
        return "n/a"
    if isinstance(value, float):
        return f"{value:.{digits}f}"
    return str(value)


def render_graph_analysis() -> None:
    max_diameter_nodes = st.sidebar.slider(
        "Max nodes for exact diameter",
        min_value=100,
        max_value=5000,
        value=1000,
        step=100,
    )
    max_cast_size = st.sidebar.slider("Max cast size", min_value=2, max_value=500, value=30)
    top_core_actors = st.sidebar.slider("Top core actors", min_value=5, max_value=100, value=25, step=5)
    min_core_degree = st.sidebar.slider("Minimum degree for core table", min_value=0, max_value=100, value=1)
    data = fetch_json(
        "/analytics/network/actor-projection",
        params=with_source({
            "max_diameter_nodes": max_diameter_nodes,
            "max_cast_size": max_cast_size,
            "top_core_actors": top_core_actors,
            "min_core_actor_degree": min_core_degree,
        }),
    )

    stats = data["stats"]
    cols = st.columns(4)
    cols[0].metric("Actors", f"{stats['node_count']:,}")
    cols[1].metric("Collaborations", f"{stats['edge_count']:,}")
    cols[2].metric("Films Used", f"{data['movie_count']:,}")
    cols[3].metric("Largest Component", f"{data['largest_component_count']:,}")

    tabs = st.tabs(
        (
            "Network Graph",
            "Communities",
            "Power Law",
            "High-Cluster",
            "Log-Average Path",
            "Core-Like Structure",
        )
    )

    with tabs[0]:
        st.subheader("Core Actor Network")
        _render_network_graph(data["graph_nodes"], data["graph_edges"])

    with tabs[1]:
        communities = data["communities"]
        metric_cols = st.columns(3)
        metric_cols[0].metric("Algorithm", communities["algorithm"].title())
        metric_cols[1].metric("Communities", f"{communities['community_count']:,}")
        metric_cols[2].metric("Modularity", _format_optional(communities.get("modularity")))
        st.subheader("Leiden Community Graph")
        _render_community_graph(communities)

        community_df = pd.DataFrame(communities["nodes"])
        if not community_df.empty:
            community_df["top_actors"] = community_df["top_actors"].apply(
                lambda actors: ", ".join(
                    actor.get("name") or f"Person {actor['person_id']}"
                    for actor in actors
                )
            )
            st.dataframe(
                community_df.sort_values("actor_count", ascending=False),
                use_container_width=True,
            )

    with tabs[2]:
        power_law = data["power_law"]
        metric_cols = st.columns(3)
        metric_cols[0].metric("Alpha", _format_optional(power_law.get("alpha")))
        metric_cols[1].metric("xmin", _format_optional(power_law.get("xmin"), digits=0))
        metric_cols[2].metric("Log-log R2", _format_optional(power_law.get("r_squared")))
        degree_df = pd.DataFrame(power_law["degree_distribution"])
        if degree_df.empty:
            st.info("Not enough actor collaborations to build a degree distribution.")
        else:
            fig = px.scatter(
                degree_df,
                x="degree",
                y="count",
                log_x=True,
                log_y=True,
                title="Actor Degree Distribution",
            )
            st.plotly_chart(fig, use_container_width=True)
            st.dataframe(degree_df, use_container_width=True)

    with tabs[3]:
        clustering = data["clustering"]
        metric_cols = st.columns(2)
        metric_cols[0].metric("Average Clustering", _format_optional(clustering["average_clustering"]))
        metric_cols[1].metric("Transitivity", _format_optional(clustering["transitivity"]))
        cluster_df = pd.DataFrame(clustering["coefficient_distribution"])
        if not cluster_df.empty:
            cluster_df["coefficient"] = cluster_df["degree"] / 20
            fig = px.bar(
                cluster_df,
                x="coefficient",
                y="count",
                title="Local Clustering Coefficient Distribution",
            )
            fig.update_xaxes(title_text="Local clustering coefficient", tickformat=".2f")
            st.plotly_chart(fig, use_container_width=True)
        st.caption("Actor projection graphs often cluster strongly because each movie cast creates many actor pairs.")

    with tabs[4]:
        path = data["path"]
        metric_cols = st.columns(4)
        metric_cols[0].metric("LCC Nodes", f"{path['largest_component_nodes']:,}")
        metric_cols[1].metric("LCC Share", f"{path['largest_component_share']:.1%}")
        metric_cols[2].metric("Avg Shortest Path", _format_optional(path["average_shortest_path_length"]))
        metric_cols[3].metric("Diameter", _format_optional(path["diameter"], digits=0))
        compare_cols = st.columns(2)
        compare_cols[0].metric("log(n)", _format_optional(path["log_node_count"]))
        compare_cols[1].metric("Avg Path / log(n)", _format_optional(path["average_path_to_log_ratio"]))
        if path.get("sampled"):
            st.info(
                "Average shortest path is sampled and diameter is skipped because the largest component is above the configured exact limit."
            )
        path_df = pd.DataFrame(path["length_distribution"])
        if not path_df.empty:
            fig = px.bar(
                path_df,
                x="degree",
                y="count",
                title="Shortest Path Length Distribution",
            )
            fig.update_xaxes(title_text="Path length")
            st.plotly_chart(fig, use_container_width=True)

    with tabs[5]:
        core = data["core"]
        st.metric("Max Core Number", core["max_core_number"])
        core_df = pd.DataFrame(core["core_size_by_k"])
        if not core_df.empty:
            fig = px.bar(core_df, x="degree", y="count", title="Core Number Distribution")
            fig.update_xaxes(title_text="Core number")
            st.plotly_chart(fig, use_container_width=True)
            st.dataframe(core_df.rename(columns={"degree": "core_number"}), use_container_width=True)
        actors_df = pd.DataFrame(core["top_actors"])
        st.subheader("Top Core Actors")
        if actors_df.empty:
            st.info("No core actors to show yet.")
        else:
            display_df = actors_df.rename(columns={"value": "core_number"})
            chart_df = display_df.sort_values(["core_number", "name"], ascending=[True, True]).tail(25)
            fig = px.bar(
                chart_df,
                x="core_number",
                y="name",
                orientation="h",
                title="Top Actors by Core Number",
            )
            st.plotly_chart(fig, use_container_width=True)
            st.dataframe(
                display_df,
                use_container_width=True,
            )


def main() -> None:
    st.set_page_config(page_title="Scrapoo Dashboard", layout="wide")
    st.title("Scrapoo Analytics Dashboard")
    selected_label = st.sidebar.radio("Data Source", tuple(DATA_SOURCES), horizontal=True)
    st.session_state["data_source"] = DATA_SOURCES[selected_label]
    st.caption(f"Data source: {selected_label}")
    section = st.sidebar.radio(
        "Section",
        (
            "Overview",
            "People",
            "Countries",
            "Releases",
            "Network",
            "Graph Analysis",
        ),
    )
    if section == "Overview":
        render_overview()
    elif section == "People":
        render_people()
    elif section == "Countries":
        render_countries()
    elif section == "Releases":
        render_releases()
    elif section == "Network":
        render_network()
    else:
        render_graph_analysis()


if __name__ == "__main__":
    main()
