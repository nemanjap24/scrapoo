"""Scrapy-powered helpers for crawling CSFD movie pages.

This module wraps a purpose-built Spider so Celery tasks (or other callers)
can programmatically crawl listing or film detail pages and receive
plain-Python payloads.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Callable, Dict, Iterable, List, Optional, Tuple

import scrapy
from scrapy.crawler import CrawlerProcess

from app.core.config import settings


@dataclass
class ScrapeBatch:
    movies: List[Dict]
    people: List[Dict]


@dataclass
class _Collector:
    movies: List[Dict] = field(default_factory=list)
    people: List[Dict] = field(default_factory=list)

    def __call__(self, item: Dict) -> None:
        payload = dict(item)
        item_type = payload.pop("item_type", "movie")
        if item_type == "person":
            self.people.append(payload)
        else:
            self.movies.append(payload)

    def build(self) -> ScrapeBatch:
        return ScrapeBatch(movies=self.movies[:], people=self.people[:])


class CSFDSpider(scrapy.Spider):  # pragma: no cover - exercised via Celery integration tests
    name = "scrapoo-csfd"

    def __init__(
        self,
        start_urls: Iterable[str],
        item_callback: Optional[Callable[[Dict], None]] = None,
        max_listing_pages: int = 1,
        include_people: bool = False,
        *args,
        **kwargs,
    ) -> None:
        super().__init__(*args, **kwargs)
        self.start_urls = list(start_urls)
        self.item_callback = item_callback
        self.max_listing_pages = max(0, max_listing_pages)
        self.include_people = include_people
        self._listing_pages_seen = 0
        self._seen_movies: set[str] = set()

    def parse(self, response: scrapy.http.Response):  # type: ignore[override]
        url = response.url
        if "/film/" in url:
            yield from self.parse_film(response)
            return
        if any(token in url for token in ("rebricky", "zebricky", "top", "vlastny-vyber")):
            yield from self.parse_listing(response)
            return
        # Fallback: detect listing markup
        if response.css("a.film-title-name"):
            yield from self.parse_listing(response)
        else:
            yield from self.parse_film(response)

    def parse_listing(self, response: scrapy.http.Response):
        film_links = response.css("a.film-title-name::attr(href)").getall()
        for href in film_links:
            url = response.urljoin(href)
            yield response.follow(url, callback=self.parse_film)

        if self._listing_pages_seen >= self.max_listing_pages:
            return

        self._listing_pages_seen += 1
        next_href = response.css("a.page-next::attr(href)").get()
        if next_href:
            yield response.follow(next_href, callback=self.parse_listing)

    def parse_film(self, response: scrapy.http.Response):
        csfd_id = self._extract_csfd_id(response.url)
        if not csfd_id or csfd_id in self._seen_movies:
            return
        self._seen_movies.add(csfd_id)

        title = (response.css("h1::text").get() or "").strip()
        original_title, country_name = self._extract_primary_name_metadata(response)
        year_text = response.css("div.origin span::text").get()
        year = year_text.strip().strip(", ") if year_text else None
        description = (response.css("div.plot-full::text").get() or "").strip()
        genres = [g.strip() for g in response.css("div.genres a::text, div.genres span.genre::text").getall() if g.strip()]
        rating = None
        rating_text = response.css("div.rating-average::text").get()
        if rating_text:
            cleaned = rating_text.strip().replace("%", "")
            try:
                rating = float(cleaned) / 100.0
            except Exception:  # pragma: no cover - depends on upstream format
                rating = None

        poster_url = response.css("div.film-posters img::attr(src)").get()
        creators = response.css("div.creators")
        directors = self._extract_people(creators, labels=("Réžia", "Režie", "Réžia:", "Režie:"))
        actors = self._extract_people(
            creators,
            labels=("Hrajú", "Hrají", "Hrajú:", "Hrají:"),
        )

        movie = {
            "item_type": "movie",
            "csfd_id": csfd_id,
            "csfd_url": response.url,
            "title": title,
            "original_title": original_title or title,
            "year": year,
            "description": description,
            "genres": genres,
            "rating": rating,
            "poster_url": poster_url,
            "directors": directors,
            "actors": actors,
            "country": country_name,
        }
        self._emit(movie)
        yield movie

        if self.include_people:
            for slug in directors:
                yield response.follow(
                    url=response.urljoin(f"/tvorca/{slug}/"),
                    callback=self.parse_person,
                    cb_kwargs={"fallback_slug": slug, "role": "director"},
                )
            for slug in actors:
                yield response.follow(
                    url=response.urljoin(f"/tvorca/{slug}/"),
                    callback=self.parse_person,
                    cb_kwargs={"fallback_slug": slug, "role": "actor"},
                )

    def parse_person(
        self,
        response: scrapy.http.Response,
        fallback_slug: str | None = None,
        role: str | None = None,
    ):
        csfd_id = fallback_slug or self._extract_person_id(response.url)
        name = (response.css("h1::text").get() or "").strip()
        birth_date = (response.css("div.birth-date::text").get() or "").strip()
        bio = (response.css("div.biography::text").get() or "").strip()

        person = {
            "item_type": "person",
            "csfd_id": csfd_id,
            "name": name,
            "birth_date": birth_date or None,
            "bio": bio or None,
            "csfd_url": response.url,
            "occupation": role.title() if role else None,
        }
        self._emit(person)
        yield person

    def _emit(self, payload: Dict) -> None:
        if not self.item_callback:
            return
        try:
            self.item_callback(dict(payload))
        except Exception:  # pragma: no cover - defensive
            self.logger.exception("item_callback failed")

    @staticmethod
    def _extract_csfd_id(url: str) -> Optional[str]:
        if "/film/" not in url:
            return None
        slug = url.split("/film/", 1)[-1]
        slug = slug.split("/", 1)[0]
        return slug.split("-", 1)[0]

    @staticmethod
    def _extract_person_id(url: str) -> Optional[str]:
        for token in ("/tvorca/", "/tvurce/"):
            if token in url:
                slug = url.split(token, 1)[-1]
                return slug.strip("/")
        return None

    def _extract_primary_name_metadata(self, response: scrapy.http.Response) -> Tuple[Optional[str], Optional[str]]:
        entries = response.css("ul.film-names li")
        if not entries:
            return None, self._extract_country_from_origin(response)
        primary = entries[0]
        original_title = self._clean_original_title(primary)
        country = primary.css("img.flag::attr(title)").get() or primary.css("img.flag::attr(alt)").get()
        if country:
            country = country.strip()
        if not country:
            country = self._extract_country_from_origin(response)
        return original_title, country or None

    @staticmethod
    def _clean_original_title(entry) -> Optional[str]:
        raw_parts = entry.xpath("text()[normalize-space()]").getall() or []
        if not raw_parts:
            raw_parts = entry.xpath(".//text()[normalize-space()]").getall()
        cleaned: List[str] = []
        for part in raw_parts:
            chunk = part.strip()
            if not chunk:
                continue
            lowered = chunk.lower()
            if "viac" in lowered or "menej" in lowered:
                continue
            cleaned.append(chunk)
        if not cleaned:
            return None
        text = " ".join(cleaned)
        if "(" in text:
            text = text.split("(", 1)[0].strip()
        return text or None

    @staticmethod
    def _extract_country_from_origin(response: scrapy.http.Response) -> Optional[str]:
        origin_parts = [part.strip() for part in response.css("div.origin ::text").getall() if part.strip()]
        if not origin_parts:
            return None
        candidate = origin_parts[0]
        if "," in candidate:
            candidate = candidate.split(",", 1)[0].strip()
        return candidate or None

    @staticmethod
    def _extract_people(creators, labels: Iterable[str], limit: Optional[int] = None) -> List[str]:
        if not creators:
            return []
        label_xpath = " or ".join([f"contains(., '{label}')" for label in labels])
        section = creators.xpath(f".//div[h4[{label_xpath}]]")
        if not section:
            return []
        links = section.xpath(".//a/@href").getall()
        slugs: List[str] = []
        seen: set[str] = set()
        for href in links:
            slug = href.rstrip("/").split("/")[-1]
            if slug:
                if slug in seen:
                    continue
                seen.add(slug)
                slugs.append(slug)
            if limit and len(slugs) >= limit:
                break
        return slugs


def crawl_movies(
    start_urls: Iterable[str],
    *,
    max_listing_pages: int = 1,
    include_people: bool = True,
    request_delay: Optional[float] = None,
) -> ScrapeBatch:
    """Run the CSFD spider and return collected payloads."""

    collector = _Collector()
    download_delay = settings.REQUEST_DELAY if request_delay is None else request_delay
    spider_settings = {
        "LOG_ENABLED": False,
        "CONCURRENT_REQUESTS": settings.SCRAPY_CONCURRENT_REQUESTS,
        "CONCURRENT_REQUESTS_PER_DOMAIN": settings.SCRAPY_CONCURRENT_REQUESTS,
        "DOWNLOAD_DELAY": max(0.0, download_delay),
        "USER_AGENT": "ScrapooCrawler/1.0 (+https://github.com/nemanjap24/scrapoo)",
        "ROBOTSTXT_OBEY": False,
        "AUTOTHROTTLE_ENABLED": False,
    }

    process = CrawlerProcess(settings=spider_settings)
    process.crawl(
        CSFDSpider,
        start_urls=list(start_urls),
        item_callback=collector,
        max_listing_pages=max_listing_pages,
        include_people=include_people,
    )
    process.start()
    return collector.build()
