from nltk.corpus import wordnet as wn

def get_hypos(syn):
    h_all = set()
    for h in syn.hyponyms():
        h_all.add(h)
        h_all.update(get_hypos(h))
    return h_all

food_syns = [
    wn.synset('food.n.01'),
    wn.synset('food.n.02'),
    wn.synset('dish.n.02'),
    wn.synset('beverage.n.01'),
    wn.synset('produce.n.01'),
]

words = {}
for root in food_syns:
    all_s = get_hypos(root)
    all_s.add(root)
    for s in all_s:
        for l in s.lemmas():
            name = l.name()
            if '_' not in name and '-' not in name:
                w = name.upper()
                if 3 <= len(w) <= 12 and w.isalpha() and w not in words:
                    definition = s.definition()
                    ex = s.examples()[0] if s.examples() else f"Enjoying delicious fresh {name.lower()}."
                    words[w] = (definition, ex)

print(f"Total single-word food entries: {len(words)}")
for w, (d, ex) in list(words.items())[:8]:
    print(f"{w:<12}: {d} | Ex: {ex}")
