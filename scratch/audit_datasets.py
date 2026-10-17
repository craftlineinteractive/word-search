import json
import glob
import os
import re

files = sorted(glob.glob('assets/data/*.json'))
print(f'Total files: {len(files)}')
total_levels = 0
all_words = {}
duplicates = []
empty_fields = 0
word_lengths = []
level_word_counts = set()

for f in files:
    fname = os.path.basename(f)
    with open(f, 'r', encoding='utf-8') as fp:
        data = json.load(fp)
    levels = data.get('levels', [])
    total_levels += len(levels)
    print(f'{fname}: id={data.get("id")}, title={data.get("title")}, levels={len(levels)}')
    for lvl in levels:
        ln = lvl.get('levelNumber')
        words = lvl.get('words', [])
        level_word_counts.add(len(words))
        for w in words:
            raw_w = w.get('word', '')
            norm_w = raw_w.strip().upper()
            word_lengths.append(len(norm_w))
            meaning = w.get('meaning', '').strip()
            example = w.get('example', '').strip()
            if not meaning or not example:
                empty_fields += 1
            if norm_w in all_words:
                duplicates.append((norm_w, all_words[norm_w], (fname, ln)))
            else:
                all_words[norm_w] = (fname, ln)

print(f'\n--- SUMMARY ---')
print(f'Total levels: {total_levels}')
print(f'Words per level observed: {sorted(list(level_word_counts))}')
print(f'Total unique words: {len(all_words)}')
print(f'Total duplicates: {len(duplicates)}')
print(f'Empty meaning/example fields: {empty_fields}')
print(f'Min word length: {min(word_lengths) if word_lengths else 0}, Max word length: {max(word_lengths) if word_lengths else 0}')
if duplicates:
    print(f'First 10 duplicates: {duplicates[:10]}')
