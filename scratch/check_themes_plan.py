import json
import os
import re
from nltk.corpus import wordnet as wn
from nltk.stem import PorterStemmer

ps = PorterStemmer()

# Verify mapping for all 30 themes
themes = [
    ("food", "Food"),
    ("holiday", "Holiday"),
    ("jobs", "Jobs"),
    ("electronics", "Electronics"),
    ("books", "Books"),
    ("games", "Games"),
    ("plants", "Plants"),
    ("painting", "Painting"),
    ("words", "Words"),
    ("professional", "Professional"),
    ("religion", "Religion"),
    ("music", "Music"),
    ("hobby", "Hobby"),
    ("nature", "Nature"),
    ("tournament", "Tournament"),
    ("education", "Education"),
    ("technology", "Technology"),
    ("birds", "Birds"),
    ("weather", "Weather"),
    ("ocean", "Ocean"),
    ("sports", "Sports"),
    ("pets", "Pets"),
    ("vehicles", "Vehicles"),
    ("city", "City"),
    ("home", "Home"),
    ("wild-animals", "Wild Animals"),
    ("fashion", "Fashion"),
    ("entertainment", "Entertainment"),
    ("adventure", "Adventure"),
    ("fantasy", "Fantasy")
]

print(f"Total themes to generate: {len(themes)}")
