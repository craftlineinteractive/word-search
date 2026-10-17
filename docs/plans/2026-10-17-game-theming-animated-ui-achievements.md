# Forest Aesthetic, World Theming, Tactile Game UI & 3-Star Achievement System Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform the Word Search game from a standard mobile app into a lush, tactile, living game with a default enchanted forest theme, dynamic world-based level theming (Food, Ocean, Holiday, etc.), procedural 60fps animated particles/vines/elements, organic wood & stone components, and a Clash of Clans-style 3-star multi-tier achievement system with in-game sliding notification banners.

**Architecture:** 
- A unified `WorldThemeManager` and `ThemeVisuals` palette system providing ambient colors, gradients, particle types, and thematic assets for both the default Forest theme (Home, Map, Settings) and individual World themes (Food, Holiday, Ocean, etc.).
- A zero-jank procedural particle and animated element engine using Flutter `CustomPainter`, `AnimationController`, and `TickerProvider` (Fireflies/Pollen, Floating Bubbles, Rising Culinary Steam, Swaying Leaves, Glimmering Sunbeams).
- Organic tactile game widgets: `WoodPlankButton` (with carved 3D bevels, wood grain, vine/flower accents), `ParchmentDialog` & `StoneTabletCard` (replacing flat Material cards), and `VineFrame` decorative borders.
- An extensible `AchievementService` & `AchievementModel` supporting Clash of Clans 3-star tiers (Bronze ★☆☆, Silver ★★☆, Gold ★★★), tracking 16+ long-term milestones, persisted in `UserProgress`, with an animated `AchievementNotificationOverlay` sliding from the top edge.

**Tech Stack:** Flutter 3.x, Dart 3, CustomPainter (Impeller-optimized), AnimationController, SharedPreferences, Shared Theme Tokens.

---

## Asset Architecture & Needs Analysis

To achieve a true game aesthetic without inflating the app size with heavy videos or laggy GIFs, we use a hybrid **Procedural Vector + Targeted Asset** approach:

### 1. Needed Assets & Generation Strategy:
| Asset Category | Target File Path | Format | Role & Usage |
| :--- | :--- | :--- | :--- |
| **Forest Wood Textures / Buttons** | `assets/images/wood_button_slice.png` or Procedural Canvas | PNG / CustomPainter | Carved wooden plank base for primary buttons with depth bevel |
| **Parchment Scroll Background** | `assets/images/parchment_scroll.png` or Procedural Canvas | PNG / CustomPainter | Dialog & modal backdrops with textured ancient paper/scroll edges |
| **Star Badges (Bronze, Silver, Gold)** | `assets/images/star_bronze.png`, `star_silver.png`, `star_gold.png` | PNG / CustomPainter | Clash of Clans 3-tier achievement star badges with metallic sheen |
| **Trophy & Achievement Medals** | `assets/images/trophy_cup.png` | PNG / Vector | Banner notification icon & achievement screen header |
| **Vine & Floral Trims** | Procedural `VinePainter` / SVG | Canvas Path | Dynamic ivy, roots, and flowers blooming along button corners and card frames |
| **World Ambient Particles** | Procedural `ParticleEngine` | Canvas Draw | Zero-asset-size dynamic particles (Pollen, Bubbles, Steam, Snowflakes, Embers) |
| **Achievement Audio SFX** | `assets/sounds/achievement_fanfare.mp3` | MP3 / WAV | Joyful Supercell-style fanfare chime when a tier completes |

---

## Detailed Task Breakdown

### Task 1: Data Model & Persistence for 3-Star Multi-Tier Achievements
**Files:**
- Create: `lib/models/achievement.dart`
- Modify: `lib/models/user_progress.dart`
- Test: `test/achievement_model_test.dart`

**Step 1: Write the failing unit test**
Test that `Achievement` has 3 tiers, calculates current star count (0 to 3), progress percentage (0.0 to 1.0), handles tier claims, and serializes to/from JSON in `UserProgress`.

**Step 2: Run test to verify it fails**
Run: `flutter test test/achievement_model_test.dart`
Expected: Compilation failure (`achievement.dart` not found).

**Step 3: Implement `Achievement` and update `UserProgress`**
Implement:
- `AchievementTier`: `int tierIndex` (1, 2, 3), `int targetValue`, `int rewardCoins`, `int rewardHints`, `String title`.
- `Achievement`: `String id`, `String name`, `String description`, `IconData icon`, `List<AchievementTier> tiers`.
- Methods: `int getStars(int currentProgress)`, `double getProgressRatio(int currentProgress, int tier)`, `bool isTierClaimed(int tier)`.
- In `UserProgress`: add `Map<String, int> achievementStats` (e.g. `words_found`, `levels_no_hint`, `stars_earned`, `meanings_viewed`), `Map<String, int> claimedAchievementTiers` (e.g. `word_hunter: 2`).

**Step 4: Run test to verify it passes**
Run: `flutter test test/achievement_model_test.dart`
Expected: PASS.

**Step 5: Commit**
`git commit -m "feat(achievements): create 3-star multi-tier achievement data model and persistence"`

---

### Task 2: Achievement Catalog & Evaluation Engine
**Files:**
- Create: `lib/services/achievement_service.dart`
- Test: `test/achievement_service_test.dart`

**Step 1: Write the failing unit test**
Test that `AchievementService` evaluates progress updates, detects newly completed tiers, dispatches notification events, and claims rewards (adding coins/hints to `UserProgress`).

**Step 2: Run test to verify it fails**
Run: `flutter test test/achievement_service_test.dart`
Expected: Compilation failure.

**Step 3: Implement `AchievementService` with 16 Deep Long-Term Achievements**
Catalog includes:
1. `word_hunter`: "Word Hunter" (Find 100 / 1,000 / 5,000 words) -> Rewards: 50, 200, 1,000 coins
2. `world_wanderer`: "World Wanderer" (Complete 1 / 10 / 30 Worlds) -> Rewards: 100, 500, 2,500 coins
3. `level_champion`: "Level Champion" (Clear 25 / 250 / 1,000 Levels) -> Rewards: 50, 300, 1,500 coins
4. `speed_demon`: "Speed Demon" (Find 3 words under 20s: 5 / 25 / 100 times) -> Rewards: 50, 250, 1,000 coins
5. `sharp_mind`: "Sharp Mind" (Clear 10 / 50 / 200 levels with 0 hints) -> Rewards: 100, 400, 1,500 coins
6. `coin_tycoon`: "Coin Tycoon" (Accumulate 1,000 / 10,000 / 50,000 coins) -> Rewards: 100, 500, 2,000 coins
7. `star_collector`: "Star Collector" (Earn 100 / 1,000 / 3,000 stars) -> Rewards: 100, 600, 3,000 coins
8. `daily_master`: "Daily Master" (Solve 3 / 14 / 60 daily puzzles) -> Rewards: 75, 300, 1,200 coins
9. `vocabulary_scholar`: "Vocabulary Scholar" (Read word definitions 10 / 50 / 200 times) -> Rewards: 50, 200, 800 coins
10. `hint_strategist`: "Hint Strategist" (Use 5 / 25 / 100 hints wisely) -> Rewards: 3 hints, 10 hints, 30 hints
11. `food_connoisseur`: "Food Connoisseur" (Clear World 1 Food: 20 / 60 / 120 levels) -> Rewards: 50, 150, 500 coins
12. `ocean_diver`: "Ocean Diver" (Clear World 20 Ocean: 20 / 60 / 120 levels) -> Rewards: 50, 150, 500 coins
13. `avian_watcher`: "Avian Watcher" (Clear World 18 Birds: 20 / 60 / 120 levels) -> Rewards: 50, 150, 500 coins
14. `safari_ranger`: "Safari Ranger" (Clear World 26 Wild Animals: 20 / 60 / 120 levels) -> Rewards: 50, 150, 500 coins
15. `perfect_streak`: "Flawless Streak" (Clear 5 / 15 / 50 levels in a row without quitting) -> Rewards: 100, 400, 1,500 coins
16. `grand_master`: "Legend of Words" (Clear 500 / 1,800 / 3,600 levels) -> Rewards: 500, 2,000, 10,000 coins

**Step 4: Run test to verify it passes**
Run: `flutter test test/achievement_service_test.dart`
Expected: PASS.

---

### Task 3: Animated Procedural World Theme Engine (Forest + 30 World Themes)
**Files:**
- Create: `lib/theme/world_theme.dart`
- Create: `lib/widgets/ambient_particles_overlay.dart`
- Modify: `lib/theme/app_theme.dart`
- Test: `test/world_theme_test.dart`

**Step 1: Write the failing unit test**
Test that `WorldTheme.forWorld(worldId)` returns the correct palette, background style, particle type (`pollen`, `steam`, `bubbles`, `snow`, `leaves`), and accent colors.

**Step 2: Implement `WorldTheme` and `AmbientParticlesOverlay`**
- `WorldTheme`:
  - `ThemeType`: Forest (Default for Home/Map/Settings), Food (Culinary warm honey/cream), Ocean (Azure reef & bubbles), Holiday (Crimson & snow), Nature/Plants (Lush jungle & leaves), Adventure (Ancient amber stone), etc.
  - Colors: `primaryGradient`, `accentGlow`, `cardBg`, `woodTone`, `particleColor`.
- `AmbientParticlesOverlay`:
  - A lightweight 60fps `CustomPainter` managing 20-30 floating particles with random gentle swaying, floating speeds, opacity pulses, and screen wrap-around.
  - Particle types:
    - Forest: golden pollen/fireflies drifting gently with soft glow.
    - Food: rising vapor/steam wisps and sparkling seasoning specks.
    - Ocean: rising translucent bubbles with light highlights.
    - Holiday: soft falling snow crystals.
  - RepaintBoundary optimization ensures 0 jank and minimal GPU/battery footprint.

**Step 3: Run test to verify it passes**
Run: `flutter test test/world_theme_test.dart`
Expected: PASS.

---

### Task 4: Tactile Game UI Components (Wood Plank Buttons, Vine Frames, Stone Tablets)
**Files:**
- Create: `lib/widgets/organic_wood_button.dart`
- Create: `lib/widgets/parchment_card.dart`
- Create: `lib/widgets/nature_decorations.dart`
- Test: `test/game_components_test.dart`

**Step 1: Write the failing unit test**
Test that `OrganicWoodButton` renders with proper touch padding (>= 48dp), triggers press sink animation, and renders leaf/flower trims.

**Step 2: Implement Organic Tactile Components**
- `OrganicWoodButton`:
  - Rich wood plank gradient, carved dark-wood bottom bevel (3D push down effect on tap).
  - Optional corner leaf/flower sprouts painted with custom Bézier curves.
  - Satisfying audio click on press.
- `ParchmentCard` / `StoneTabletCard`:
  - Organic rounded container with textured paper/stone gradient, carved border, and ivy accents.
- `ClashStarWidget`:
  - Renders 3 stars (★☆☆, ★★☆, ★★★) with metallic bronze, silver, and gold gradients, bevel highlights, and unlocked glow.

**Step 3: Run test to verify it passes**
Run: `flutter test test/game_components_test.dart`
Expected: PASS.

---

### Task 5: Clash of Clans 3-Star Achievement Screen
**Files:**
- Create: `lib/screens/achievements_screen.dart`
- Test: `test/achievements_screen_test.dart`

**Step 1: Write the failing widget test**
Test that `AchievementsScreen` displays total stars, lists all 16 achievements, displays 3-star step progression, shows "Claim" button for ready tiers, and delivers coin/hint rewards.

**Step 2: Implement `AchievementsScreen`**
- Forest-themed parchment/wood aesthetic with Header Trophy & Total Achievement Stars counter (`XX / 48 ★`).
- Filter tabs: All, In Progress, Completed.
- Achievement Card:
  - Custom wooden/stone frame.
  - Badge icon inside carved circular frame.
  - Title and 3-Star indicator: [★][★][★] (Bronze, Silver, Gold).
  - Dynamic progress bar with green fill: `Current / Target` (e.g. `245 / 500`).
  - Active Claim Button with gleaming gold effect when ready to collect.
  - Claiming triggers joyful coin/star confetti burst and updates balance.

**Step 3: Run test to verify it passes**
Run: `flutter test test/achievements_screen_test.dart`
Expected: PASS.

---

### Task 6: Sliding In-Game Top Notification Banner
**Files:**
- Create: `lib/widgets/achievement_notification_banner.dart`
- Modify: `lib/main.dart` or Root Navigator Overlay
- Test: `test/achievement_banner_test.dart`

**Step 1: Write the failing widget test**
Test that triggering an achievement tier completion pops a top sliding banner with title, tier stars, reward amount, and auto-dismisses after 3 seconds.

**Step 2: Implement `AchievementNotificationBanner`**
- Slide-and-fade animation from the top edge with safe-area padding.
- Golden border, carved wood background, glowing trophy icon.
- Sound effect playback (`SoundManager.playFanfare()`).
- Tap gesture navigates directly to `AchievementsScreen`.

**Step 3: Run test to verify it passes**
Run: `flutter test test/achievement_banner_test.dart`
Expected: PASS.

---

### Task 7: Screen Makeover: Forest Theme for Home, World Map & Settings
**Files:**
- Modify: `lib/screens/home_screen.dart`
- Modify: `lib/screens/levels_map_screen.dart`
- Modify: `lib/screens/settings_screen.dart`
- Test: `test/phase5_journey_map_test.dart`

**Step 1: Update `HomeScreen`**
- Replace flat buttons with `OrganicWoodButton` with vine & leaf motifs.
- Add `AmbientParticlesOverlay(theme: WorldTheme.forest)` for floating fireflies/pollen.
- Add direct entry button to `AchievementsScreen` with an uncollected notification badge!
- Wood-carved trophy badge and coin balance bar.

**Step 2: Update `LevelsMapScreen` (World Roadmap)**
- Enhance winding journey path with grassy/mossy stone nodes, blooming flowers at milestones.
- Forest canopy background with subtle drifting leaves.

**Step 3: Update `SettingsScreen`**
- Wood and parchment style cards for sound, theme, and language controls.

---

### Task 8: Screen Makeover: Themed World Level Map & Gameplay Screen (Food, Ocean, etc.)
**Files:**
- Modify: `lib/screens/chapter_levels_screen.dart`
- Modify: `lib/screens/gameplay_screen.dart`
- Test: `test/phase3_gameplay_test.dart`

**Step 1: Update `ChapterLevelsScreen`**
- Load `WorldTheme.forWorld(worldId)`:
  - If World 1 (Food): Culinary theme, picnic cloth banner, culinary props, rising steam particles.
  - If World 20 (Ocean): Coral blue theme, floating bubbles, sea crest banners.
  - Level nodes styled with thematic accents.

**Step 2: Update `GameplayScreen`**
- Integrate `AmbientParticlesOverlay` with the active world theme.
- Style Word Search grid board with carved wooden or thematic borders.
- Word bank chips styled with organic tactile pills.
- Achievement event hooks: whenever a word is found, level completed without hints, or time recorded, ping `AchievementService`.

---

### Task 9: Full Verification, Static Analysis & Test Suite
**Files:**
- All modified and new test files.

**Step 1: Run `flutter analyze`**
Verify: 0 issues, 0 warnings.

**Step 2: Run `flutter test`**
Verify: 100% passing across all old and new test suites.

**Step 3: Final Acceptance Verification**
Review UI responsiveness, 60fps animations, touch ergonomics, and achievement event flow.
