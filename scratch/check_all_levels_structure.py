import json
import glob
import os

files = sorted(glob.glob('assets/data/*.json'))
summary = {}

for f in files:
    with open(f, 'r', encoding='utf-8') as fp:
        d = json.load(fp)
    for l in d['levels']:
        ln = l['levelNumber']
        rows = l['gridRows']
        cols = l['gridCols']
        diff = l.get('difficulty', '')
        wc = len(l['words'])
        if ln not in summary:
            summary[ln] = {'rows': set(), 'cols': set(), 'diff': set(), 'words': set()}
        summary[ln]['rows'].add(rows)
        summary[ln]['cols'].add(cols)
        summary[ln]['diff'].add(diff)
        summary[ln]['words'].add(wc)

for ln in sorted(summary.keys()):
    s = summary[ln]
    print(f"Lvl {ln:2d}: grid={sorted(list(s['rows']))}x{sorted(list(s['cols']))}, diff={sorted(list(s['diff']))}, wordCounts={sorted(list(s['words']))}")
