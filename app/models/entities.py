from __future__ import annotations

from tortoise import fields
from tortoise.models import Model


class Country(Model):
    id = fields.IntField(pk=True)
    name = fields.CharField(max_length=50)
    films: fields.ReverseRelation["Film"]

    class Meta:
        table = "country"

    def __str__(self) -> str:  # pragma: no cover
        return self.name or f"Country {self.id}"


class Genre(Model):
    id = fields.IntField(pk=True)
    name = fields.CharField(max_length=60)
    films: fields.ReverseRelation["Film"]

    class Meta:
        table = "genre"

    def __str__(self) -> str:  # pragma: no cover
        return self.name or f"Genre {self.id}"


class Person(Model):
    id = fields.IntField(pk=True)
    name = fields.CharField(max_length=60)
    birth_date = fields.DateField(null=True)
    url = fields.CharField(max_length=100)
    occupation = fields.CharField(max_length=50)
    film_links: fields.ReverseRelation["PersonInFilm"]

    class Meta:
        table = "person"

    def __str__(self) -> str:  # pragma: no cover
        return self.name


class Film(Model):
    id = fields.IntField(pk=True)
    title = fields.CharField(max_length=50)
    original_title = fields.CharField(max_length=50)
    country: fields.ForeignKeyRelation[Country] = fields.ForeignKeyField(
        "models.Country",
        related_name="films",
        null=True,
        source_field="country",
        on_delete=fields.SET_NULL,
    )
    language = fields.CharField(max_length=50)
    release_year = fields.IntField(null=True)
    rating = fields.FloatField(null=True)
    num_votes = fields.IntField(null=True)
    genre: fields.ForeignKeyRelation[Genre] = fields.ForeignKeyField(
        "models.Genre",
        related_name="primary_films",
        null=True,
        source_field="genre_id",
        on_delete=fields.SET_NULL,
    )
    url = fields.CharField(max_length=100)
    person_links: fields.ReverseRelation["PersonInFilm"]
    genres: fields.ManyToManyRelation[Genre] = fields.ManyToManyField(
        "models.Genre",
        related_name="films",
        through="film_genre",
        forward_key="film",
        backward_key="genre",
    )

    class Meta:
        table = "film"

    def __str__(self) -> str:  # pragma: no cover
        if self.release_year:
            return f"{self.title} ({self.release_year})"
        return self.title


class PersonInFilm(Model):
    film: fields.ForeignKeyRelation[Film] = fields.ForeignKeyField(
        "models.Film",
        related_name="person_links",
        source_field="films",
        on_delete=fields.CASCADE,
    )
    person: fields.ForeignKeyRelation[Person] = fields.ForeignKeyField(
        "models.Person",
        related_name="film_links",
        source_field="persons",
        on_delete=fields.CASCADE,
    )
    role = fields.CharField(max_length=30)

    class Meta:
        table = "person_in_film"
        unique_together = ("film", "person")

    def __str__(self) -> str:  # pragma: no cover
        return f"{self.person_id} -> {self.film_id} ({self.role})"


class MovieLink(Model):
    id = fields.IntField(pk=True)
    url = fields.CharField(max_length=100)
    status = fields.CharField(max_length=15)

    class Meta:
        table = "movie_links"

    def __str__(self) -> str:  # pragma: no cover
        return self.url
