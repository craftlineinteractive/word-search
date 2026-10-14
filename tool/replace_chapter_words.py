import json
import os
import re
import sys

# Dedicated script to update any chapter's 35 levels with custom authentic words, meanings, and examples.
# Exactly 364 unique words per chapter (Level 1-9: 8 words/lvl, Level 10-17: 9 words/lvl, Level 18-24: 11 words/lvl, Level 25-35: 13 words/lvl).

def clean_word(w):
    return re.sub(r'[^A-Z]', '', w.upper())

def update_chapter(chapter_id, words_list):
    """
    words_list should be a list of dicts:
    [
      {"word": "TACO", "meaning": "A Mexican dish...", "example": "Spicy beef taco."},
      ... (364 items)
    ]
    """
    data_dir = "assets/data"
    files = sorted([os.path.join(data_dir, f) for f in os.listdir(data_dir) if f.startswith("chapter_") and f.endswith(".json")])
    
    target_file = None
    for f in files:
        with open(f, "r", encoding="utf-8") as file_obj:
            d = json.load(file_obj)
            if d.get("id") == chapter_id:
                target_file = f
                break

    if not target_file:
        print(f"Error: Chapter ID {chapter_id} not found in assets/data/")
        return False

    with open(target_file, "r", encoding="utf-8") as f:
        chapter_data = json.load(f)

    levels = chapter_data.get("levels", [])
    if len(levels) != 35:
        print(f"Error: Chapter has {len(levels)} levels instead of 35.")
        return False

    word_idx = 0
    total_words_assigned = 0

    for lvl in levels:
        lvl_num = lvl.get("levelNumber", 1)
        
        # Determine word count needed for this level
        if lvl_num <= 9:
            count = 8
        elif lvl_num <= 17:
            count = 9
        elif lvl_num <= 24:
            count = 11
        else:
            count = 13

        level_words = []
        max_len = 0

        for _ in range(count):
            if word_idx < len(words_list):
                w_item = words_list[word_idx]
                w_str = clean_word(w_item.get("word", ""))
                m_str = w_item.get("meaning", "")
                e_str = w_item.get("example", "")

                level_words.append({
                    "word": w_str,
                    "meaning": m_str,
                    "example": e_str
                })

                if len(w_str) > max_len:
                    max_len = len(w_str)

                word_idx += 1

        lvl["words"] = level_words
        total_words_assigned += len(level_words)

        # Ensure grid dimensions fit the longest word strictly
        if lvl["gridRows"] <= max_len:
            lvl["gridRows"] = max_len + 1
            lvl["gridCols"] = max_len + 1

    # Save updated JSON
    with open(target_file, "w", encoding="utf-8") as f:
        json.dump(chapter_data, f, indent=2)

    print(f"Successfully updated Chapter {chapter_id} ({chapter_data.get('title')}) in {target_file}!")
    print(f"Total Words Assigned: {total_words_assigned} across 35 levels.")
    return True

if __name__ == "__main__":
    print("Script tool/replace_chapter_words.py ready to update chapter word lists.")
