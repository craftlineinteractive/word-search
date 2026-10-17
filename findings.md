# Findings: Word Search Game Architecture & Dataset Inventory

## 1. Project Overview & Structure
- **Game Engine:** Flutter 3.x + Dart 3.x.
- **Word Grid Engine:** `lib/engine/word_grid_engine.dart`
  - Generates 8-directional word search puzzles (horizontal, vertical, diagonal, backwards).
  - Up to 10 attempts to place all words, prioritizing intersections and cycling direction families.
  - Word constraints: Words must be pure alphabetic (`A-Z`), uppercase, no whitespace, hyphens, or punctuation.
  - Max word length constraint: Cannot exceed `max(gridRows, gridCols)`. When words are longer than 14 characters, grid dimensions must expand accordingly (`gridRows = max(14, longestWordLength)`).
- **Data Repository:** `lib/services/level_repository.dart`
  - Catalog currently defines 30 entries (IDs 1–30).
  - Files stored in `assets/data/`.
  - Image assets in `assets/chapter_images/` (30 pngs, confirmed to exist).
- **User Progress Persistence:** `lib/models/user_progress.dart`
  - Stored in `SharedPreferences` under key `word_search_user_progress_v1`.
  - Levels keyed as `${chapterId}_${levelNumber}` (e.g. `1_1`).
  - Worlds/Chapters unlocked via set `unlockedChapters` of `int` IDs.
  - Star calculation: 3 stars per completed level. Required stars per world: `(chapterId - 1) * 25`.
  - By maintaining IDs 1..30 and sequential levels 1..120, user progress and saved completions are 100% preserved.

---

## 2. Dataset Inventory (Pre-Migration)
- **World Count:** 30 Worlds (`food`, `holiday`, `jobs`, `electronics`, `books`, `games`, `plants`, `painting`, `words`, `professional`, `religion`, `music`, `hobby`, `nature`, `tournament`, `education`, `technology`, `birds`, `pets`, `wild-animals`, `ocean`, `weather`, `sports`, `vehicles`, `city`, `home`, `fashion`, `entertainment`, `adventure`, `fantasy`).
- **Initial Levels:** 35 levels per World = 1,050 total levels.
- **New Target:** **120 levels per World** = **3,600 total levels** (user requested 120 levels per world instead of 60).
- **Initial Duplicates Found:** 71 duplicate word instances across levels 1–35 (predominantly between `jobs.json` and `professional.json`, `books.json`, `hobby.json`, and self-duplicates in `food.json` e.g. `PUDDING`, `BURRITO`, `SAMOSA`, `GRAVY`).
- **Animal World Distribution Requirement:**
  - Originally Worlds 18 (Birds), 19 (Pets), and 20 (Wild Animals) were clustered consecutively.
  - User requested separating them across different positions so player doesn't encounter consecutive animal worlds.
  - New World positioning:
    - World 18: Birds
    - World 19: Weather
    - World 20: Ocean
    - World 21: Sports
    - World 22: Pets
    - World 23: Vehicles
    - World 24: City
    - World 25: Home
    - World 26: Wild Animals
    - World 27: Fashion
    - World 28: Entertainment
    - World 29: Adventure
    - World 30: Fantasy
  - This ensures 3–4 non-animal worlds separate every animal theme.
- **Level Word Counts:**
  - Levels 1–9: 8 words (normal)
  - Levels 10–17: 9 words (medium)
  - Levels 18–24: 11 words (hard)
  - Levels 25–120: 11–13 words (expert)

---

## 3. UI Terminology Migration Audit
The following files contained hardcoded "Chapter" terminology and/or hardcoded 35-level limits:
1. `lib/screens/levels_map_screen.dart`:
   - `for (int lvl = 1; lvl <= 35; lvl++)` → dynamic `totalLevelsCount` (120)
   - `if (completedCount >= 35)` → dynamic `totalLevelsCount`
   - `totalLevelsCount: 35` → 120
   - `CH 1 / 30` → `WORLD 1 / 30`
   - `Chapter X Locked!` → `World X Locked!`
   - Dialog text: "unlock Chapter X... in previous chapters" → "unlock World X... in previous worlds"
2. `lib/screens/chapter_levels_screen.dart`:
   - `Chapter ${widget.chapter.id} ($totalLevels Levels)` → `World ${widget.chapter.id} ($totalLevels Levels)`
3. `lib/widgets/chapter_node_widget.dart`:
   - `totalLevelsCount = 35` → `totalLevelsCount = 120`
4. `lib/widgets/rating_bottom_sheet.dart`:
   - "help us create more chapters" → "help us create more worlds"
5. `lib/screens/home_screen.dart`:
   - `totalLevels = 1050` → 3600 (30 worlds × 120 levels)
   - `totalPossibleStars = 3150` → 10800 (3600 × 3 stars)

---

## 4. UI Theming, Procedural Animated Elements & 3-Star Achievement System
- **Game Aesthetic vs App Aesthetic:**
  - Simple apps use flat rectangular buttons, plain Material elevation shadows, and standard system dialogs.
  - Games use organic, tactile materials: carved wood planks with 3D bottom bevels, stone tablets, ancient parchment scrolls, and blooming floral/vine accents that respond to touch with physics sink (Y-offset translation + haptics).
- **Procedural Animated Elements Architecture (Flutter 60/120fps):**
  - Storing MP4 videos or large animated GIFs drains mobile battery, wastes RAM, and inflates the APK by tens of megabytes.
  - The superior game architecture in Flutter uses `CustomPainter` with `AnimationController` and `TickerProviderStateMixin`.
  - Particles (floating fireflies, golden pollen, ocean bubbles, rising culinary steam, falling snow) are managed as an array of 20–30 procedural structs with randomized phase offsets, sinusoidal horizontal drift, vertical float velocities, and alpha breathing pulses.
  - Wrapped in `RepaintBoundary` to prevent re-rendering the underlying UI tree, achieving a steady 60–120 FPS on Impeller.
- **Clash of Clans 3-Star Multi-Tier Achievement Mechanics:**
  - Standard achievements give a single reward and quickly run out, leaving players with no long-term engagement.
  - The Clash of Clans 3-star model features 3 progressive milestone steps per achievement (★☆☆ Bronze, ★★☆ Silver, ★★★ Gold).
  - Each step increases in difficulty (e.g., 100 words -> 1,000 words -> 5,000 words) and awards escalating coin/hint bonuses.
  - Persistent tracking: `UserProgress` stores raw counters (`achievementStats`) and claimed tier indexes (`claimedAchievementTiers`) to ensure offline persistence and idempotent reward claiming.
  - Instant Feedback: Sliding top notification banner appears in real-time when any tier target is achieved during gameplay, with fanfare audio and golden visual glow.

