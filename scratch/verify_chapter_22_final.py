import json
import os
import re

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

prior_used = set()
for c_num, path in ch_files.items():
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            for lvl in data.get('levels', []):
                for w in lvl.get('words', []):
                    prior_used.add(w['word'].upper())

target_path = "assets/data/chapter_22_weather.json"
assert os.path.exists(target_path), "Chapter 22 file missing!"

with open(target_path, 'r', encoding='utf-8') as f:
    ch22_data = json.load(f)

levels = ch22_data.get('levels', [])
assert len(levels) == 35, f"Expected 35 levels, got {len(levels)}"

all_words = []
words_set = set()
errors = []

for idx, lvl in enumerate(levels, 1):
    grid_rows = lvl.get('gridRows', 0)
    grid_cols = lvl.get('gridCols', 0)
    max_grid = max(grid_rows, grid_cols)
    
    lvl_words = lvl.get('words', [])
    for w_obj in lvl_words:
        w = w_obj.get('word', '').upper().strip()
        defn = w_obj.get('definition', '')
        ex = w_obj.get('example', '')
        
        # Check placeholder
        if w.startswith("VOCAB") or "PLACEHOLDER" in w:
            errors.append(f"Level {idx}: Placeholder word found '{w}'")
            
        # Check grid bounds
        if len(w) > max_grid:
            errors.append(f"Level {idx}: Word '{w}' length ({len(w)}) exceeds max grid ({max_grid})")
            
        # Check boilerplate definition
        if "A term relating to" in defn or "relating to" in defn.lower() and len(defn.split()) < 6:
            errors.append(f"Level {idx}: Generic boilerplate definition for '{w}': '{defn}'")
            
        # Check intra-chapter uniqueness
        if w in words_set:
            errors.append(f"Level {idx}: Duplicate intra-chapter word '{w}'")
        words_set.add(w)
        all_words.append(w)
        
        # Check cross-chapter overlap with Ch 1-21
        if w in prior_used:
            errors.append(f"Level {idx}: Cross-chapter overlap word '{w}' used in Chapters 1-21!")

# Check plural pairs
for w in all_words:
    if w.endswith('S') and w[:-1] in words_set:
        errors.append(f"Plural pair violation: '{w}' and '{w[:-1]}'")

print(f"Chapter 22 Total Words: {len(all_words)}")
print(f"Chapter 22 Unique Words: {len(words_set)}")

if errors:
    print(f"\nFAILED WITH {len(errors)} ERRORS:")
    for err in errors[:20]:
        print(f" - {err}")
else:
    print("\nSUCCESS: All 9 verification checks passed cleanly for Chapter 22 Weather!")
