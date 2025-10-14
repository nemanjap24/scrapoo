# sitemap_collector

Standalone script/module to collect URLs from robots.txt -> sitemaps -> nested sitemaps.

Features

- Fetches `robots.txt` and discovers sitemap files (supports nested sitemapindex files).
- Fetches sitemap XML or `.xml.gz`, extracts `<loc>` URLs.
- Concurrent sitemap downloading and parsing (ThreadPoolExecutor).
- Supports output in JSON or CSV formats.
- Can save only film URLs (`/film/`) and creator URLs (`/tvorca/`).
- Optionally rotates existing output files into `archive/` to avoid overwriting.
- Basic logging with `--verbose` and `--quiet`.

Usage

Run the module from the project root:

```bash
python3 -m scraper.sitemap_collector [robots_url] [options]
```

Options of interest

- `--out, -o`: output file path (json or csv depending on `--format`).
- `--format`: `json` (default) or `csv`.
- `--workers, -w`: number of concurrent workers (default 8).
- `--verbose, -v`: verbose logging (INFO/DEBUG messages).
- `--quiet`: reduce logging output.
- `--only-film-creator`: only save URLs that include `/film/` or `/tvorca/`.
- `--rotate-existing`: if the output file exists, move it into `archive/` with a timestamp before writing.

Examples

Save JSON with only films and creators, rotate existing file:

```bash
python3 -m scraper.sitemap_collector --only-film-creator --rotate-existing --out csfd_films_creators.json
```

Save CSV with types (film/creator/other):

```bash
python3 -m scraper.sitemap_collector --format csv --out all_urls.csv
```

Notes & research usage

- The script will retry network requests without SSL verification if local CA bundles are missing. This is only intended for research environments; for production, ensure proper certificate verification.
- For very large sites (millions of URLs) prefer using lower verbosity and larger `--workers`, and consider running on a machine with enough memory/disk.

License

- MIT-style: use in your research, cite as needed.
