import random

# Exact replica of Dart's WordGridEngine for fast validation during level generation
DIRECTIONS = [
    (0, 1),   # horizontalForward
    (0, -1),  # horizontalBackward
    (1, 0),   # verticalDown
    (-1, 0),  # verticalUp
    (1, 1),   # diagonalDownRight
    (-1, -1), # diagonalUpLeft
    (1, -1),  # diagonalDownLeft
    (-1, 1),  # diagonalUpRight
]

def can_place(matrix, rows, cols, word, start_row, start_col, dr, dc):
    end_row = start_row + (len(word) - 1) * dr
    end_col = start_col + (len(word) - 1) * dc
    if end_row < 0 or end_row >= rows or end_col < 0 or end_col >= cols:
        return False
    for i, ch in enumerate(word):
        r = start_row + i * dr
        c = start_col + i * dc
        cur = matrix[r][c]
        if cur is not None and cur != ch:
            return False
    return True

def count_intersections(matrix, rows, cols, word, start_row, start_col, dr, dc):
    end_row = start_row + (len(word) - 1) * dr
    end_col = start_col + (len(word) - 1) * dc
    if end_row < 0 or end_row >= rows or end_col < 0 or end_col >= cols:
        return 0
    matches = 0
    for i, ch in enumerate(word):
        r = start_row + i * dr
        c = start_col + i * dc
        cur = matrix[r][c]
        if cur is not None:
            if cur == ch:
                matches += 1
            else:
                return 0
    return matches

def commit_placement(matrix, word, start_row, start_col, dr, dc):
    for i, ch in enumerate(word):
        r = start_row + i * dr
        c = start_col + i * dc
        matrix[r][c] = ch

def try_place_word(matrix, rows, cols, word, dirs, rng):
    all_positions = [(r, c) for r in range(rows) for c in range(cols)]
    rng.shuffle(all_positions)

    # 1. Try with intersections
    for dr, dc in dirs:
        for r, c in all_positions:
            if count_intersections(matrix, rows, cols, word, r, c, dr, dc) > 0 and can_place(matrix, rows, cols, word, r, c, dr, dc):
                commit_placement(matrix, word, r, c, dr, dc)
                return True

    # 2. Try in open space
    for dr, dc in dirs:
        for r, c in all_positions:
            if can_place(matrix, rows, cols, word, r, c, dr, dc):
                commit_placement(matrix, word, r, c, dr, dc)
                return True

    return False

def verify_level_grid(rows, cols, words, max_attempts=15):
    # Sort descending by length
    sorted_words = sorted([w.strip().upper() for w in words if w.strip()], key=lambda x: len(x), reverse=True)
    rng = random.Random(42)

    for attempt in range(max_attempts):
        matrix = [[None for _ in range(cols)] for _ in range(rows)]
        unplaced = []

        all_dirs = list(DIRECTIONS)
        diag_dirs = [d for d in all_dirs if d[0] != 0 and d[1] != 0]
        vert_dirs = [d for d in all_dirs if d[0] != 0 and d[1] == 0]
        horiz_dirs = [d for d in all_dirs if d[0] == 0 and d[1] != 0]

        rng.shuffle(diag_dirs)
        rng.shuffle(vert_dirs)
        rng.shuffle(horiz_dirs)

        for i, word in enumerate(sorted_words):
            prioritized = []
            if i % 3 == 0:
                prioritized = diag_dirs + vert_dirs + horiz_dirs
            elif i % 3 == 1:
                prioritized = vert_dirs + diag_dirs + horiz_dirs
            else:
                prioritized = horiz_dirs + diag_dirs + vert_dirs

            placed = try_place_word(matrix, rows, cols, word, prioritized, rng)
            if not placed:
                unplaced.append(word)

        if len(unplaced) == 0:
            return True, unplaced

    return False, unplaced
