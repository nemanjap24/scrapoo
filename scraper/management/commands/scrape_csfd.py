import argparse
from django.core.management.base import BaseCommand
from scraper.services import CSFDScraper

class Command(BaseCommand):
    help = 'Scrape movies and people from CSFD'

    def add_arguments(self, parser):
        parser.add_argument('--movie', type=str, help='URL of the movie to scrape')
        parser.add_argument('--person', type=str, help='URL of the person to scrape')
        parser.add_argument('--charts', action='store_true', help='Scrape movies from CSFD charts')
        parser.add_argument('--max-pages', type=int, default=1, help='Maximum number of chart pages to scrape')

    def handle(self, *args, **options):
        scraper = CSFDScraper()

        if options['charts']:
            self.stdout.write('Starting to scrape movies from CSFD charts')
            max_pages = options['max_pages']
            charts_url = f"{scraper.magic_url}"
            movie_links = scraper.fetch_movie_links(charts_url, max_pages)
            self.stdout.write(self.style.SUCCESS(f'Finished scraping {len(movie_links)} movies from charts'))
            print(movie_links)
            # start asynchronously scraping movies
            return

        if options['movie']:
            self.stdout.write(f"Scraping movie: {options['movie']}")
            movie_data = scraper.scrape_movie(options['movie'])
            if movie_data:
                movie = scraper.save_movie(movie_data)
                if movie:
                    self.stdout.write(self.style.SUCCESS(f'Successfully scraped movie: {movie.title}'))
                else:
                    self.stdout.write(self.style.ERROR('Failed to save movie'))
            else:
                self.stdout.write(self.style.ERROR('Failed to scrape movie'))

        if options['person']:
            self.stdout.write(f"Scraping person: {options['person']}")
            person_data = scraper.scrape_person(options['person'])
            if person_data:
                person = scraper.save_person(person_data)
                if person:
                    self.stdout.write(self.style.SUCCESS(f'Successfully scraped person: {person.name}'))
                else:
                    self.stdout.write(self.style.ERROR('Failed to save person'))
            else:
                self.stdout.write(self.style.ERROR('Failed to scrape person'))

        if not options['movie'] and not options['person'] and not options['charts']:
            self.stdout.write(self.style.ERROR('Please provide either --movie, --person, or --charts argument'))