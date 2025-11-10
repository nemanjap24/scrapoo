from django.db import models


"""
Models mapped from the provided SQL schema.

Mapping summary:
- country -> Country (country_id PK, name)
- genre -> Genre (genre_id PK, name)
- person -> Person (person_id PK, name, birth_date, birth_place, url, occupation)
- film -> Film (film_id PK, title, original_title, country FK, language, release_year, rating, num_votes, genre FK, person FK, url)
- role_in_film -> RoleInFilm (film FK, person FK, role ENUM)
- movie_links -> MovieLink (movie_link_id PK, url, status)

The file also keeps a lightweight `Movie` compatibility model and a `LegacyPerson` proxy
to minimize changes in existing code that referenced the old models.
"""


class Country(models.Model):
    country_id = models.IntegerField(primary_key=True)
    name = models.CharField(max_length=60)

    class Meta:
        db_table = 'country'

    def __str__(self):
        return self.name


class Genre(models.Model):
    genre_id = models.IntegerField(primary_key=True)
    name = models.CharField(max_length=60, blank=True)

    class Meta:
        db_table = 'genre'

    def __str__(self):
        return self.name or f"Genre {self.genre_id}"


class Person(models.Model):
    person_id = models.IntegerField(primary_key=True)
    name = models.CharField(max_length=60, blank=True)
    birth_date = models.DateField(null=True, blank=True)
    birth_place = models.CharField(max_length=50, blank=True)
    url = models.CharField(max_length=50, blank=True)
    occupation = models.CharField(max_length=50, blank=True)

    class Meta:
        db_table = 'person'

    def __str__(self):
        return self.name or f"Person {self.person_id}"


class Film(models.Model):
    film_id = models.IntegerField(primary_key=True)
    title = models.CharField(max_length=50)
    original_title = models.CharField(max_length=50)
    country = models.ForeignKey(Country, null=True, blank=True, on_delete=models.SET_NULL, db_column='country_id', related_name='films')
    language = models.CharField(max_length=50, blank=True)
    release_year = models.IntegerField(null=True, blank=True)
    rating = models.FloatField(null=True, blank=True)
    num_votes = models.IntegerField(null=True, blank=True)
    genre = models.ForeignKey(Genre, null=True, blank=True, on_delete=models.SET_NULL, db_column='genre_id', related_name='films')
    person = models.ForeignKey(Person, null=True, blank=True, on_delete=models.SET_NULL, db_column='person_id', related_name='films')
    url = models.CharField(max_length=100, blank=True)

    class Meta:
        db_table = 'film'

    def __str__(self):
        return f"{self.title} ({self.release_year})" if self.release_year else self.title


class RoleInFilm(models.Model):
    ROLE_CHOICES = [
        ('actor', 'Actor'),
        ('director', 'Director'),
        ('writer', 'Writer'),
        ('producer', 'Producer'),
        ('actor_writer', 'Actor and Writer'),
    ]

    film = models.ForeignKey(Film, on_delete=models.CASCADE, db_column='film_id')
    person = models.ForeignKey(Person, on_delete=models.CASCADE, db_column='person_id')
    role = models.CharField(max_length=30, choices=ROLE_CHOICES)

    class Meta:
        db_table = 'role_in_film'
        unique_together = (('film', 'person'),)

    def __str__(self):
        return f"{self.person} as {self.role} in {self.film}"


class MovieLink(models.Model):
    movie_link_id = models.IntegerField(primary_key=True)
    url = models.CharField(max_length=100)
    status = models.CharField(max_length=100)

    class Meta:
        db_table = 'movie_links'

    def __str__(self):
        return self.url

class Movie(models.Model):
    # keep a lightweight compatibility Movie model built on top of Film
    film = models.OneToOneField(Film, on_delete=models.CASCADE, related_name='movie', primary_key=True)

    def __str__(self):
        return str(self.film)

