from __future__ import annotations

from tortoise import fields, models


class Country(models.Model):
    id = fields.IntField(pk=True)
    name = fields.CharField(max_length=50, null=True)

    films: fields.ReverseRelation["Film"]

    class Meta:
        table = "country"


class Genre(models.Model):
    id = fields.IntField(pk=True)
    name = fields.CharField(max_length=60, null=True)

    films: fields.ManyToManyRelation["Film"]

    class Meta:
        table = "genre"


class Film(models.Model):
    id = fields.IntField(pk=True)
    title = fields.CharField(max_length=50)
    original_title = fields.CharField(max_length=50, null=True)
    language = fields.CharField(max_length=50, null=True)
    release_year = fields.IntField(null=True)
    rating = fields.FloatField(null=True)
    num_votes = fields.IntField(null=True)
    url = fields.CharField(max_length=100, null=True)

    country: fields.ForeignKeyRelation[Country] = fields.ForeignKeyField(
        "models.Country",
        related_name="films",
        null=True,
        on_delete=fields.SET_NULL,
    )

    genres: fields.ManyToManyRelation[Genre] = fields.ManyToManyField(
        "models.Genre",
        related_name="films",
        through="film_genre",
    )

    person_in_films: fields.ReverseRelation["PersonInFilm"]

    class Meta:
        table = "film"


class Person(models.Model):
    id = fields.IntField(pk=True)
    name = fields.CharField(max_length=60)
    birth_date = fields.DateField(null=True)
    url = fields.CharField(max_length=100, null=True)
    occupation = fields.CharField(max_length=50, null=True)

    person_in_films: fields.ReverseRelation["PersonInFilm"]

    class Meta:
        table = "person"


class PersonInFilm(models.Model):
    films: fields.ForeignKeyRelation[Film] = fields.ForeignKeyField(
        "models.Film",
        related_name="person_in_films",
        on_delete=fields.CASCADE,
    )
    persons: fields.ForeignKeyRelation[Person] = fields.ForeignKeyField(
        "models.Person",
        related_name="film_roles",
        on_delete=fields.CASCADE,
    )
    role = fields.CharField(max_length=30, null=True)

    class Meta:
        table = "person_in_film"
        unique_together = (("films", "persons"),)


class MovieLink(models.Model):
    id = fields.IntField(pk=True)
    url = fields.CharField(max_length=100, null=True)
    status = fields.CharField(max_length=15, null=True)

    class Meta:
        table = "movie_link"
