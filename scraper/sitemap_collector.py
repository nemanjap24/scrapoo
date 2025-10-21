"""sitemap_collector.py

Standalone module to collect URLs from robots.txt -> sitemaps -> nested sitemaps.

Usage:
    python -m scraper.sitemap_collector

This script will fetch https://www.csfd.sk/robots.txt, discover sitemaps (including sitemapindex files),
download each sitemap (supports .xml and .xml.gz), extract all <loc> URLs and print counts.

Designed for research / small scripts; robust to network errors and common sitemap structures.
"""
from __future__ import annotations

import gzip
import io
import ssl
import sys
import time
import csv
import logging
import xml.etree.ElementTree as ET
from typing import Iterable, List, Set, Optional
import os
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
import argparse
import json

try:
    import requests
except Exception:  # pragma: no cover - fallback
    requests = None

ROBOT_URL = "https://www.csfd.sk/robots.txt"


def _series_key_from_url(url: str) -> Optional[str]:
    """Extract the series key (first segment after /film/) or None."""
    from urllib.parse import urlparse
    p = urlparse(url).path
    parts = [seg for seg in p.split('/') if seg]
    try:
        idx = parts.index('film')
    except ValueError:
        return None
    if idx + 1 < len(parts):
        return parts[idx + 1]
    return None


def _is_base_film_url(url: str, series_key: str) -> bool:
    # Strict match: only treat URLs like
    # https://<host>/film/<id-movie-name>/prehlad/  (optional trailing slash)
    # as the base page. This avoids matching pages that have extra segments
    # between the movie slug and 'prehlad' (e.g. '/film/<slug>/season/..../prehlad/').
    import re
    pattern = re.compile(r"^https?://[^/]+/film/[^/]+/prehlad/?$", re.IGNORECASE)
    return bool(pattern.match(url))


def normalize_film_urls(urls: Iterable[str]) -> Set[str]:
    """Normalize film URLs to avoid duplicates:

    - Group URLs by series key (first segment after /film/).
    - If the group contains the base series page (no extra path or next segment 'prehlad'), keep only that.
    - Else if group contains season pages (segment contains 'season'), keep season pages and drop episode pages.
    - Else keep all pages in the group (likely episode-only series).
    """
    from urllib.parse import urlparse

    urls = set(urls)
    groups: dict[str, Set[str]] = {}
    others: Set[str] = set()
    for u in urls:
        key = _series_key_from_url(u)
        if key:
            groups.setdefault(key, set()).add(u)
        else:
            others.add(u)

    result: Set[str] = set(others)
    for key, grp in groups.items():
        # find base
        base = None
        for u in grp:
            if _is_base_film_url(u, key):
                base = u
                break

        if base:
            result.add(base)
            continue

        # no base -> check for season pages
        seasons = set()
        episodes = set()
        for u in grp:
            path = urlparse(u).path
            parts = [seg for seg in path.split('/') if seg]
            # segment after series key
            try:
                idx = parts.index('film')
                seg = parts[idx + 2] if idx + 2 < len(parts) else ''
            except Exception:
                seg = ''
            if 'season' in seg.lower():
                seasons.add(u)
            else:
                episodes.add(u)

        if seasons:
            result.update(seasons)
        else:
            result.update(episodes)

    return result


def fetch_text(url: str, timeout: int = 15) -> str:
    """Fetch URL and return text. Uses requests if available, otherwise urllib.

    Raises Exception on network errors.
    """
    if requests:
        try:
            resp = requests.get(url, timeout=timeout)
            resp.raise_for_status()
            return resp.text
        except Exception as e:
            # possibly an SSL certificate issue; fall through to urllib retry below
            logging.warning("requests failed for %s: %s. Will retry ignoring SSL verification.", url, e)

    # fallback to urllib with possible unverified SSL retry
    from urllib.request import urlopen
    from urllib.error import URLError

    try:
        with urlopen(url, timeout=timeout) as f:
            raw = f.read()
    except Exception as e:
        # Retry with unverified SSL context for environments with missing cert bundle (research use)
        try:
            ctx = ssl._create_unverified_context()
            logging.warning("SSL verification failed for %s, retrying without verification.", url)
            with urlopen(url, timeout=timeout, context=ctx) as f:
                raw = f.read()
        except Exception:
            raise

    # try to decode as utf-8, fallback to latin1
    try:
        return raw.decode("utf-8")
    except Exception:
        return raw.decode("latin-1")


def fetch_bytes(url: str, timeout: int = 30) -> bytes:
    """Fetch URL and return raw bytes. Uses requests if available."""
    if requests:
        try:
            resp = requests.get(url, timeout=timeout)
            resp.raise_for_status()
            return resp.content
        except Exception as e:
            logging.warning("requests failed for %s: %s. Will retry ignoring SSL verification.", url, e)

    from urllib.request import urlopen
    from urllib.error import URLError

    try:
        with urlopen(url, timeout=timeout) as f:
            return f.read()
    except Exception as e:
        # Retry with unverified SSL context
        try:
            ctx = ssl._create_unverified_context()
            logging.warning("SSL verification failed for %s, retrying without verification.", url)
            with urlopen(url, timeout=timeout, context=ctx) as f:
                return f.read()
        except Exception:
            raise


def parse_robots_for_sitemaps(robots_text: str) -> List[str]:
    """Extract sitemap URLs from robots.txt content."""
    sitemaps: List[str] = []
    for line in robots_text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if line.lower().startswith("sitemap:"):
            _, val = line.split(":", 1)
            sitemaps.append(val.strip())
    return sitemaps


def extract_locs_from_xml(xml_bytes: bytes) -> List[str]:
    """Parse sitemap XML (bytes) and return list of <loc> values.

    Supports sitemapindex (nested sitemaps) and urlset.
    """
    try:
        text = xml_bytes.decode("utf-8")
    except Exception:
        try:
            text = xml_bytes.decode("latin-1")
        except Exception:
            text = xml_bytes.decode(errors="ignore")

    # remove XML namespace prefixes for simpler tag matching
    it = ET.iterparse(io.StringIO(text))
    for _, el in it:
        if "}" in el.tag:
            el.tag = el.tag.split("}", 1)[1]
    root = it.root

    locs: List[str] = []
    # handle sitemapindex -> <sitemap><loc>...
    if root.tag == "sitemapindex":
        for sitemap in root.findall("sitemap"):
            loc = sitemap.find("loc")
            if loc is not None and loc.text:
                locs.append(loc.text.strip())
    else:
        # assume urlset
        for url in root.findall("url"):
            loc = url.find("loc")
            if loc is not None and loc.text:
                locs.append(loc.text.strip())

    return locs


def is_gzip_bytes(b: bytes) -> bool:
    return len(b) >= 2 and b[0] == 0x1F and b[1] == 0x8B


def decompress_gzip(b: bytes) -> bytes:
    return gzip.decompress(b)


def collect_all_sitemaps(start_robots_url: str = ROBOT_URL) -> Set[str]:
    """Collect all sitemap URLs by reading robots.txt and traversing sitemapindex files.

    Returns a set of sitemap URLs that point to urlset XML files (or gzipped XML).
    """
    robots = fetch_text(start_robots_url)
    sitemaps = list(parse_robots_for_sitemaps(robots))

    seen: Set[str] = set()
    to_process = sitemaps[:]

    while to_process:
        cur = to_process.pop()
        if cur in seen:
            continue
        seen.add(cur)
        try:
            raw = fetch_bytes(cur)
        except Exception as e:
            logging.warning("failed to fetch %s: %s", cur, e)
            continue

        if is_gzip_bytes(raw):
            try:
                raw = decompress_gzip(raw)
            except Exception as e:
                logging.warning("failed to decompress gzip %s: %s", cur, e)
                continue

        try:
            locs = extract_locs_from_xml(raw)
        except Exception as e:
            logging.warning("failed to parse XML from %s: %s", cur, e)
            continue

        for l in locs:
            # If loc points to a sitemap, queue it for processing
            if l.endswith('.xml') or l.endswith('.xml.gz') or 'sitemap' in l.lower():
                if l not in seen:
                    to_process.append(l)

    # At this point `seen` contains all sitemap-like files discovered.
    return seen


def collect_all_urls_from_sitemaps(sitemap_urls: Iterable[str]) -> Set[str]:
    """Given sitemap URLs (can be xml or xml.gz), collect all <loc> URLs from urlset files.

    Returns a set of page URLs.
    """
    urls: Set[str] = set()

    def process_sitemap(s: str, verbose: bool = False) -> Optional[Set[str]]:
        try:
            raw = fetch_bytes(s)
        except Exception as e:
            logging.warning("failed to fetch sitemap %s: %s", s, e)
            return None

        if is_gzip_bytes(raw):
            try:
                raw = decompress_gzip(raw)
            except Exception as e:
                logging.warning("failed to decompress %s: %s", s, e)
                return None

        try:
            locs = extract_locs_from_xml(raw)
        except Exception as e:
            logging.warning("failed to parse XML %s: %s", s, e)
            return None

        page_urls: Set[str] = set()
        for l in locs:
            if l.endswith('.xml') or l.endswith('.xml.gz') or 'sitemap' in l.lower():
                continue
            page_urls.add(l)

        if verbose:
            logging.info("Read sitemap: %s -> %d page URLs", s, len(page_urls))

        return page_urls

    # We'll run sitemap processing concurrently if there are many
    sitemap_list = list(sitemap_urls)
    workers = min(16, max(2, len(sitemap_list)))
    with ThreadPoolExecutor(max_workers=workers) as ex:
        future_to_s = {ex.submit(process_sitemap, s, True): s for s in sitemap_list}
        for fut in as_completed(future_to_s):
            s = future_to_s[fut]
            try:
                res = fut.result()
            except Exception as e:
                logging.warning("sitemap %s raised during processing: %s", s, e)
                continue
            if res:
                urls.update(res)

    return urls


def main(argv: List[str] | None = None) -> int:
    argv = argv or sys.argv[1:]

    parser = argparse.ArgumentParser(description="Collect URLs from robots.txt -> sitemaps")
    parser.add_argument("robots_url", nargs="?", default=ROBOT_URL, help="robots.txt URL to start from")
    parser.add_argument("--out", "-o", help="Output file to write URLs (json or csv)")
    parser.add_argument("--workers", "-w", type=int, default=8, help="Number of concurrent workers for sitemap fetching")
    parser.add_argument("--verbose", "-v", action="store_true", help="Verbose: print messages when sitemaps/URLs are read")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--only-film-creator", action="store_true", help="Only save URLs that are films (contain '/film/') or creators ('/tvorca/')")
    group.add_argument("--only-films", action="store_true", help="Only save URLs that are films ('/film/')")
    group.add_argument("--only-creators", action="store_true", help="Only save URLs that are creators ('/tvorca/')")
    parser.add_argument("--rotate-existing", action="store_true", help="If output file exists, rename it with a timestamp suffix before writing")
    parser.add_argument("--format", choices=["json", "csv"], default="json", help="Output format when using --out")
    parser.add_argument("--quiet", action="store_true", help="Quiet mode: reduce logging output")
    args = parser.parse_args(argv)

    robots_url = args.robots_url
    # Configure logging
    log_level = logging.DEBUG if args.verbose else (logging.WARNING if args.quiet else logging.INFO)
    logging.basicConfig(level=log_level, format="%(asctime)s %(levelname)s %(message)s")
    logging.info("Fetching robots.txt from: %s", robots_url)
    try:
        robots = fetch_text(robots_url)
    except Exception as e:
        print(f"Error: failed to fetch robots.txt: {e}", file=sys.stderr)
        return 2

    sitemaps = parse_robots_for_sitemaps(robots)
    if not sitemaps:
        print("No sitemaps found in robots.txt")
        return 0

    logging.info("Found %d sitemaps in robots.txt. Discovering nested sitemaps...", len(sitemaps))
    all_sitemaps = collect_all_sitemaps(robots_url)
    # union with original
    all_sitemaps = all_sitemaps.union(sitemaps)

    logging.info("Discovered %d sitemap files total.", len(all_sitemaps))

    logging.info("Collecting page URLs from sitemaps (this may take a while)...")
    # use provided workers value
    # patch: pass workers to collect_all_urls_from_sitemaps by setting env var or monkeypatch the function; simpler: adjust function to accept workers
    # For now, we'll set a small config via global variable. But better is to pass through; to keep patch small, override local behavior here.
    # We'll call a local concurrent routine here instead of modifying collect_all_urls_from_sitemaps signature.

    # Prepare sitemap list
    sitemap_list = sorted(all_sitemaps)

    # Inline concurrent processing using existing helper process_sitemap (redefine here similar to collect_all_urls_from_sitemaps)
    def process_sitemap_inline(s: str, verbose: bool = False) -> Optional[Set[str]]:
        try:
            raw = fetch_bytes(s)
        except Exception as e:
            print(f"Warning: failed to fetch sitemap {s}: {e}", file=sys.stderr)
            return None

        if is_gzip_bytes(raw):
            try:
                raw = decompress_gzip(raw)
            except Exception as e:
                print(f"Warning: failed to decompress {s}: {e}", file=sys.stderr)
                return None

        try:
            locs = extract_locs_from_xml(raw)
        except Exception as e:
            print(f"Warning: failed to parse XML {s}: {e}", file=sys.stderr)
            return None

        page_urls: Set[str] = set()
        for l in locs:
            if l.endswith('.xml') or l.endswith('.xml.gz') or 'sitemap' in l.lower():
                continue
            page_urls.add(l)

        if verbose:
            # only log summary per sitemap
            logging.info("Read sitemap: %s -> %d page URLs", s, len(page_urls))

        return page_urls

    urls: Set[str] = set()
    workers = max(1, args.workers)
    with ThreadPoolExecutor(max_workers=workers) as ex:
        future_to_s = {ex.submit(process_sitemap_inline, s, args.verbose): s for s in sitemap_list}
        for fut in as_completed(future_to_s):
            s = future_to_s[fut]
            try:
                res = fut.result()
            except Exception as e:
                print(f"Warning: sitemap {s} raised during processing: {e}", file=sys.stderr)
                continue
            if res:
                urls.update(res)

    total = len(urls)
    film_urls = [u for u in urls if 'www.csfd.sk/film/' in u]
    # Normalize film URLs to avoid counting episodes/seasons as duplicates
    normalized_films = normalize_film_urls(film_urls)
    logging.info("Total page URLs found: %d", total)
    logging.info("Film URLs (containing 'www.csfd.sk/film/'): %d (normalized: %d)", len(film_urls), len(normalized_films))

    if args.out:
        write_urls = sorted(urls)
        films = [u for u in write_urls if '/film/' in u]
        creators = [u for u in write_urls if '/tvorca/' in u]
        # apply normalization when considering films to write
        normalized_films = normalize_film_urls(films)

        if args.only_film_creator:
            filtered = sorted(set(normalized_films) | set(creators))
        elif args.only_films:
            filtered = sorted(set(normalized_films))
        elif args.only_creators:
            filtered = sorted(set(creators))
        else:
            # if not filtering, include all urls but replace film urls with normalized set to avoid duplicates
            non_films = [u for u in write_urls if '/film/' not in u]
            filtered = sorted(set(non_films) | set(normalized_films))

        # rotate existing file if requested -> move into archive/
        out_path = Path(args.out)
        archive_dir = out_path.parent / 'archive'
        if args.rotate_existing and out_path.exists():
            try:
                archive_dir.mkdir(parents=True, exist_ok=True)
                ts = time.strftime('%Y%m%d-%H%M%S')
                newname = archive_dir / f"{out_path.name}.{ts}.bak"
                out_path.rename(newname)
                logging.info("Rotated existing %s -> %s", out_path, newname)
            except Exception as e:
                logging.warning("failed to rotate existing file %s: %s", args.out, e)

        try:
            if args.format == 'json':
                with open(args.out, 'w', encoding='utf-8') as f:
                    if args.only_film_creator:
                        # Save normalized film URLs, not raw ones
                        json.dump({'films': sorted(set(normalized_films)), 'creators': sorted(set(creators))}, f, ensure_ascii=False, indent=2)
                    else:
                        json.dump({'urls': filtered, 'films_count': len(normalized_films), 'creators_count': len(creators)}, f, ensure_ascii=False, indent=2)
            else:  # csv
                # CSV will contain columns: url,type where type is film/creator/other
                with open(args.out, 'w', newline='', encoding='utf-8') as f:
                    writer = csv.writer(f)
                    writer.writerow(['url', 'type'])
                    for u in filtered:
                        t = 'film' if '/film/' in u else ('creator' if '/tvorca/' in u else 'other')
                        writer.writerow([u, t])

            logging.info("Wrote %d URLs to %s", len(filtered), args.out)
            logging.info("Film URLs (normalized): %d; Creator URLs: %d", len(normalized_films), len(creators))
        except Exception as e:
            logging.warning("failed to write output file %s: %s", args.out, e)

    # Optionally print sample
    if film_urls:
        print("Sample film URL:", film_urls[0])

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
