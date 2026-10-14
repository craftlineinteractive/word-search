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
}

prior_words = set()
for c_num, path in ch_files.items():
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
        for lvl in data.get('levels', []):
            for w in lvl.get('words', []):
                prior_words.add(w['word'].upper())

target_path = "assets/data/chapter_16_education.json"
with open(target_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

levels = data.get('levels', [])
print(f"Total levels in Chapter 16: {len(levels)}")
assert len(levels) == 35, f"Expected 35 levels, got {len(levels)}"

ch_words = []
words_set = set()

for i, lvl in enumerate(levels, 1):
    l_words = lvl.get('words', [])
    g_rows = lvl.get('gridRows', 0)
    g_cols = lvl.get('gridCols', 0)
    max_grid = max(g_rows, g_cols)

    expected_count = 8 if i <= 9 else (9 if i <= 17 else (11 if i <= 24 else 13))
    assert len(l_words) == expected_count, f"L{i} has {len(l_words)} words, expected {expected_count}"

    for w_obj in l_words:
        w = w_obj['word'].upper()
        assert not w.startswith("VOCAB"), f"L{i} has placeholder word {w}"
        assert w not in words_set, f"Duplicate word {w} in Chapter 16"
        assert w not in prior_words, f"Overlap word {w} with prior chapters"
        assert len(w) <= max_grid, f"Word {w} (len {len(w)}) exceeds max grid dim {max_grid} in L{i}"
        
        words_set.add(w)
        ch_words.append(w)

print(f"Chapter 16 Total Words: {len(ch_words)}")
assert len(ch_words) == 364, f"Expected 364 total words, got {len(ch_words)}"

print("CHAPTER 16 VERIFICATION PASSED PERFECTLY!")
