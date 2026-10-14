import json
import os

ch8_path = 'assets/data/chapter_08_painting.json'
with open(ch8_path, 'r', encoding='utf-8') as f:
    ch8 = json.load(f)

print("Title:", ch8.get('title'))
levels = ch8.get('levels', [])
print("Total levels:", len(levels))

ch8_words = []
vocab_count = 0
grid_errors = []

for lvl in levels:
    lvl_num = lvl.get('levelNumber')
    rows = lvl.get('gridRows', 0)
    cols = lvl.get('gridCols', 0)
    max_grid = max(rows, cols)
    
    for w in lvl.get('words', []):
        word = w.get('word', '')
        ch8_words.append(word)
        if 'VOCAB' in word:
            vocab_count += 1
        if len(word) > max_grid:
            grid_errors.append((lvl_num, word, len(word), rows, cols))

print("Total words:", len(ch8_words))
print("Unique words in Ch8:", len(set(ch8_words)))
print("VOCAB placeholders:", vocab_count)
print("Grid accommodation errors:", len(grid_errors))

# Check overlap with prior completed chapters
used_other = set()
for path in [
    'assets/data/chapter_01_food.json',
    'assets/data/chapter_02_holiday.json',
    'assets/data/chapter_04_electronics.json',
    'assets/data/chapter_05_books.json',
    'assets/data/chapter_06_games.json',
    'assets/data/chapter_07_plants.json'
]:
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    for lvl in data.get('levels', []):
        for w in lvl.get('words', []):
            used_other.add(w['word'].upper().replace(' ', '').replace('-', ''))

overlap = set(ch8_words).intersection(used_other)
print("Overlap with Ch1, 2, 4, 5, 6, 7:", len(overlap))
if overlap:
    print("Overlapping words:", overlap)
