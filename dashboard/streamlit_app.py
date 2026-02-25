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


@st.cache_data(ttl=60)
def fetch_json(path: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    url = f"{API_BASE_URL}{path}"
    with httpx.Client(timeout=DEFAULT_TIMEOUT) as client:
        response = client.get(url, params=params or {})
        response.raise_for_status()
        return response.json()


def render_overview() -> None:
    data = fetch_json("/analytics/overview", params={"limit": 10})
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
    data = fetch_json("/analytics/people", params=params)
    for role_stats in data.get("roles", []):
        st.subheader(f"{role_stats['role'].title()}s")
        df = pd.DataFrame(role_stats["people"])
        fig = px.bar(df, x="name", y="film_count", title=f"{role_stats['role'].title()} output")
        st.plotly_chart(fig, use_container_width=True)
        st.dataframe(df)


def render_countries() -> None:
    limit = st.slider("Countries to show", min_value=5, max_value=30, value=10)
    data = fetch_json("/analytics/countries", params={"limit": limit})
    st.subheader("Country Share")
    df = pd.DataFrame(data["countries"])
    fig = px.pie(df, values="film_count", names="name", title="Film Share by Country")
    st.plotly_chart(fig, use_container_width=True)
    st.dataframe(df)


def render_releases() -> None:
    bucket = st.selectbox("Grouping", options=["decade", "year"], index=0)
    limit = st.slider("Buckets to show", min_value=5, max_value=40, value=12)
    data = fetch_json("/analytics/releases", params={"bucket": bucket, "limit": limit})
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


def render_network() -> None:
    limit_nodes = st.slider("Top central people", min_value=5, max_value=50, value=10)
    limit_edges = st.slider("Top collaborations", min_value=5, max_value=50, value=10)
    min_shared = st.slider("Minimum shared films", min_value=1, max_value=10, value=2)
    params = {
        "limit_nodes": limit_nodes,
        "limit_edges": limit_edges,
        "min_shared_films": min_shared,
    }
    data = fetch_json("/analytics/network/collaboration", params=params)
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


def main() -> None:
    st.set_page_config(page_title="Scrapoo Dashboard", layout="wide")
    st.title("Scrapoo Analytics Dashboard")
    st.caption("Data source: FastAPI analytics endpoints")
    section = st.sidebar.radio(
        "Section",
        (
            "Overview",
            "People",
            "Countries",
            "Releases",
            "Network",
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
    else:
        render_network()


if __name__ == "__main__":
    main()
