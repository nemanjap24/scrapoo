from __future__ import annotations

from typing import List, Sequence

from app.core.config import settings
from scraper.sitemap_collector import decompress_gzip, extract_locs_from_xml, fetch_bytes, is_gzip_bytes


class SitemapResolutionError(RuntimeError):
    """Raised when sitemap URLs cannot be resolved."""


def resolve_sitemaps(from_page: int | None = None, max_pages: int | None = None) -> List[str]:
    """Return the list of sitemap URLs to process based on paging arguments."""

    index_bytes = _fetch_bytes(str(settings.SITEMAP_INDEX_URL))
    sitemap_urls = _extract_locs(index_bytes)
    selected = _slice_sitemaps(sitemap_urls, from_page, max_pages)
    if not selected:
        raise SitemapResolutionError("No sitemap URLs matched the requested range")
    return selected


def expand_sitemaps(
    sitemap_urls: Sequence[str],
    *,
    include_movies: bool = True,
) -> List[str]:
    """Expand sitemap files into individual film URLs."""

    if not include_movies or not sitemap_urls:
        return []

    seen: set[str] = set()
    film_urls: List[str] = []
    for sitemap in sitemap_urls:
        xml_bytes = _fetch_bytes(sitemap)
        locs = _extract_locs(xml_bytes)
        for loc in locs:
            url = loc.strip()
            if not url or url in seen:
                continue
            if "/film/" not in url:
                continue
            seen.add(url)
            film_urls.append(url)
    return film_urls


def _slice_sitemaps(all_sitemaps: Sequence[str], from_page: int | None, max_pages: int | None) -> List[str]:
    if not all_sitemaps:
        return []
    start_index = max(0, (from_page or 1) - 1)
    if start_index >= len(all_sitemaps):
        return []
    if max_pages:
        end_index = min(len(all_sitemaps), start_index + max_pages)
    else:
        end_index = len(all_sitemaps)
    return list(all_sitemaps[start_index:end_index])


def _fetch_bytes(url: str) -> bytes:
    try:
        payload = fetch_bytes(url)
    except Exception as exc:  # pragma: no cover - network errors hit at runtime
        raise SitemapResolutionError(f"Failed to fetch {url}: {exc}") from exc
    if is_gzip_bytes(payload):
        try:
            payload = decompress_gzip(payload)
        except Exception as exc:  # pragma: no cover
            raise SitemapResolutionError(f"Failed to decompress {url}: {exc}") from exc
    return payload


def _extract_locs(xml_bytes: bytes) -> List[str]:
    try:
        return extract_locs_from_xml(xml_bytes)
    except Exception as exc:  # pragma: no cover
        raise SitemapResolutionError(f"Failed to parse sitemap XML: {exc}") from exc
