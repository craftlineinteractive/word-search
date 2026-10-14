import json
import os

ch_files = {
    1: "assets/data/chapter_01_food.json",
    2: "assets/data/chapter_02_holiday.json",
    3: "assets/data/chapter_03_professions.json",
    4: "assets/data/chapter_04_electronics.json",
    5: "assets/data/chapter_05_books.json",
    6: "assets/data/chapter_06_games.json",
    7: "assets/data/chapter_07_plants.json",
    8: "assets/data/chapter_08_painting.json",
    9: "assets/data/chapter_09_words.json",
    10: "assets/data/chapter_10_professional.json",
    11: "assets/data/chapter_11_religion.json",
}

prior_words = set()
for c_num, path in ch_files.items():
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            for lvl in data.get('levels', []):
                for w in lvl.get('words', []):
                    prior_words.add(w['word'].upper())

target_path = "assets/data/chapter_12_music.json"
with open(target_path, 'r', encoding='utf-8') as f:
    ch12_data = json.load(f)

levels = ch12_data.get('levels', [])
print(f"Chapter 12 Title: {ch12_data.get('chapterTitle')}")
print(f"Total Levels: {len(levels)}")

assert len(levels) == 35, f"Expected 35 levels, got {len(levels)}"

ch12_words = []
vocab_count = 0
grid_errors = 0

expected_distribution = {
    range(1, 10): 8,
    range(10, 18): 9,
    range(18, 25): 11,
    range(25, 36): 13
}

for i, lvl in enumerate(levels, 1):
    l_words = lvl.get('words', [])
    g_rows = lvl.get('gridRows')
    g_cols = lvl.get('gridCols')
    
    exp_count = None
    for r, count in expected_distribution.items():
        if i in r:
            exp_count = count
            break
            
    if len(l_words) != exp_count:
        print(f"Warning: Level {i} has {len(l_words)} words, expected {exp_count}")
        
    for w in l_words:
        w_str = w['word'].upper()
        if "VOCAB" in w_str:
            vocab_count += 1
        ch12_words.append(w_str)
        
        max_dim = max(g_rows, g_cols)
        if len(w_str) > max_dim:
            print(f"Grid Error in L{i}: word '{w_str}' length {len(w_str)} exceeds max dim {max_dim}")
            grid_errors += 1

print(f"Total words in Ch 12: {len(ch12_words)}")
assert len(ch12_words) == 364, f"Expected 364 words, got {len(ch12_words)}"
assert vocab_count == 0, f"Found {vocab_count} VOCAB placeholders!"
assert grid_errors == 0, f"Found {grid_errors} grid bounds errors!"

unique_ch12 = set(ch12_words)
print(f"Unique words in Ch 12: {len(unique_ch12)}")
assert len(unique_ch12) == 364, f"Duplicates found in Ch 12! Unique: {len(unique_ch12)}"

overlap = unique_ch12.intersection(prior_words)
print(f"Overlap with chapters 1-11: {len(overlap)}")
if overlap:
    print("Overlapping words:", overlap)
assert len(overlap) == 0, f"Overlap detected with prior chapters!"

print("\n--- ALL VERIFICATION CHECKS PASSED FOR CHAPTER 12 (MUSIC) ---")
