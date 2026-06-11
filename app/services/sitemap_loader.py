from __future__ import annotations

import gzip
import io
import ssl
import xml.etree.ElementTree as ET
from typing import List, Sequence
from urllib.request import urlopen

from app.core.config import settings


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
    max_films: int | None = None,
) -> List[str]:
    """Expand sitemap files into individual film URLs, respecting optional limits."""

    if not include_movies or not sitemap_urls:
        return []

    seen: set[str] = set()
    film_urls: List[str] = []
    limit = max_films if max_films and max_films > 0 else None
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
            if limit and len(film_urls) >= limit:
                return film_urls
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
        payload = _download_bytes(url)
    except Exception as exc:  # pragma: no cover - network errors hit at runtime
        raise SitemapResolutionError(f"Failed to fetch {url}: {exc}") from exc
    if _is_gzip_bytes(payload):
        try:
            payload = gzip.decompress(payload)
        except Exception as exc:  # pragma: no cover
            raise SitemapResolutionError(f"Failed to decompress {url}: {exc}") from exc
    return payload


def _extract_locs(xml_bytes: bytes) -> List[str]:
    try:
        return _extract_locs_from_xml(xml_bytes)
    except Exception as exc:  # pragma: no cover
        raise SitemapResolutionError(f"Failed to parse sitemap XML: {exc}") from exc


def _download_bytes(url: str, timeout: int = 30) -> bytes:
    try:
        with urlopen(url, timeout=timeout) as response:
            return response.read()
    except Exception:
        context = ssl._create_unverified_context()
        with urlopen(url, timeout=timeout, context=context) as response:
            return response.read()


def _extract_locs_from_xml(xml_bytes: bytes) -> List[str]:
    try:
        text = xml_bytes.decode("utf-8")
    except Exception:
        try:
            text = xml_bytes.decode("latin-1")
        except Exception:
            text = xml_bytes.decode(errors="ignore")

    iterator = ET.iterparse(io.StringIO(text))
    for _, element in iterator:
        if "}" in element.tag:
            element.tag = element.tag.split("}", 1)[1]
    root = iterator.root

    if root.tag == "sitemapindex":
        return [
            loc.text.strip()
            for sitemap in root.findall("sitemap")
            for loc in [sitemap.find("loc")]
            if loc is not None and loc.text
        ]

    return [
        loc.text.strip()
        for url in root.findall("url")
        for loc in [url.find("loc")]
        if loc is not None and loc.text
    ]


def _is_gzip_bytes(payload: bytes) -> bool:
    return len(payload) >= 2 and payload[0] == 0x1F and payload[1] == 0x8B
