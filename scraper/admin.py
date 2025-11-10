from django.contrib import admin
from .models import Person, Film


@admin.register(Film)
class FilmAdmin(admin.ModelAdmin):
    list_display = ('title', 'release_year', 'rating')
    list_filter = ('release_year', 'language', 'country')
    search_fields = ('title', 'original_title', 'url')

@admin.register(Person)
class PersonAdmin(admin.ModelAdmin):
    list_display = ('name', 'birth_date')
    search_fields = ('name',)
