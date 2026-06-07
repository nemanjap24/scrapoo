from typing import List, Literal, Optional

from pydantic import BaseModel


class PersonStats(BaseModel):
    id: int
    name: Optional[str] = None
    occupation: Optional[str] = None
    film_count: int


class CountryStats(BaseModel):
    id: int
    name: Optional[str] = None
    film_count: int


class AnalyticsOverview(BaseModel):
    total_films: int
    total_people: int
    top_actors: List[PersonStats]
    top_directors: List[PersonStats]
    prolific_countries: List[CountryStats]


class RolePeopleStats(BaseModel):
    role: str
    people: List[PersonStats]


class PeopleAnalytics(BaseModel):
    total_roles: int
    roles: List[RolePeopleStats]


class CountryShareStats(CountryStats):
    film_share: float


class CountriesAnalytics(BaseModel):
    total_countries: int
    total_films: int
    countries: List[CountryShareStats]


class ReleaseBucketStats(BaseModel):
    label: str
    film_count: int


class ReleaseAnalytics(BaseModel):
    grouping: Literal["year", "decade"]
    total_buckets: int
    total_films: int
    buckets: List[ReleaseBucketStats]


class GraphStats(BaseModel):
    node_count: int
    edge_count: int
    density: float
    average_degree: float


class GraphNodeMetric(BaseModel):
    person_id: int
    name: Optional[str]
    occupation: Optional[str]
    value: float


class GraphEdgeMetric(BaseModel):
    source_id: int
    source_name: Optional[str]
    target_id: int
    target_name: Optional[str]
    weight: int


class CollaborationAnalytics(BaseModel):
    stats: GraphStats
    top_centrality: List[GraphNodeMetric]
    top_collaborations: List[GraphEdgeMetric]


class DegreeDistributionBucket(BaseModel):
    degree: int
    count: int


class PowerLawAnalytics(BaseModel):
    alpha: Optional[float] = None
    xmin: Optional[int] = None
    r_squared: Optional[float] = None
    degree_distribution: List[DegreeDistributionBucket]


class ClusteringAnalytics(BaseModel):
    average_clustering: float
    transitivity: float
    coefficient_distribution: List[DegreeDistributionBucket]


class PathAnalytics(BaseModel):
    largest_component_nodes: int
    largest_component_share: float
    average_shortest_path_length: Optional[float] = None
    diameter: Optional[int] = None
    log_node_count: Optional[float] = None
    average_path_to_log_ratio: Optional[float] = None
    sampled: bool = False
    length_distribution: List[DegreeDistributionBucket]


class CoreAnalytics(BaseModel):
    max_core_number: int
    core_size_by_k: List[DegreeDistributionBucket]
    top_actors: List[GraphNodeMetric]


class CommunityNodeMetric(BaseModel):
    community_id: int
    actor_count: int
    internal_edge_count: int
    internal_weight: int
    top_actors: List[GraphNodeMetric]


class CommunityEdgeMetric(BaseModel):
    source_community: int
    target_community: int
    weight: int


class CommunityAnalytics(BaseModel):
    algorithm: str
    community_count: int
    modularity: Optional[float] = None
    nodes: List[CommunityNodeMetric]
    edges: List[CommunityEdgeMetric]


class ActorProjectionAnalytics(BaseModel):
    stats: GraphStats
    movie_count: int
    largest_component_count: int
    power_law: PowerLawAnalytics
    clustering: ClusteringAnalytics
    path: PathAnalytics
    core: CoreAnalytics
    communities: CommunityAnalytics
    graph_nodes: List[GraphNodeMetric]
    graph_edges: List[GraphEdgeMetric]
