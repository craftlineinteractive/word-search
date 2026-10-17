from nltk.corpus import wordnet as wn

keywords = ['electronic', 'circuit', 'voltage', 'current', 'diode', 'signal', 'sensor', 'digital', 'semiconductor', 'frequency']
found = set()

for s in wn.all_synsets():
    defn = s.definition().lower()
    if any(k in defn for k in keywords):
        for l in s.lemmas():
            name = l.name()
            if '_' not in name and '-' not in name and name.isalpha() and 3 <= len(name) <= 14:
                found.add(name.upper())

print(f"Keywords search for Electronics found: {len(found)} words!")
print(f"Sample words: {list(found)[:20]}")
