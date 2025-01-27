from django.contrib import admin
from .models import Movie, Person

@admin.register(Movie)
class MovieAdmin(admin.ModelAdmin):
    list_display = ('title', 'year', 'rating')
    list_filter = ('year', 'genres')
    search_fields = ('title', 'description')

@admin.register(Person)
class PersonAdmin(admin.ModelAdmin):
    list_display = ('name', 'birth_date')
    search_fields = ('name', 'bio')
