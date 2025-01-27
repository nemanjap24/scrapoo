from django.db import models

class Person(models.Model):
    csfd_id = models.CharField(max_length=50, unique=True)
    name = models.CharField(max_length=255)
    birth_date = models.DateField(null=True, blank=True)
    bio = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

class Movie(models.Model):
    csfd_id = models.CharField(max_length=50, unique=True)
    title = models.CharField(max_length=255)
    original_title = models.CharField(max_length=255, blank=True)
    year = models.IntegerField(null=True, blank=True)
    description = models.TextField(blank=True)
    genres = models.JSONField(default=list)
    rating = models.FloatField(null=True, blank=True)
    poster_url = models.URLField(max_length=500, blank=True)
    directors = models.ManyToManyField(Person, related_name='directed_movies')
    actors = models.ManyToManyField(Person, related_name='acted_in_movies')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.title} ({self.year})"

# class MovieLinks(models.Model):
