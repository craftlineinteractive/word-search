import json
import glob

with open('assets/data/chapter_01_food.json', 'r', encoding='utf-8') as f:
    d = json.load(f)

for l in d['levels']:
    print(f"Level {l['levelNumber']:2d}: grid={l['gridRows']}x{l['gridCols']}, diff={l.get('difficulty')}, words={len(l['words'])}")
