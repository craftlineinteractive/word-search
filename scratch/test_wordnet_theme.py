from nltk.corpus import wordnet as wn
import re

def get_hyponyms(synset):
    hyponyms = set()
    for h in synset.hyponyms():
        hyponyms.add(h)
        hyponyms.update(get_hyponyms(h))
    return hyponyms

# Test food
food_syn = wn.synset('food.n.01')
food_hypos = get_hyponyms(food_syn)
print(f'Food hyponym synsets: {len(food_hypos)}')

food_words = set()
for s in food_hypos:
    for lemma in s.lemmas():
        name = lemma.name().upper().replace('_', '')
        if name.isalpha() and 3 <= len(name) <= 14:
            food_words.add(name)

print(f'Clean food words found: {len(food_words)}')
print(f'Sample food words: {list(food_words)[:15]}')
