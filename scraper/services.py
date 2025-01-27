import os
import time
from typing import Optional, Dict, List
import requests
from bs4 import BeautifulSoup
from datetime import datetime
from django.conf import settings
from .models import Movie, Person

class CSFDScraper:
    def __init__(self):
        self.base_url = os.getenv('BASE_URL')
        self.magic_url = os.getenv('MAGIC_URL')
        self.request_delay = int(os.getenv('REQUEST_DELAY', 2))
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (compatible; ScrapooCrawler/1.0; +https://github.com/username/scrapoo)'
        })

    def _make_request(self, url: str) -> Optional[BeautifulSoup]:
        """Make a request to CSFD with rate limiting and return BeautifulSoup object"""
        try:
            time.sleep(self.request_delay)  # Rate limiting
            response = self.session.get(url)
            response.raise_for_status()
            return BeautifulSoup(response.text, 'html.parser')
        except Exception as e:
            print(f"Error fetching {url}: {str(e)}")
            return None

    def scrape_movie(self, movie_url: str) -> Optional[Dict]:
        """Scrape movie details from a CSFD movie page"""
        soup = self._make_request(movie_url)
        if not soup:
            return None

        # Extract basic movie data
        title_elem = soup.select_one('h1')
        if not title_elem:
            return None

        # Extract title and year
        title_text = title_elem.text.strip()
        year = None
        if '(' in title_text and ')' in title_text:
            title = title_text[:title_text.rfind('(')].strip()
            year_match = title_text[title_text.rfind('(')+1:title_text.rfind(')')]
            try:
                year = int(year_match)
            except ValueError:
                pass
        else:
            title = title_text

        # Extract description
        plot_elem = soup.select_one('div.plot-full')
        description = plot_elem.text.strip() if plot_elem else ''

        # Extract genres
        genre_elems = soup.select('div.genres span.genre')
        genres = [genre.text.strip() for genre in genre_elems]

        # Extract rating
        rating_elem = soup.select_one('div.rating-average')
        rating = None
        if rating_elem:
            try:
                rating = float(rating_elem.text.strip().replace('%', '')) / 100
            except ValueError:
                pass

        # Extract poster URL
        poster_elem = soup.select_one('div.film-posters img')
        poster_url = poster_elem.get('src') if poster_elem else ''

        # Extract directors and actors
        creators_elem = soup.select_one('div.creators')
        directors = []
        actors = []
        if creators_elem:
            # Extract directors
            director_section = creators_elem.find('div', string=lambda text: 'Režie:' in str(text) if text else False)
            if director_section:
                director_links = director_section.find_next('span').find_all('a')
                directors = [link['href'].split('/')[-1] for link in director_links if '/tvurce/' in link['href']]

            # Extract actors
            actor_section = creators_elem.find('div', string=lambda text: 'Hrají:' in str(text) if text else False)
            if actor_section:
                actor_links = actor_section.find_next('span').find_all('a')
                actors = [link['href'].split('/')[-1] for link in actor_links if '/tvurce/' in link['href']][:10]  # Limit to top 10 actors

        movie_data = {
            'csfd_id': movie_url.split('/')[-1],
            'title': title,
            'year': year,
            'description': description,
            'genres': genres,
            'rating': rating,
            'poster_url': poster_url,
            'directors': directors,
            'actors': actors
        }

        return movie_data

    def scrape_person(self, person_url: str) -> Optional[Dict]:
        """Scrape person details from a CSFD person page"""
        soup = self._make_request(person_url)
        if not soup:
            return None

        # Extract person data (implement detailed scraping logic here)
        person_data = {
            'csfd_id': person_url.split('/')[-1],
            'name': '',  # Extract name
            'birth_date': None,  # Extract birth date
            'bio': ''  # Extract biography
        }

        return person_data

    def save_movie(self, movie_data: Dict) -> Optional[Movie]:
        """Save movie data to database"""
        try:
            movie, created = Movie.objects.update_or_create(
                csfd_id=movie_data['csfd_id'],
                defaults={
                    'title': movie_data['title'],
                    'year': movie_data['year'],
                    'description': movie_data['description'],
                    'genres': movie_data['genres'],
                    'rating': movie_data['rating'],
                    'poster_url': movie_data['poster_url']
                }
            )
            return movie
        except Exception as e:
            print(f"Error saving movie {movie_data['csfd_id']}: {str(e)}")
            return None

    def save_person(self, person_data: Dict) -> Optional[Person]:
        """Save person data to database"""
        try:
            person, created = Person.objects.update_or_create(
                csfd_id=person_data['csfd_id'],
                defaults={
                    'name': person_data['name'],
                    'birth_date': person_data['birth_date'],
                    'bio': person_data['bio']
                }
            )
            return person
        except Exception as e:
            print(f"Error saving person {person_data['csfd_id']}: {str(e)}")
            return None

    def fetch_movie_links(self, url: str, max_pages: int, current_page: int = 1, movie_links: List[str] = None) -> List[Dict]:
        """Fetch movie links from CSFD top charts and scrape detailed movie data"""
        if movie_links is None:
            movie_links = []

        if current_page > max_pages:
            return movie_links

        print(f"Fetching page {current_page}")

        soup = self._make_request(url)
        if not soup:
            return movie_links

        movies = soup.find_all('article', class_='article')
        for movie in movies:
            link = movie.find('a', class_='film-title-name', href=True)
            if link and link['href']:
                movie_url = f"{self.base_url}{link['href']}"
                movie_data = self.scrape_movie(movie_url)
                if movie_data:
                    movie = self.save_movie(movie_data)
                    if movie:
                        print(f"Successfully scraped and saved movie: {movie.title}")
                    else:
                        print(f"Failed to save movie from URL: {movie_url}")
                else:
                    print(f"Failed to scrape movie from URL: {movie_url}")

        next_page = soup.find('a', class_='page-next')
        if next_page and next_page.get('href'):
            next_url = f"{self.base_url}{next_page['href']}"
            return self.fetch_movie_links(next_url, max_pages, current_page + 1, movie_links)

        return movie_links