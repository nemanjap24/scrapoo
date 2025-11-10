"""scraper/scrapy_parser.py

Lightweight Scrapy-based parser for CSFD pages.

This module provides a Scrapy Spider that parses movie and person pages asynchronously
and calls an optional callback for each parsed item. It's intentionally conservative:
- it doesn't attempt to save to the database automatically (to avoid OS/DB setup complexity),
  but the callback can call existing saving helpers.
- it mirrors selectors from the existing BeautifulSoup parser in `services.py`.

Usage (one-off):
    python3 -m scraper.scrapy_parser --url https://www.csfd.sk/film/12345-nazov

Note: add `scrapy` to `requirements.txt` and install dependencies before running.
"""
from __future__ import annotations

import os
import sys
from typing import Callable, Iterable, Optional
import json

# NOTE: Currently parsed items are written to a JSON file (temporary).
# Later this should be replaced with direct saving to the Django database
# (e.g., via an item pipeline or an `item_callback` that calls `services.save_movie`).

import scrapy
from scrapy.crawler import CrawlerProcess

# Optional: make Django models available if the user wants to save directly from callbacks
try:
    import django
    if os.getenv('DJANGO_SETTINGS_MODULE'):
        django.setup()
except Exception:
    # Running without Django is fine; callback can still handle items
    pass


class MovieItem(scrapy.Item):
    csfd_id = scrapy.Field()
    title = scrapy.Field()
    year = scrapy.Field()
    description = scrapy.Field()
    genres = scrapy.Field()
    rating = scrapy.Field()
    poster_url = scrapy.Field()
    directors = scrapy.Field()
    actors = scrapy.Field()


class PersonItem(scrapy.Item):
    csfd_id = scrapy.Field()
    name = scrapy.Field()
    birth_date = scrapy.Field()
    bio = scrapy.Field()


class CSFDSpider(scrapy.Spider):
    name = "csfd_spider"

    def __init__(self, start_urls: Iterable[str], item_callback: Optional[Callable] = None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.start_urls = list(start_urls)
        self.item_callback = item_callback

    def parse(self, response: scrapy.http.Response):
        url = response.url
        # Decide page type based on URL
        if '/film/' in url:
            yield from self.parse_film(response)
        elif '/tvorca/' in url or '/tvurce/' in url or '/person/' in url:
            yield from self.parse_person(response)
        else:
            # If unsure, try film parser first
            yield from self.parse_film(response)

    def parse_film(self, response: scrapy.http.Response):
        # csfd id from url
        csfd_id = response.url.split('film/', 1)[-1].split('-', 1)[0]

        title = response.css('h1::text').get()
        title = title.strip() if title else ''

        year = response.css('div.origin span::text').get()
        if year:
            year = year.strip().strip(', ')

        description = response.css('div.plot-full::text').get()
        description = description.strip() if description else ''

        genres = response.css('div.genres a::text').getall()
        genres = [g.strip() for g in genres if g.strip()]

        rating_text = response.css('div.rating-average::text').get()
        rating = None
        if rating_text:
            try:
                rating = float(rating_text.strip().replace('%', '')) / 100.0
            except Exception:
                rating = None

        poster_url = response.css('div.film-posters img::attr(src)').get() or ''

        directors = []
        actors = []

        creators = response.css('div.creators')
        if creators:
            # Director lookup (attempt to follow structure used in services.py)
            director_section = creators.xpath(".//h4[contains(., 'Réžia') or contains(., 'Réžia:') or contains(., 'Režie')]")
            if director_section:
                director_links = director_section.xpath('../following-sibling::span[1]//a/@href').getall()
                directors = [href.split('/')[-1] for href in director_links if href and '/tvorca/' in href or '/tvurce/' in href]
            # <div>
            #                                                 <h4>Hrajú:</h4>
            #                                                 <a href="/tvorca/331-johnny-depp/">Johnny Depp</a>, <a
            #                                                     href="/tvorca/60-orlando-bloom/">Orlando Bloom</a>, <a
            #                                                     href="/tvorca/2240-keira-knightley/">Keira Knightley</a>, <a
            #                                                     href="/tvorca/157-stellan-skarsgard/">Stellan Skarsgård</a>, <a
            #                                                     href="/tvorca/12132-bill-nighy/">Bill Nighy</a>, <a
            #                                                     href="/tvorca/38-yun-fat-chow/">Yun-fat Chow</a>, <a
            #                                                     href="/tvorca/2078-geoffrey-rush/">Geoffrey Rush</a>, <a
            #                                                     href="/tvorca/13402-jack-davenport/">Jack Davenport</a>, <a
            #                                                     href="/tvorca/50288-kevin-mcnally/">Kevin McNally</a>, <a
            #                                                     href="/tvorca/4834-naomie-harris/">Naomie
            #                                                     Harris</a><span class="more-member-1 hidden">, <a href="/tvorca/18731-tom-hollander/">Tom Hollander</a>, <a href="/tvorca/465-jonathan-pryce/">Jonathan Pryce</a>, <a href="/tvorca/33539-lee-arenberg/">Lee Arenberg</a>, <a href="/tvorca/33818-mackenzie-crook/">Mackenzie Crook</a>, <a href="/tvorca/46484-david-bailie/">David Bailie</a>, <a href="/tvorca/44164-martin-klebba/">Martin Klebba</a>, <a href="/tvorca/26795-keith-richards/">Keith Richards</a>, <a href="/tvorca/35282-jb-blanc/">JB Blanc</a>, <a href="/tvorca/23339-ghassan-massoud/">Ghassan Massoud</a>, <a href="/tvorca/44881-reggie-lee/">Reggie Lee</a>, <a href="/tvorca/47443-mark-hildreth/">Mark Hildreth</a>, <a href="/tvorca/49807-dominic-scott-kay/">Dominic Scott Kay</a>, <a href="/tvorca/49845-marshall-manesh/">Marshall Manesh</a>, <a href="/tvorca/50287-david-schofield/">David Schofield</a>, <a href="/tvorca/53905-art-hsu/">Art Hsu</a>, <a href="/tvorca/54786-vanessa-branch/">Vanessa Branch</a>, <a href="/tvorca/56097-hakeem-kae-kazim/">Hakeem Kae-Kazim</a>, <a href="/tvorca/19973-omid-djalili/">Omid Djalili</a>, <a href="/tvorca/68457-stany-coppet/">Stany Coppet</a>, <a href="/tvorca/86646-patrick-hume/">Patrick Hume</a>, <a href="/tvorca/90171-greg-ellis/">Greg Ellis</a>, <a href="/tvorca/100705-peter-donald-badalamenti-ii/">Peter Donald Badalamenti II</a>, <a href="/tvorca/130717-sergio-calderon/">Sergio Calderón</a>, <a href="/tvorca/184148-barnett-o-hara/">Barnett O'Hara</a>, <a href="/tvorca/217800-christopher-adamson/">Christopher Adamson</a>, <a href="/tvorca/224783-dermot-keaney/">Dermot Keaney</a>, <a href="/tvorca/225121-andy-beckwith/">Andy Beckwith</a>, <a href="/tvorca/229045-david-meunier/">David Meunier</a>, <a href="/tvorca/18738-marcel-iures/">Marcel Iureș</a>, <a href="/tvorca/263120-chris-m-allport/">Chris M. Allport</a>, <a href="/tvorca/276433-lauren-maher/">Lauren Maher</a>, <a href="/tvorca/283277-ned-wertimer/">Ned Wertimer</a>, <a href="/tvorca/307472-natalie-victoria/">Natalie Victoria</a>, <a href="/tvorca/329378-christopher-s-capp/">Christopher S. Capp</a>, <a href="/tvorca/49674-michelle-lee/">Michelle Lee</a>, <a href="/tvorca/35999-alexandr-bargman/">Alexandr Bargman</a>, <a href="/tvorca/485437-david-prak/">David Prak</a>, <a href="/tvorca/486947-giles-new/">Giles New</a>, <a href="/tvorca/486949-angus-barnett/">Angus Barnett</a>, <a href="/tvorca/486962-takayo-fischer/">Takayo Fischer</a>, <a href="/tvorca/547784-rick-mali/">Rick Mali</a>, <a href="/tvorca/572314-rohan-mehra/">Rohan Mehra</a>, <a href="/tvorca/574739-thomas-isao-morinaka/">Thomas Isao Morinaka</a>, <a href="/tvorca/760073-max-valentine/">Max Valentine</a>, <a href="/tvorca/849636-hans-hernke/">Hans Hernke</a></span>&nbsp;<span class="span-more-small">(<a href="#" class="more" data-text="menej" data-show=".more-member-1">viac</a>)</span>
            #                                             </div>
            actor_section = creators.xpath(".//h4[contains(., 'Hrajú') or contains(., 'Hrají:') or contains(., 'Hrají')]")
            if actor_section:
                actor_links = actor_section.xpath('../following-sibling::span[1]//a/@href').getall()
                actors = [href.split('/')[-1] for href in actor_links if href and '/tvorca/' in href or '/tvurce/' in href]
            print('--------- ACTOR SECTION DEBUG ---------')
            print(actor_section.get())
            print('---------------------------------------')

        movie = MovieItem(
            csfd_id=csfd_id,
            title=title,
            year=year,
            description=description,
            genres=genres,
            rating=rating,
            poster_url=poster_url,
            directors=directors,
            actors=actors,
        )

        # Offer to callback (e.g., saving function) and also yield the item
        if self.item_callback:
            try:
                self.item_callback(dict(movie))
            except Exception:
                # don't break the spider if callback fails
                self.logger.exception('item_callback failed')

        yield movie

    def parse_person(self, response: scrapy.http.Response):
        csfd_id = response.url.rstrip('/').split('/')[-1]
        name = response.css('h1::text').get() or ''
        name = name.strip()
        birth_date = response.css('div.birth-date::text').get()
        bio = response.css('div.biography::text').get() or ''

        person = PersonItem(csfd_id=csfd_id, name=name, birth_date=birth_date, bio=bio)

        if self.item_callback:
            try:
                self.item_callback(dict(person))
            except Exception:
                self.logger.exception('item_callback failed')

        yield person


def crawl_urls(urls: Iterable[str], item_callback: Optional[Callable] = None, user_agent: Optional[str] = None, output_json: Optional[str] = None) -> None:
    """Run the CSFDSpider for the given URLs. This blocks until the crawl finishes.

    Args:
        urls: iterable of absolute URLs to crawl
        item_callback: optional callable that receives each parsed item dict
        user_agent: optional user agent string
        output_json: optional path to a JSON Lines file where each parsed item will be appended
    """
    settings = {
        'LOG_ENABLED': True,
        'CONCURRENT_REQUESTS': 8,
    }
    user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36'
    if user_agent:
        settings['USER_AGENT'] = user_agent

    # Build a composite callback: write to JSON (if requested) and call user callback
    writer = None
    if output_json:
        # Open file in append mode; we will write one JSON object per line (JSON Lines)
        f = open(output_json, 'a', encoding='utf-8')

        def _write_item(item: dict) -> None:
            try:
                f.write(json.dumps(item, ensure_ascii=False) + '\n')
                f.flush()
            except Exception:
                # Best-effort write; do not crash the spider
                pass

        writer = _write_item

    def _composite_callback(item: dict) -> None:
        # write to JSON first (if enabled)
        if writer:
            writer(item)
        # then call user's callback
        if item_callback:
            try:
                item_callback(item)
            except Exception:
                # swallow exceptions from user callback so spider continues
                pass

    process = CrawlerProcess(settings=settings)
    process.crawl(CSFDSpider, start_urls=list(urls), item_callback=_composite_callback)
    process.start()  # blocks until finished
    if output_json:
        try:
            f.close()
        except Exception:
            pass


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Run Scrapy parser for CSFD pages (one-off).')
    parser.add_argument('--url', '-u', action='append', help='URL to crawl (may be repeated)', required=True)
    parser.add_argument('--out', '-o', help='Optional JSON output file (JSON Lines). Temporary: later save directly to DB.')
    args = parser.parse_args()

    def print_cb(item: dict):
        print('PARSED ITEM:', item)

    crawl_urls(args.url, item_callback=print_cb, output_json=args.out)
