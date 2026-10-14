import json
import os
import re
import sys

# Universal Chapter Data Applicator
# Converts a raw array of word objects into a complete 35-level JSON dataset.

def clean_word(w):
    return re.sub(r'[^A-Z]', '', w.upper())

def apply_words_to_chapter(chapter_id, words_array):
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
        print(f"ERROR: Chapter ID {chapter_id} not found in assets/data/")
        return False

    with open(target_file, "r", encoding="utf-8") as f:
        chapter_data = json.load(f)

    levels = []
    word_idx = 0
    total_words_assigned = 0

    # 35 Levels distribution
    for lvl_num in range(1, 36):
        if lvl_num <= 9:
            count = 8
            grid_size = 9
            difficulty = "normal"
        elif lvl_num <= 17:
            count = 9
            grid_size = 11
            difficulty = "medium"
        elif lvl_num <= 24:
            count = 11
            grid_size = 13
            difficulty = "hard"
        else:
            count = 13
            grid_size = 14
            difficulty = "expert"

        level_words = []
        max_word_len = 0

        for _ in range(count):
            if word_idx < len(words_array):
                item = words_array[word_idx]
                w_str = clean_word(item.get("word", ""))
                m_str = item.get("meaning", item.get("definition", "")).strip()
                e_str = item.get("example", "").strip()

                if not m_str:
                    m_str = f"Specific vocabulary item in {chapter_data.get('title')}."
                if not e_str:
                    e_str = f"The term {w_str.title()} is featured in this word puzzle."

                level_words.append({
                    "word": w_str,
                    "meaning": m_str,
                    "example": e_str
                })

                if len(w_str) > max_word_len:
                    max_word_len = len(w_str)

                word_idx += 1

        # Ensure grid accommodates longest word length
        actual_rows = max(grid_size, max_word_len + 1)
        actual_cols = max(grid_size, max_word_len + 1)

        levels.append({
            "levelNumber": lvl_num,
            "title": f"{chapter_data.get('title')} Level {lvl_num}",
            "gridRows": actual_rows,
            "gridCols": actual_cols,
            "difficulty": difficulty,
            "words": level_words
        })

        total_words_assigned += len(level_words)

    chapter_data["levels"] = levels

    with open(target_file, "w", encoding="utf-8") as f:
        json.dump(chapter_data, f, indent=2)

    print(f"\nSUCCESS: Chapter {chapter_id} ({chapter_data.get('title')}) updated with {total_words_assigned} words in {target_file}!")
    return True

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python tool/apply_chapter_data.py <chapter_id> <path_to_words_json>")
    else:
        ch_id = int(sys.argv[1])
        json_path = sys.argv[2]
        with open(json_path, "r", encoding="utf-8") as f:
            words_data = json.load(f)
        apply_words_to_chapter(ch_id, words_data)
