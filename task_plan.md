# Task Plan: Refine Every Word, Rename Chapters to Worlds, and Expand to 3,600 Levels (120 Levels per World)

## 1. Goal & Objectives
- **Target:** Expand the word-search puzzle game from 30 Chapters × 35 Levels (1,050 levels) to **30 Worlds × 120 Levels (3,600 levels total)**.
- **Terminology:** Full migration of user-facing concept from **Chapters** to **Worlds** across all screens, dialogs, progress indicators, and labels.
- **Vocabulary Refinement:**
  - Audit and refine existing levels 1–35 across all 30 Worlds.
  - Generate levels 36–120 for each World with high-quality, theme-appropriate vocabulary.
  - Subcategory distribution: eliminate narrow thematic clustering across adjacent levels (e.g. food, animals, jobs).
  - Accurate concise definitions and natural, grammatical example sentences.
- **Global Uniqueness:**
  - **Zero duplicate target words** across all 3,600 levels in the entire game after casing and punctuation normalization.
  - No trivial inflection bypasses (e.g., Apple vs Apples, Play vs Played).
- **Grid Compatibility & Solvability:**
  - Every level must be validated against `WordGridEngine` to ensure 100% of target words place successfully without placement failures or infinite loops.
  - Grid rows and cols dynamically scale and accommodate the longest word in every level (`max(gridDim, longestWord)`).
- **Backward Compatibility:**
  - Preserve `UserProgress` (coins, hints, unlocked worlds, completed levels format `chapterId_levelNumber`).
  - Keep stable integer IDs (1..30) and asset paths.
- **Automated Validation & Tests:**
  - Build automated validation scripts and Flutter tests (`flutter test`, `flutter analyze`) ensuring zero duplicates, exact level counts (120/world = 3600 total), and grid solvability.

---

## 2. Inventory & Baseline Metrics
- **Worlds Found:** 30
- **Levels Before Change:** 1,050 (35 levels × 30 chapters)
- **Target Levels After Change:** 3,600 (120 levels × 30 worlds)
- **Initial Duplicate Target Words:** 71 duplicate word instances detected in existing levels 1–35.
- **Word Scaling & Dimensions:**
  - Levels 1–9: Normal difficulty, 8 words, 9×9 grid (or max(9, longest_word))
  - Levels 10–17: Medium difficulty, 9 words, 11×11 grid (or max(11, longest_word))
  - Levels 18–24: Hard difficulty, 11 words, 13×13 grid (or max(13, longest_word))
  - Levels 25–120: Expert difficulty, 11–13 words, 14×14 grid (or max(14, longest_word))
- **Estimated Total Global Vocabulary:** ~38,000 – 40,000 globally unique target words.

---

## 3. Phased Implementation Roadmap

### Phase 1: Planning, Inventory, and Architecture Verification
- [x] Inspect existing repository structure, models, engine, and assets.
- [x] Run baseline audit on all 30 JSON files for word counts, duplicates, grid scaling, and placeholders.
- [x] Create `task_plan.md`, `findings.md`, and `progress.md`.

### Phase 2: Terminology & Data File Migration (Chapters → Worlds)
- [x] Rename data files in `assets/data/`: `chapter_XX_*.json` → `world_XX_*.json`.
- [x] Update `LevelRepository` catalog, JSON file references, and cache mappings.
- [x] Add backward-compatible type aliases in models (`typedef World = Chapter;`, `typedef WorldMeta = ChapterMeta;`).
- [x] Update UI strings and widgets:
  - `lib/screens/levels_map_screen.dart` (CH -> WORLD, Chapter Locked -> World Locked, totalLevelsCount: 120)
  - `lib/screens/chapter_levels_screen.dart` (Chapter X -> World X, total levels 120)
  - `lib/widgets/chapter_node_widget.dart` (default levels 120, badges)
  - `lib/widgets/rating_bottom_sheet.dart` (chapters -> worlds)
  - `lib/screens/home_screen.dart` (total levels 3600, stars 10800)
- [x] Preserve user progress keying and backward compatibility.

### Phase 3 & 4: Vocabulary Expansion & Refinement (Levels 1–120 for All 30 Worlds)
- [x] Build comprehensive authentic thematic vocabulary for all 30 Worlds:
  - World 01: Food (120 levels)
  - World 02: Holiday (120 levels)
  - World 03: Jobs (120 levels)
  - World 04: Electronics (120 levels)
  - World 05: Books (120 levels)
  - World 06: Games (120 levels)
  - World 07: Plants (120 levels)
  - World 08: Painting (120 levels)
  - World 09: Words (120 levels)
  - World 10: Professional (120 levels)
  - World 11: Religion (120 levels)
  - World 12: Music (120 levels)
  - World 13: Hobby (120 levels)
  - World 14: Nature (120 levels)
  - World 15: Tournament (120 levels)
  - World 16: Education (120 levels)
  - World 17: Technology (120 levels)
  - World 18: Birds (120 levels)
  - World 19: Weather (120 levels)
  - World 20: Ocean (120 levels)
  - World 21: Sports (120 levels)
  - World 22: Pets (120 levels)
  - World 23: Vehicles (120 levels)
  - World 24: City (120 levels)
  - World 25: Home (120 levels)
  - World 26: Wild Animals (120 levels)
  - World 27: Fashion (120 levels)
  - World 28: Entertainment (120 levels)
  - World 29: Adventure (120 levels)
  - World 30: Fantasy (120 levels)
- [x] Fix all legacy duplicates.
- [x] Subcategory randomization: Eliminate narrow clumping (seafood, meats, fruits, etc. randomly distributed throughout all 120 levels).
- [x] Letter Diversity: Strictly limit to at most 2 words starting with the same alphabet per level (`count <= 2`).
- [x] Separated Animal worlds: Birds (18), Pets (22), Wild Animals (26).
- [x] Ensure valid educational meanings and contextual example sentences for every word.

### Phase 5: Global Uniqueness Verification
- [x] Ran automated normalization and global uniqueness check across all 3,600 levels.
- [x] Verified exactly 0 duplicate words globally across all 3,600 levels (38,310 words total).

### Phase 6: Grid Compatibility & Solvability Verification
- [x] Ran `WordGridEngine` simulation on all 3,600 levels.
- [x] Verified 100% of target words place successfully (0 unplaced words).
- [x] Verified grid dimensions >= length of every word in every level.

### Phase 7: Automated Tests & Validation Suite
- [x] Updated `test/phase2_dataset_integrity_test.dart` and `test/phase5_journey_map_test.dart`.
- [x] Ran `flutter analyze`: 0 issues found.
- [x] Ran `flutter test`: 55/55 passed (100%).

### Phase 8: Final Review & Acceptance Verification (Dataset & Engine)
- [x] Verified all 30 worlds with 120 levels each (3,600 levels total).
- [x] Verified 0 duplicates across 38,310 words globally.
- [x] Verified max 2 words per starting alphabet per level (3,600/3,600 levels compliant).
- [x] Verified animal worlds separated (18 Birds, 22 Pets, 26 Wild Animals).
- [x] Verified `flutter analyze` (0 issues) and `flutter test` (55/55 passed).

### Phase 9: Forest Aesthetic, World Theming, Tactile Game UI & 3-Star Achievements
- [ ] **9.1: Data Models, Persistence & Legacy Migration**
  - Implement `Achievement` & `AchievementTier` in `lib/models/achievement.dart`.
  - Update `UserProgress` with `achievementStats`, `claimedAchievementTiers`, and atomic `saveWithResult()`.
  - Implement verified backfill for `levels_completed` and `gameplay_stars_earned = completedLevels.length * 3`.
  - Add tests: `test/achievement_migration_test.dart` and `test/reward_claim_crash_safety_test.dart`.
- [ ] **9.2: Theme Foundation & Tactile 2D Game Components**
  - Implement `WorldTheme` in `lib/theme/world_theme.dart` with token contracts and mapping for Forest + all 30 Worlds.
  - Implement `AmbientParticlesOverlay` in `lib/widgets/ambient_particles_overlay.dart` (max 15 particles, lifecycle, reduced motion).
  - Implement `OrganicWoodButton` in `lib/widgets/organic_wood_button.dart` (carved 3D wood bevel, leaf/flower accents).
  - Implement `ParchmentCard` in `lib/widgets/parchment_card.dart` and `ClashStarWidget` in `lib/widgets/clash_star_widget.dart`.
  - Add tests: `test/world_theme_mapping_test.dart`.
- [ ] **9.3: Pilot Integration — World 1 (Food) End-to-End**
  - Apply `WorldTheme.food` to `ChapterLevelsScreen` (Food 120-level map) and `GameplayScreen` (Food puzzle level).
  - Integrate session timer, hint tracking (`usedHintInSession`), and anti-farming word/level hooks.
  - Add tests: `test/achievement_anti_farming_test.dart` and `test/streak_tracking_test.dart`.
- [ ] **9.4: Full Theming Rollout — Forest Default & 30 World Themes**
  - Upgrade `HomeScreen`, `LevelsMapScreen` (World Roadmap), and `SettingsScreen` with the Forest theme.
  - Connect all 30 world themes in `ChapterLevelsScreen` and `GameplayScreen`.
- [ ] **9.5: 3-Star Achievement System & Top Sliding Banner**
  - Implement `AchievementService` in `lib/services/achievement_service.dart` with all 16 achievements (48 milestone stars).
  - Implement `AchievementsScreen` in `lib/screens/achievements_screen.dart` with Clash of Clans 3-star cards, progress bars, and claim buttons.
  - Implement `AchievementNotificationBanner` in `lib/widgets/achievement_notification_banner.dart` and mount in root shell.
- [ ] **9.6: Comprehensive Verification & Regression Suite**
  - Run full test suite including all 5 new test files.
  - Run `flutter analyze` (target: 0 issues).
  - Benchmark performance on device/simulator.
