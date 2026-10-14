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

for ch_num in range(18, 22):
    path = ch_files[ch_num]
    assert os.path.exists(path), f"File missing: {path}"
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    levels = data.get("levels", [])
    assert len(levels) == 35, f"Chapter {ch_num} has {len(levels)} levels, expected 35"

    ch_words = []
    for lvl_idx, lvl in enumerate(levels, 1):
        words = [w["word"].upper() for w in lvl.get("words", [])]
        ch_words.extend(words)

        # Grid bounds check
        max_w_len = max(len(w) for w in words)
        grid_rows = lvl.get("gridRows", 0)
        grid_cols = lvl.get("gridCols", 0)
        assert max(grid_rows, grid_cols) >= max_w_len, f"Ch {ch_num} Lvl {lvl_idx}: max word len {max_w_len} > grid max({grid_rows}, {grid_cols})"

    assert len(ch_words) == 364, f"Chapter {ch_num} total words is {len(ch_words)}, expected 364"
    assert len(set(ch_words)) == 364, f"Chapter {ch_num} has duplicate words within chapter!"

    # Check for placeholder VOCAB...
    for w in ch_words:
        assert not w.startswith("VOCAB"), f"Chapter {ch_num} contains synthetic placeholder word: {w}"

    # Check for lazy plural duplicates within chapter
    ch_words_set = set(ch_words)
    for w in ch_words:
        if w.endswith("S") and w[:-1] in ch_words_set:
            raise AssertionError(f"Chapter {ch_num} contains lazy plural pair: {w[:-1]} and {w}")

    # Check for boilerplate definitions
    for lvl in levels:
        for w in lvl['words']:
            assert 'term relating' not in w['meaning'].lower(), f"Boilerplate meaning found: {w['meaning']}"

    print(f"Chapter {ch_num:02d} verified: 35 levels, 364 words, 0 placeholders, 0 duplicates, 0 plural pairs, 0 boilerplate definitions.")

# Cross-chapter check between 21 and prior 1-20
prior_words = set()
for ch_num in range(1, 21):
    with open(ch_files[ch_num], 'r', encoding='utf-8') as f:
        data = json.load(f)
        for lvl in data['levels']:
            for w in lvl['words']:
                prior_words.add(w['word'].upper())

with open(ch_files[21], 'r', encoding='utf-8') as f:
    data = json.load(f)
    ch21_words = set([w['word'].upper() for lvl in data['levels'] for w in lvl['words']])

overlap = ch21_words.intersection(prior_words)
assert len(overlap) == 0, f"Chapter 21 has overlap with prior chapters: {overlap}"
print("Chapter 21 cross-chapter overlap check passed: 0 overlapping words with Chapters 1-20!")
