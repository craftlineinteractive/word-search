import json
import os

ch7_path = 'assets/data/chapter_07_plants.json'
with open(ch7_path, 'r', encoding='utf-8') as f:
    ch7 = json.load(f)

print("Title:", ch7.get('title'))
levels = ch7.get('levels', [])
print("Total levels:", len(levels))

ch7_words = []
vocab_count = 0
grid_errors = []

for lvl in levels:
    lvl_num = lvl.get('levelNumber')
    rows = lvl.get('gridRows', 0)
    cols = lvl.get('gridCols', 0)
    max_grid = max(rows, cols)
    
    for w in lvl.get('words', []):
        word = w.get('word', '')
        ch7_words.append(word)
        if 'VOCAB' in word:
            vocab_count += 1
        if len(word) > max_grid:
            grid_errors.append((lvl_num, word, len(word), rows, cols))

print("Total words:", len(ch7_words))
print("Unique words in Ch7:", len(set(ch7_words)))
print("VOCAB placeholders:", vocab_count)
print("Grid accommodation errors:", len(grid_errors))

# Check overlap with prior completed chapters
used_other = set()
for path in [
    'assets/data/chapter_01_food.json',
    'assets/data/chapter_02_holiday.json',
    'assets/data/chapter_04_electronics.json',
    'assets/data/chapter_05_books.json',
    'assets/data/chapter_06_games.json'
]:
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    for lvl in data.get('levels', []):
        for w in lvl.get('words', []):
            used_other.add(w['word'].upper().replace(' ', '').replace('-', ''))

overlap = set(ch7_words).intersection(used_other)
print("Overlap with Ch1, 2, 4, 5, 6:", len(overlap))
if overlap:
    print("Overlapping words:", overlap)
