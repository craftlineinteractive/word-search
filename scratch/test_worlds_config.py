import json
import os
import re
import random
from nltk.corpus import wordnet as wn
from nltk.stem import PorterStemmer

ps = PorterStemmer()
random.seed(42)

DATA_DIR = r"e:\Craftline Interactive\word-puzzle\assets\data"

# 30 Worlds with re-ordered animal themes as requested by the user:
# Birds: World 18, Pets: World 22, Wild Animals: World 26
WORLDS_CONFIG = [
    {"id": 1, "key": "food", "title": "Food", "iconAsset": "assets/chapter_images/food.png", "themeColor": 4294924066, "legacy": "chapter_01_food.json", "target": "world_01_food.json"},
    {"id": 2, "key": "holiday", "title": "Holiday", "iconAsset": "assets/chapter_images/holiday.png", "themeColor": 4278238420, "legacy": "chapter_02_holiday.json", "target": "world_02_holiday.json"},
    {"id": 3, "key": "jobs", "title": "Jobs", "iconAsset": "assets/chapter_images/jobs.png", "themeColor": 4282339765, "legacy": "chapter_03_jobs.json", "target": "world_03_jobs.json"},
    {"id": 4, "key": "electronics", "title": "Electronics", "iconAsset": "assets/chapter_images/electronics.png", "themeColor": 4280391411, "legacy": "chapter_04_electronics.json", "target": "world_04_electronics.json"},
    {"id": 5, "key": "books", "title": "Books", "iconAsset": "assets/chapter_images/books.png", "themeColor": 4286141256, "legacy": "chapter_05_books.json", "target": "world_05_books.json"},
    {"id": 6, "key": "games", "title": "Games", "iconAsset": "assets/chapter_images/games.png", "themeColor": 4288423856, "legacy": "chapter_06_games.json", "target": "world_06_games.json"},
    {"id": 7, "key": "plants", "title": "Plants", "iconAsset": "assets/chapter_images/plants.png", "themeColor": 4283215696, "legacy": "chapter_07_plants.json", "target": "world_07_plants.json"},
    {"id": 8, "key": "painting", "title": "Painting", "iconAsset": "assets/chapter_images/painting.png", "themeColor": 4294940672, "legacy": "chapter_08_painting.json", "target": "world_08_painting.json"},
    {"id": 9, "key": "words", "title": "Words", "iconAsset": "assets/chapter_images/words.png", "themeColor": 4284955319, "legacy": "chapter_09_words.json", "target": "world_09_words.json"},
    {"id": 10, "key": "professional", "title": "Professional", "iconAsset": "assets/chapter_images/professional.png", "themeColor": 4284511627, "legacy": "chapter_10_professional.json", "target": "world_10_professional.json"},
    {"id": 11, "key": "religion", "title": "Religion", "iconAsset": "assets/chapter_images/religion.png", "themeColor": 4287460963, "legacy": "chapter_11_religion.json", "target": "world_11_religion.json"},
    {"id": 12, "key": "music", "title": "Music", "iconAsset": "assets/chapter_images/music.png", "themeColor": 4293467747, "legacy": "chapter_12_music.json", "target": "world_12_music.json"},
    {"id": 13, "key": "hobby", "title": "Hobby", "iconAsset": "assets/chapter_images/hobby.png", "themeColor": 4294924066, "legacy": "chapter_13_hobby.json", "target": "world_13_hobby.json"},
    {"id": 14, "key": "nature", "title": "Nature", "iconAsset": "assets/chapter_images/nature.png", "themeColor": 4281236786, "legacy": "chapter_14_nature.json", "target": "world_14_nature.json"},
    {"id": 15, "key": "tournament", "title": "Tournament", "iconAsset": "assets/chapter_images/tournament.png", "themeColor": 4294951175, "legacy": "chapter_15_tournament.json", "target": "world_15_tournament.json"},
    {"id": 16, "key": "education", "title": "Education", "iconAsset": "assets/chapter_images/education.png", "themeColor": 4282339765, "legacy": "chapter_16_education.json", "target": "world_16_education.json"},
    {"id": 17, "key": "technology", "title": "Technology", "iconAsset": "assets/chapter_images/technology.png", "themeColor": 4278228616, "legacy": "chapter_17_technology.json", "target": "world_17_technology.json"},
    # Animal World 1: Birds at 18
    {"id": 18, "key": "birds", "title": "Birds", "iconAsset": "assets/chapter_images/birds.png", "themeColor": 4278430204, "legacy": "chapter_18_birds.json", "target": "world_18_birds.json"},
    {"id": 19, "key": "weather", "title": "Weather", "iconAsset": "assets/chapter_images/weather.png", "themeColor": 4278234305, "legacy": "chapter_22_weather.json", "target": "world_19_weather.json"},
    {"id": 20, "key": "ocean", "title": "Ocean", "iconAsset": "assets/chapter_images/ocean.png", "themeColor": 4278351569, "legacy": "chapter_21_ocean.json", "target": "world_20_ocean.json"},
    {"id": 21, "key": "sports", "title": "Sports", "iconAsset": "assets/chapter_images/sports.png", "themeColor": 4283215696, "legacy": "chapter_23_sports.json", "target": "world_21_sports.json"},
    # Animal World 2: Pets at 22
    {"id": 22, "key": "pets", "title": "Pets", "iconAsset": "assets/chapter_images/pets.png", "themeColor": 4294940672, "legacy": "chapter_19_pets.json", "target": "world_22_pets.json"},
    {"id": 23, "key": "vehicles", "title": "Vehicles", "iconAsset": "assets/chapter_images/vehicles.png", "themeColor": 4294197302, "legacy": "chapter_24_vehicles.json", "target": "world_23_vehicles.json"},
    {"id": 24, "key": "city", "title": "City", "iconAsset": "assets/chapter_images/city.png", "themeColor": 4282339765, "legacy": "chapter_25_city.json", "target": "world_24_city.json"},
    {"id": 25, "key": "home", "title": "Home", "iconAsset": "assets/chapter_images/home.png", "themeColor": 4287460963, "legacy": "chapter_26_home.json", "target": "world_25_home.json"},
    # Animal World 3: Wild Animals at 26
    {"id": 26, "key": "wild-animals", "title": "Wild Animals", "iconAsset": "assets/chapter_images/wild-animals.png", "themeColor": 4293284096, "legacy": "chapter_20_wild-animals.json", "target": "world_26_wild-animals.json"},
    {"id": 27, "key": "fashion", "title": "Fashion", "iconAsset": "assets/chapter_images/fashion.png", "themeColor": 4293467747, "legacy": "chapter_27_fashion.json", "target": "world_27_fashion.json"},
    {"id": 28, "key": "entertainment", "title": "Entertainment", "iconAsset": "assets/chapter_images/entertainment.png", "themeColor": 4294924066, "legacy": "chapter_28_entertainment.json", "target": "world_28_entertainment.json"},
    {"id": 29, "key": "adventure", "title": "Adventure", "iconAsset": "assets/chapter_images/adventure.png", "themeColor": 4294940672, "legacy": "chapter_29_adventure.json", "target": "world_29_adventure.json"},
    {"id": 30, "key": "fantasy", "title": "Fantasy", "iconAsset": "assets/chapter_images/fantasy.png", "themeColor": 4288423856, "legacy": "chapter_30_fantasy.json", "target": "world_30_fantasy.json"}
]

print("Initialized Worlds configuration with animal separation:")
for cfg in WORLDS_CONFIG:
    print(f"World {cfg['id']:2d}: {cfg['title']:<15} (from {cfg['legacy']} -> {cfg['target']})")
