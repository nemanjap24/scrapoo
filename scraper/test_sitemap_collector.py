import unittest
from unittest.mock import patch
import io
import json
from scraper import sitemap_collector as sc


class TestSitemapCollector(unittest.TestCase):
    def setUp(self):
        # example robots pointing to a sitemapindex
        self.robots = "Sitemap: https://example.com/sitemap_index.xml\n"
        # sitemap_index contains two sitemaps
        self.sitemap_index_xml = '''<?xml version="1.0" encoding="UTF-8"?>
        <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
          <sitemap>
            <loc>https://example.com/sitemap1.xml</loc>
          </sitemap>
          <sitemap>
            <loc>https://example.com/sitemap2.xml</loc>
          </sitemap>
        </sitemapindex>'''
        # sitemap1 contains film urls
        self.sitemap1 = '''<?xml version="1.0" encoding="UTF-8"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
          <url><loc>https://www.csfd.sk/film/12345-example/prehlad/</loc></url>
          <url><loc>https://www.csfd.sk/film/23456-other/prehlad/</loc></url>
        </urlset>'''
        # sitemap2 contains creator and other urls
        self.sitemap2 = '''<?xml version="1.0" encoding="UTF-8"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
          <url><loc>https://www.csfd.sk/tvorca/54321-author/prehlad/</loc></url>
          <url><loc>https://www.csfd.sk/some/other/page</loc></url>
        </urlset>'''

    @patch('scraper.sitemap_collector.fetch_text')
    @patch('scraper.sitemap_collector.fetch_bytes')
    def test_collect_and_filter(self, mock_fetch_bytes, mock_fetch_text):
        # Mock network responses
        def fetch_text_side(url, timeout=...):
            return self.robots

        def fetch_bytes_side(url, timeout=...):
            if url.endswith('sitemap_index.xml'):
                return self.sitemap_index_xml.encode('utf-8')
            if url.endswith('sitemap1.xml'):
                return self.sitemap1.encode('utf-8')
            if url.endswith('sitemap2.xml'):
                return self.sitemap2.encode('utf-8')
            raise RuntimeError('unexpected url')

        mock_fetch_text.side_effect = fetch_text_side
        mock_fetch_bytes.side_effect = fetch_bytes_side

        sitemaps = sc.collect_all_sitemaps('https://example.com/robots.txt')
        self.assertIn('https://example.com/sitemap1.xml', sitemaps)
        self.assertIn('https://example.com/sitemap2.xml', sitemaps)

        urls = sc.collect_all_urls_from_sitemaps(sorted(sitemaps))
        self.assertTrue(any('/film/12345' in u for u in urls))
        self.assertTrue(any('/tvorca/54321' in u for u in urls))

        # Test filtering logic
        films = [u for u in urls if '/film/' in u]
        creators = [u for u in urls if '/tvorca/' in u]
        self.assertEqual(len(films), 2)
        self.assertEqual(len(creators), 1)

    @patch('scraper.sitemap_collector.fetch_text')
    @patch('scraper.sitemap_collector.fetch_bytes')
    def test_only_flags(self, mock_fetch_bytes, mock_fetch_text):
        mock_fetch_text.return_value = self.robots
        mock_fetch_bytes.side_effect = lambda url, timeout=...: (
            self.sitemap_index_xml.encode('utf-8') if url.endswith('sitemap_index.xml') else
            self.sitemap1.encode('utf-8') if url.endswith('sitemap1.xml') else
            self.sitemap2.encode('utf-8') if url.endswith('sitemap2.xml') else b''
        )

        sitemaps = sc.collect_all_sitemaps('https://example.com/robots.txt')
        urls = sc.collect_all_urls_from_sitemaps(sorted(sitemaps))

        # simulate writing with only-films
        films = [u for u in sorted(urls) if '/film/' in u]
        creators = [u for u in sorted(urls) if '/tvorca/' in u]
        self.assertEqual(len(films), 2)
        self.assertEqual(len(creators), 1)


if __name__ == '__main__':
    unittest.main()
