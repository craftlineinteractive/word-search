import json
import os

ch_files = {
    1: "assets/data/chapter_01_food.json",
    2: "assets/data/chapter_02_holiday.json",
    3: "assets/data/chapter_03_jobs.json",
    4: "assets/data/chapter_04_electronics.json",
    5: "assets/data/chapter_05_books.json",
    6: "assets/data/chapter_06_games.json",
    7: "assets/data/chapter_07_plants.json",
    8: "assets/data/chapter_08_painting.json",
    9: "assets/data/chapter_09_words.json",
    10: "assets/data/chapter_10_professional.json",
    11: "assets/data/chapter_11_religion.json",
    12: "assets/data/chapter_12_music.json",
    13: "assets/data/chapter_13_hobby.json",
    14: "assets/data/chapter_14_nature.json",
    15: "assets/data/chapter_15_tournament.json",
    16: "assets/data/chapter_16_education.json",
    17: "assets/data/chapter_17_technology.json",
    18: "assets/data/chapter_18_birds.json",
    19: "assets/data/chapter_19_pets.json",
    20: "assets/data/chapter_20_wild-animals.json",
    21: "assets/data/chapter_21_ocean.json",
}

used_words = set()
for c_num, path in ch_files.items():
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            for lvl in data.get('levels', []):
                for w in lvl.get('words', []):
                    used_words.add(w['word'].upper())

from build_chapter_22_weather import raw_weather_words

skipped_used = []
for word, definition, example in raw_weather_words:
    w = word.upper().strip().replace("-", "").replace(" ", "")
    if w in used_words:
        skipped_used.append(w)

print(f"Skipped {len(skipped_used)} words because they were used in prior chapters (1-21):")
print(skipped_used)
