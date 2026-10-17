import json
import glob
import os

files = sorted(glob.glob('assets/data/*.json'))
word_locations = {}

for f in files:
    fname = os.path.basename(f)
    with open(f, 'r', encoding='utf-8') as fp:
        d = json.load(fp)
    for lvl in d['levels']:
        ln = lvl['levelNumber']
        for w in lvl['words']:
            word = w['word'].strip().upper()
            if word not in word_locations:
                word_locations[word] = []
            word_locations[word].append((fname, ln))

duplicates = {w: locs for w, locs in word_locations.items() if len(locs) > 1}
print(f"Total duplicate word keys: {len(duplicates)}")
for w, locs in sorted(duplicates.items()):
    print(f"{w:<18} ({len(locs)} times): {locs}")
