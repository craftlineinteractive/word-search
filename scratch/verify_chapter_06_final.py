import json
import os

ch6_path = 'assets/data/chapter_06_games.json'
with open(ch6_path, 'r', encoding='utf-8') as f:
    ch6 = json.load(f)

print("Title:", ch6.get('title'))
levels = ch6.get('levels', [])
print("Total levels:", len(levels))

ch6_words = []
vocab_count = 0
grid_errors = []

for lvl in levels:
    lvl_num = lvl.get('levelNumber')
    rows = lvl.get('gridRows', 0)
    cols = lvl.get('gridCols', 0)
    max_grid = max(rows, cols)
    
    for w in lvl.get('words', []):
        word = w.get('word', '')
        ch6_words.append(word)
        if 'VOCAB' in word:
            vocab_count += 1
        if len(word) > max_grid:
            grid_errors.append((lvl_num, word, len(word), rows, cols))

print("Total words:", len(ch6_words))
print("Unique words in Ch6:", len(set(ch6_words)))
print("VOCAB placeholders:", vocab_count)
print("Grid accommodation errors:", len(grid_errors))

# Check overlap with prior completed chapters
used_other = set()
for path in [
    'assets/data/chapter_01_food.json',
    'assets/data/chapter_02_holiday.json',
    'assets/data/chapter_04_electronics.json',
    'assets/data/chapter_05_books.json'
]:
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    for lvl in data.get('levels', []):
        for w in lvl.get('words', []):
            used_other.add(w['word'].upper().replace(' ', '').replace('-', ''))

overlap = set(ch6_words).intersection(used_other)
print("Overlap with Ch1, 2, 4, 5:", len(overlap))
if overlap:
    print("Overlapping words:", overlap)
