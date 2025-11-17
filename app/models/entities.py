from tortoise import fields
from tortoise.models import Model


class Country(Model):
    id = fields.IntField(pk=True)
    name = fields.CharField(max_length=50, null=True)

    class Meta:
        table = "country"

    def __str__(self) -> str:  # pragma: no cover
        return self.name or f"Country {self.id}"


class Genre(Model):
    id = fields.IntField(pk=True)
    name = fields.CharField(max_length=60, null=True)

    class Meta:
        table = "genre"

    def __str__(self) -> str:  # pragma: no cover
        return self.name or f"Genre {self.id}"


class Person(Model):
    id = fields.IntField(pk=True)
    name = fields.CharField(max_length=60)
    birth_date = fields.DateField(null=True)
    url = fields.CharField(max_length=100, null=True)
    occupation = fields.CharField(max_length=50, null=True)

    class Meta:
        table = "person"

    def __str__(self) -> str:  # pragma: no cover
        return self.name


class Film(Model):
    id = fields.IntField(pk=True)
    title = fields.CharField(max_length=50)
    original_title = fields.CharField(max_length=50, null=True)
    country: fields.ForeignKeyRelation[Country] = fields.ForeignKeyField(
        "models.Country", related_name="films", null=True
    )
    language = fields.CharField(max_length=50, null=True)
    release_year = fields.IntField(null=True)
    rating = fields.FloatField(null=True)
    num_votes = fields.IntField(null=True)
    genre: fields.ForeignKeyRelation[Genre] = fields.ForeignKeyField(
        "models.Genre", related_name="films", null=True
    )
    url = fields.CharField(max_length=100, null=True)

    class Meta:
        table = "film"

    def __str__(self) -> str:  # pragma: no cover
        if self.release_year:
            return f"{self.title} ({self.release_year})"
        return self.title


class PersonInFilm(Model):
    film: fields.ForeignKeyRelation[Film] = fields.ForeignKeyField(
        "models.Film", related_name="person_links"
    )
    person: fields.ForeignKeyRelation[Person] = fields.ForeignKeyField(
        "models.Person", related_name="film_links"
    )
    role = fields.CharField(max_length=30, null=True)

    class Meta:
        table = "role_in_film"
        unique_together = ("film", "person")

    def __str__(self) -> str:  # pragma: no cover
        return f"{self.person_id} -> {self.film_id} ({self.role})"
