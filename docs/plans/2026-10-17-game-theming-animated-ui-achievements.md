# Comprehensive Game-Art, World Theming, 2D Tactile Game UI & 3-Star Multi-Tier Achievement System Implementation Plan

> **Specification Authority:** Word Search Game (Flutter 3.x, Dart 3.x)
> **Active Ground Truth:** Exactly 30 Worlds × 120 Levels = **3,600 Total Unique Levels** (Verified).
> **Target Achievement:** Milestone 16 ("Legend of Words") requires **3,600 unique levels completed** (Tier 1: 500, Tier 2: 1,800, Tier 3: 3,600).
> **Art Direction Standard:** Anti-UI-Slop 2D stylized cartoon game aesthetic (consistent 2.5–3.0px rounded outer stroke, dual-tone volumetric lighting, tactile 4–5dp button depth, original handcrafted vector assets, zero proprietary asset copies).

---

## 1. Game-Art & Animated-Asset Architecture (Environment Objects & Props)

To elevate the app into a living, tactile cartoon game without inflating APK size or causing GPU bottlenecks, we employ a **hybrid Procedural Vector + High-Efficiency Sprite Asset** pipeline:

### A. Environment Objects & Decorative Props Breakdown

| Category | Specific Elements | Visual Representation & Style | Animation Method | File Format & Storage | Dimensions & Optimization | Licensing Record |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Forest Trees** | Oak trees, pine canopies, weeping willows | Chunky cartoon trunks (`#3E2723`), layered emerald leaf clumps (`#15803D`, `#22C55E`), 2.5px dark stroke | Gentle sinusoidal wind sway via `Transform.rotate(angle: sin(t * 1.5) * 0.03)` | `assets/images/env/forest_tree_oak.png` + Flutter Vector fallback | 256×384 px, 8-bit PNG alpha, < 35KB | Original handcrafted art, 100% royalty-free |
| **Bushes & Foliage** | Berry bushes, fern fronds, moss mounds | Rounded bulbous foliage with cartoon berry clusters | Breathing scale idle: `1.0 + sin(t * 2) * 0.02` | `assets/images/env/forest_bush.png` | 192×128 px, PNG alpha, < 18KB | Original handcrafted art |
| **Flora & Fungi** | Woodland daisies, buttercups, spotted red mushrooms | 5-petal white/gold flowers, red cap mushrooms with cream dots | Spring-bounce blossom animation on level victory | `assets/images/env/forest_mushroom.png` + Canvas Vector blooms | 128×128 px, PNG alpha, < 12KB | Original handcrafted art |
| **Rocks & Pathways** | Stepping stones, mossy boulders, pebble borders | Smooth rounded river stones with top-light highlight bevel | Static background layer, zero animation overhead | `assets/images/env/forest_stone.png` | 160×96 px, PNG alpha, < 15KB | Original handcrafted art |
| **Fauna & Skies** | Fluttering butterflies, songbirds, fluffy clouds | Blue morpho butterfly, songbird silhouettes, cloud puffs | **Butterfly:** 3D flapping illusion via `Matrix4.identity()..scale(cos(t * 8), 1.0)`. **Clouds:** Horizontal wrap-around drift | Procedural Canvas vector (Butterfly) + `assets/images/env/cloud_soft.png` | Butterfly: 0KB (Vector). Cloud: 320×160 px, < 20KB | Original vector math + custom artwork |
| **World 1 (Food) Props**| Picnic basket, wooden board, cheese wedge, cutlery | Gingham cloth trim, honey jars, cartoon cheese | Floating food sparkle pulses | `assets/images/props/w01_picnic_basket.png` | 192×192 px, PNG alpha, < 25KB | Original handcrafted art |
| **World 20 (Ocean) Props**| Coral branches, starfish, sea anemone, swimming fish | Bright purple/coral branches, swimming clownfish | Fish gentle swim oscillation: `Offset(sin(t)*10, cos(t)*4)` | `assets/images/props/w20_coral.png` | 192×192 px, PNG alpha, < 22KB | Original handcrafted art |
| **World 18 (Birds) Props**| Woven tree nests, wooden birdhouse, speckled eggs | Rustic wooden birdhouse with green moss roof | Gentle sway on perch | `assets/images/props/w18_birdhouse.png` | 192×256 px, PNG alpha, < 25KB | Original handcrafted art |
| **Buttons & Borders** | Carved wood planks, stone slabs, twining ivy | Mahogany planks with carved bottom bevel, leaf runners | Physical 4dp press sink + tap audio | Procedural `CustomPainter` (`WoodPainter`, `VinePainter`) | 0KB asset weight (Vector Canvas) | Handcrafted Dart Vector code |

### B. Asset Optimization & Quality Gates:
1. **Size Budget:** Total new image assets for the pilot and core game will not exceed **600KB** total.
2. **Compression:** All PNGs processed through lossless `pngquant` + `oxipng` (indexed color where possible, stripping metadata).
3. **Approval Gate:** A **Sample Visual Sheet** (Forest Tree, Berry Bush, Mushroom, Cloud, Food Picnic Basket, and Butterfly animation) will be rendered and submitted for explicit user review prior to batch asset deployment.
4. **Licensing Manifest:** All assets will be documented in `assets/ASSET_MANIFEST.md` with creator timestamp, license (Proprietary / Open Game Art CC0 verified), and zero copyright dependencies.

---

## 2. Anti-Farming & Replay Prevention Architecture

To prevent players from gaming achievement counters via level restarts, replays, or spamming:

```
[Level Playthrough State Machine]
      │
      ▼
[Level Loaded]
  - levelIsAlreadyCompleted = progress.isLevelCompleted(worldId, levelNumber)
  - provisionalWordsFound = 0
  - sessionStartTime = DateTime.now()
  - sessionUsedHintOrSkip = false
      │
      ├──► [Target Word Found]
      │      - Play sound & highlight grid.
      │      - Increment provisionalWordsFound (In-Memory ONLY).
      │      - Check Speed Demon (if provisionalWordsFound >= 3 && elapsed <= 20s):
      │          flag provisionalSpeedDemon = true.
      │
      ├──► [Player Restarts or Leaves Level without Victory]
      │      - Discard provisionalWordsFound (0 committed to progress).
      │      - Discard provisionalSpeedDemon.
      │      - Reset streak to 0 (abandoned level).
      │      - Save state.
      │
      └──► [Victory: All Target Words Found!]
             - Commit to disk ONLY IF (!levelIsAlreadyCompleted):
                 • progress.completedLevels.add('${worldId}_${levelNumber}')
                 • achievementStats['words_found'] += provisionalWordsFound
                 • if (provisionalSpeedDemon) achievementStats['speed_demon'] += 1
                 • if (!sessionUsedHintOrSkip) achievementStats['hint_free_levels'] += 1
                 • progress.current_streak += 1
             - If (levelIsAlreadyCompleted == true):
                 • 0 added to words_found, 0 added to speed_demon, 0 added to streak.
```

### Exact Metric Commit Rules:
1. **Words Found (`word_hunter`):** Only committed upon **victory of an uncompleted level**. Quitting, restarting, or replaying gives **0**.
2. **Speed Demon (`speed_demon`):** Only awarded upon **victory of an uncompleted level** where 3 words were found in under 20s.
3. **Word Meanings (`vocabulary_scholar`):** Tracked in `progress.viewedWordMeanings` (a `Set<String>`). Tapping the same word definition multiple times adds **0**. Only viewing new, distinct words advances the counter.
4. **Hint-Free Clears (`sharp_mind`):** If a hint or skip booster is clicked, `sessionUsedHintOrSkip = true`. Awarded on victory only if `!sessionUsedHintOrSkip` and level was uncompleted.

---

## 3. World-Unlock Progression Analysis & Formula Verification

### Current Codebase Formula (`lib/models/user_progress.dart`):
```dart
int getRequiredStarsForChapter(int chapterId) {
  if (chapterId <= 1) return 0;
  return (chapterId - 1) * 25;
}
```

### Mathematical Progression Audit:
- **Stars Awarded per Level:** 3 Gameplay Stars.
- **World 1:** 0 Stars (Free).
- **World 2:** 25 Stars required -> `ceil(25 / 3) = 9` completed levels in World 1 (out of 120).
- **World 3:** 50 Stars required -> 17 total completed levels.
- **World 10:** 225 Stars required -> 75 total completed levels.
- **World 20:** 475 Stars required -> 159 total completed levels.
- **World 30:** 725 Stars required -> **242 total completed levels** (out of 3,600 levels).

### Analysis & Impact:
- **Casual Pacing:** All 30 Worlds unlock after playing ~242 levels (6.7% of the total 3,600 levels).
- **Pros:** Players can freely explore diverse worlds (Food, Ocean, Holiday, Animals) early without hitting a punishing multi-week lockwall.
- **Preservation Decision:** To guarantee **100% backward compatibility** with existing user saves, the formula `(worldId - 1) * 25` **remains intact**.
- **Pacing Anchor:** The long-term challenge is shifted into the **3-Star Achievement System**, where milestone 16 explicitly requires completing all **3,600 unique levels**.

---

## 4. Star Differentiation & Legacy Save Compatibility

### Strict Separation of Star Types:
1. **Gameplay Level Stars (Gold Stars ★):**
   - Computed dynamically as `completedLevels.length * 3`.
   - Max capacity: `3,600 × 3 = 10,800 Stars`.
   - Single source of truth: `completedLevels.length`.
2. **Achievement Milestone Stars (Bronze ★☆☆, Silver ★★☆, Gold ★★★):**
   - Earned by completing Tier 1, 2, and 3 of achievements.
   - Max capacity: `16 × 3 = 48 Achievement Stars`.
   - Tracked in `claimedAchievementTiers` (Map<String, int>).

### Legacy Save Compatibility:
- Loading a legacy JSON file with missing achievement keys will safely deserialize:
  - `achievementStats`: Defaults to `{}` and backfills `gameplay_stars_earned = completedLevels.length * 3` and `levels_completed = completedLevels.length`.
  - `claimedAchievementTiers`: Defaults to `{}`.
  - **No achievement stars or coins are granted automatically.** If backfilled stats satisfy a tier, the user sees an active **"CLAIM"** button, requiring manual collection.

---

## 5. Crash-Safe Detection of Unfinished Sessions & Streak Integrity

To ensure streaks reset when a player force-quits or process is terminated, without penalizing ordinary backgrounding:

```
[User Starts Uncompleted Level]
       │
       ▼
[Set progress.activeLevelSession = "${worldId}_${levelNumber}"]
[Await progress.save() to Disk]
       │
       ├──► [Case A: Player Wins Level]
       │      - progress.activeLevelSession = null
       │      - progress.current_streak += 1
       │      - Await progress.save()
       │
       ├──► [Case B: Player Taps Back/Home/Restart]
       │      - progress.activeLevelSession = null
       │      - progress.current_streak = 0
       │      - Await progress.save()
       │
       ├──► [Case C: Normal Multitasking (App Backgrounded / Screen Off)]
       │      - AppLifecycleState.paused / resumed
       │      - activeLevelSession remains "${worldId}_${levelNumber}"
       │      - App stays in memory; user resumes and wins -> Streak increments!
       │
       └──► [Case D: Process Killed / Battery Died / Force-Closed]
              - App is terminated while activeLevelSession != null.
              - On NEXT Launch (HomeScreen.initState):
                  • If progress.activeLevelSession != null:
                      - Detected abandoned level run!
                      - progress.current_streak = 0
                      - progress.activeLevelSession = null
                      - Await progress.save()
```

---

## 6. Complete Theme Mapping for All 30 Worlds & Global Screens

- **Global Screens (Home, World Roadmap, Settings):** **Enchanted Forest Theme**
  - Colors: Emerald (`#15803D`), Walnut (`#3E2723`), Sunlight (`#FBBF24`).
  - Props: Oak trees, berry bushes, mushrooms, daisy trims, carved wood plank buttons with 4dp bevel.
  - Particles: Drifting golden fireflies & floating pollen (max 15).

- **Per-World Theme & Environment Props Matrix (Levels Selection & Gameplay):**

| World ID & Key | Assigned Theme Name | Palette (Primary / Accent / Surface) | Environment Objects & Props | Particle Effect (Max 12–15) |
| :---: | :--- | :--- | :--- | :--- |
| **1: food** | Culinary Bistro | Honey (`#F59E0B`), Berry (`#EF4444`), Cream (`#FFFBEB`) | Picnic basket, gingham table border, wooden boards | Rising culinary steam & seasoning specks |
| **2: holiday** | Festive Yule | Cranberry (`#DC2626`), Pine (`#16A34A`), Gold (`#FBBF24`) | Gift boxes, gingerbread house, pine wreaths | Gentle crystalline snowflakes & warm glints |
| **3: jobs** | Artisan Workshop | Navy (`#1E3A8A`), Brass (`#D97706`), Slate (`#475569`) | Blueprints, brass gears, ruler markings | Drafting chalk dust & copper motes |
| **4: electronics**| Cyber Matrix | Cyan (`#06B6D4`), Indigo (`#4338CA`), Lime (`#84CC16`) | Circuit traces, glowing silicon microchips | Digital pulses & neon spark motes |
| **5: books** | Grand Library | Mahogany (`#78350F`), Parchment (`#FDE68A`), Ink (`#1E293B`)| Leather book stacks, quill pens, spectacles | Floating library dust & script specks |
| **6: games** | Arcade Wonderland | Purple (`#9333EA`), Pink (`#EC4899`), Yellow (`#FACC15`) | Dice pips, game token borders, joystick badges | Starburst flashes & party confetti |
| **7: plants** | Conservatory | Emerald (`#059669`), Mint (`#10B981`), Peach (`#FDA4AF`) | Greenhouse glass panes, potted ferns, terracotta | Drifting spores & botanical pollen |
| **8: painting** | Atelier Studio | Ultramarine (`#2563EB`), Ochre (`#EA580C`), Linen (`#FDFBF7`)| Wooden palette curves, paint jars, brush strokes | Pigment dust & watercolor droplets |
| **9: words** | Lexicon & Script | Violet (`#7C3AED`), Papyrus (`#FEF3C7`), Wax Seal (`#B91C1C`)| Carved wooden letters, ribbon bookmarks | Serif glyph particles & parchment flakes |
| **10: professional**| Executive Atelier| Charcoal (`#334155`), Bronze (`#B45309`), Silver (`#E2E8F0`)| Pinstripe borders, brass plaques, clockwork | Shimmering ambient light rays |
| **11: religion** | Sacred Sanctuary | Gold (`#D97706`), Rose (`#BE185D`), Celestial (`#1D4ED8`)| Stained glass arches, stone pillars, incense | Sacred incense smoke & sunbeams |
| **12: music** | Symphony Hall | Magenta (`#C026D3`), Brass (`#F59E0B`), Stage (`#18181B`) | Sheet music staves, clef scrolls, violin wood | Shimmering musical note sparkles |
| **13: hobby** | Cozy Craft Nook | Rust (`#C2410C`), Teal (`#0D9488`), Wool (`#EAB308`) | Stitched quilt seams, yarn balls, button rivets | Wool fibers & craft glitter |
| **14: nature** | Alpine Highland | Pine (`#15803D`), Sage (`#4ADE80`), Mountain (`#64748B`) | Pinecones, jagged alpine stone, mountain peaks | Pine needles & mountain breeze motes |
| **15: tournament**| Colosseum Arena | Trophy Gold (`#EAB308`), Crimson (`#B91C1C`), Iron (`#475569`)| Laurel wreaths, bronze shield crests, banners | Golden embers & victory confetti |
| **16: education** | Academy Hall | Navy (`#1E40AF`), Chalk (`#047857`), Brass (`#CA8A04`) | Chalkboards, graduation scrolls, apple motif | Soft chalk dust & glowing wisdom motes |
| **17: technology**| Quantum Lab | Cyan (`#0891B2`), Teal (`#0D9488`), Carbon (`#1F2937`) | Hexagonal grids, holographic scanline borders | Data packets & digital nodes |
| **18: birds** | High Aviary | Cerulean (`#0284C7`), Coral (`#F97316`), Sky (`#FBBF24`) | Woven nests, birdhouse silhouettes, feather motifs| Soft down feathers & sky breeze |
| **19: weather** | Cloud Observatory| Indigo (`#4338CA`), Rain (`#38BDF8`), Cloud (`#F8FAFC`) | Isobar contours, cloud scrolls, barometer dials | Rain mist droplets & cloud puffs |
| **20: ocean** | Coral Reef | Azure (`#0369A1`), Salmon (`#FB7185`), Seafoam (`#2DD4BF`) | Brain corals, starfish, swimming clownfish | Rising ocean bubbles with specular glints |
| **21: sports** | Athletic Arena | Turf (`#16A34A`), Clay (`#EA580C`), Whistle (`#FFFFFF`) | Yardline markers, ball seam stitching | Turf specks & stadium light flashes |
| **22: pets** | Sunny Garden | Honey (`#F59E0B`), Pink (`#F472B6`), Mint (`#34D399`) | Paw print badges, woven rope borders, pet toys | Floating heart puffs & garden sparkles |
| **23: vehicles** | Vintage Speedway| Crimson (`#DC2626`), Black (`#18181B`), Chrome (`#94A3B8`)| Tire tread borders, chrome bolt rivets, flags | Exhaust vapor wisps & roadway sparks |
| **24: city** | Metropolitan | Indigo (`#312E81`), Amber (`#F59E0B`), Concrete (`#64748B`)| Skyscraper silhouettes, art deco masonry | Nocturnal city ambient light motes |
| **25: home** | Hearth & Living | Hazelnut (`#92400E`), Hearth (`#EA580C`), Cream (`#FEF3C7`)| Brick fireplace trim, woven rug fringe | Fireplace embers & warm cozy glows |
| **26: wild-animals**| Savanna Outpost| Khaki (`#B45309`), Bark (`#78350F`), Sunset (`#D97706`) | Acacia trees, carved wooden totems, safari grass | Savanna heat shimmers & golden dust |
| **27: fashion** | Runway Pavilion | Rose Gold (`#FB7185`), Plum (`#86198F`), Silk (`#FFF1F2`)| Mannequins, ribbon hem stitching, zippers | Runway glitter & silk shimmer |
| **28: entertainment**| Grand Cinema | Burgundy (`#881337`), Gold (`#FACC15`), Film (`#0F172A`) | Film reels, marquee star bulbs, cinema curtains | Marquee bulb shimmer & projector rays |
| **29: adventure** | Ancient Ruins | Sandstone (`#D97706`), Moss (`#4D7C0F`), Fire (`#C2410C`)| Ancient stone runes, compass rose corners | Floating stone dust & torch sparks |
| **30: fantasy** | Astral Realm | Violet (`#7C2D12`), Teal (`#0E7490`), Starlight (`#FDE047`)| Dragon scales, crystal shards, moon phases | Arcane star specks & magical stardust |

---

## 7. Catalog of 16 Long-Term 3-Star Achievements (48 Milestone Stars)

| ID | Name | Step 1 (Bronze ★☆☆) | Step 2 (Silver ★★☆) | Step 3 (Gold ★★★) | Total Rewards |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `word_hunter` | Word Hunter | 100 Words | 1,000 Words | 5,000 Words | 1,250 Coins |
| `world_wanderer` | World Wanderer | 1 World (120 lvls) | 10 Worlds (1,200 lvls) | 30 Worlds (3,600 lvls) | 3,100 Coins |
| `level_champion` | Level Champion | 25 Unique Levels | 250 Unique Levels | 1,000 Unique Levels | 1,850 Coins |
| `speed_demon` | Speed Demon | 3 words < 20s (5×) | 3 words < 20s (25×) | 3 words < 20s (100×) | 1,300 Coins |
| `sharp_mind` | Sharp Mind | 10 levels no hint | 50 levels no hint | 200 levels no hint | 2,000 Coins |
| `coin_tycoon` | Coin Tycoon | 1,000 Lifetime Coins | 10,000 Lifetime Coins | 50,000 Lifetime Coins | 2,600 Coins |
| `star_collector` | Star Collector | 100 Gameplay Stars | 1,000 Gameplay Stars | 3,000 Gameplay Stars | 3,700 Coins |
| `daily_master` | Daily Master | 3 Daily Puzzles | 14 Daily Puzzles | 60 Daily Puzzles | 1,575 Coins |
| `vocabulary_scholar`| Vocab Scholar | 10 Unique Meanings | 50 Unique Meanings | 200 Unique Meanings | 1,050 Coins |
| `hint_strategist` | Hint Strategist | 5 Hints Used | 25 Hints Used | 100 Hints Used | 43 Free Hints |
| `food_connoisseur` | Master Chef (W1) | Clear W1 (20 lvls) | Clear W1 (60 lvls) | Clear W1 (120 lvls) | 700 Coins |
| `ocean_diver` | Deep Diver (W20) | Clear W20 (20 lvls)| Clear W20 (60 lvls)| Clear W20 (120 lvls)| 700 Coins |
| `avian_watcher` | Sky Watcher (W18)| Clear W18 (20 lvls)| Clear W18 (60 lvls)| Clear W18 (120 lvls)| 700 Coins |
| `safari_ranger` | Safari Ranger (W26)| Clear W26 (20 lvls)| Clear W26 (60 lvls)| Clear W26 (120 lvls)| 700 Coins |
| `flawless_streak` | Flawless Streak | 5 Level Streak | 15 Level Streak | 50 Level Streak | 2,000 Coins |
| `legend_of_words` | Legend of Words | 500 Unique Levels | 1,800 Unique Levels | **3,600 Unique Levels** | 12,500 Coins |

---

## 8. Explicit Data-Integrity & Strengthened Test Suite (6 Dedicated Test Files)

1. **`test/dataset_and_catalog_integrity_test.dart` (World & Level Ground Truth):**
   - Asserts `LevelRepository.catalog` contains exactly 30 entries (IDs 1..30).
   - Asserts all 30 files (`world_01_food.json` .. `world_30_fantasy.json`) exist and load successfully.
   - Asserts each world contains exactly **120 levels** (Total = **3,600 levels**).
   - Asserts 0 duplicate target words globally across the dataset.
2. **`test/asset_and_theme_mapping_test.dart` (Theme & Asset Integrity):**
   - Asserts all 30 World IDs map to valid non-null `WorldTheme` presets.
   - Asserts default Forest Theme applies to Home, World Map, and Settings.
   - Asserts that when `MediaQueryData.disableAnimations == true`, particle count evaluates to 0.
   - Asserts all declared asset images exist in `pubspec.yaml` and resolve on disk.
3. **`test/achievement_migration_test.dart` (Legacy Save Compatibility):**
   - Loads a mock legacy save without achievement fields.
   - Asserts `gameplay_stars_earned` backfills `completedLevels.length * 3`.
   - Asserts 0 achievement stars are auto-awarded.
   - Verifies coins, hints, and unlocked worlds remain 100% intact.
4. **`test/achievement_anti_farming_test.dart` (Replay & Anti-Exploit):**
   - Tests replaying an already completed level gives 0 to `words_found`, `speed_demon`, or `hint_free_levels`.
   - Tests unfinished level exit does not credit provisional words.
   - Tests viewing the same word definition multiple times credits only 1 unique meaning.
5. **`test/reward_claim_crash_safety_test.dart` (Atomic Dual-Write & Rollback):**
   - Asserts atomic dual-write of claimed tier and coins.
   - Simulates disk save failure -> asserts in-memory balances roll back cleanly with 0 coins awarded.
   - Asserts rapid double-taps rejected by mutex.
   - Asserts reload after app restart blocks duplicate claim.
6. **`test/session_kill_streak_test.dart` (Process Kill & Streak Tracking):**
   - Asserts level start sets `activeLevelSession`.
   - Asserts victory clears session and increments streak.
   - Asserts startup detection: if `activeLevelSession != null`, resets streak to 0.

---

## 9. Phased Execution Roadmap

- **Phase 0: Visual Sample Asset Sheet Approval (Pre-Implementation)**
  - Generate representative sample visual art (Forest Tree, Berry Bush, Mushroom, Cloud, Food Picnic Basket, Vector Butterfly).
  - Present sample assets and vector demos to user for explicit visual sign-off.
- **Phase 1: Planning, Data Models & Persistence**
  - Implement `Achievement` & `AchievementTier` in `lib/models/achievement.dart`.
  - Update `UserProgress` with `activeLevelSession`, `viewedWordMeanings`, and atomic `saveWithResult()`.
  - Run `test/achievement_migration_test.dart` and `test/dataset_and_catalog_integrity_test.dart`.
- **Phase 2: Theme Foundation & Tactile 2D Game Components**
  - Implement `WorldTheme` in `lib/theme/world_theme.dart` (Forest + 30 Worlds).
  - Implement `AmbientParticlesOverlay` (max 15, lifecycle, reduced motion).
  - Implement `OrganicWoodButton`, `ClashStarWidget`, and `ParchmentCard`.
  - Run `test/asset_and_theme_mapping_test.dart`.
- **Phase 3: Pilot Integration — World 1 (Food) End-to-End**
  - Integrate Food theme on `ChapterLevelsScreen` (120-level map) and `GameplayScreen`.
  - Wire session start/stop, timer, hint tracking, and anti-farming hooks.
  - Run `test/achievement_anti_farming_test.dart` and `test/session_kill_streak_test.dart`.
- **Phase 4: Full Theming Rollout — Forest Default & 30 World Themes**
  - Upgrade `HomeScreen`, `LevelsMapScreen`, and `SettingsScreen` with the lush Forest theme.
  - Connect all 30 World themes to their level-selection and gameplay screens.
- **Phase 5: 3-Star Achievement System & Top Sliding Banner**
  - Implement `AchievementService` with all 16 achievements (48 milestone stars).
  - Implement `AchievementsScreen` with 3-star cards, progress bars, and claim buttons.
  - Implement `AchievementNotificationBanner` and mount in root shell.
  - Run `test/reward_claim_crash_safety_test.dart`.
- **Phase 6: Full Verification, Static Analysis & Performance Review**
  - Run `flutter analyze` (0 issues).
  - Run `flutter test` across all 60+ tests (100% passing).
  - Profile frame rendering and memory usage on realistic device/simulator.

---

## 10. Proposed File Changes Summary

### Files to Create:
1. `assets/ASSET_MANIFEST.md` — Licensing and provenance record.
2. `lib/models/achievement.dart` — 3-Star tier and achievement definitions.
3. `lib/services/achievement_service.dart` — Catalog of 16 long-term achievements and event evaluator.
4. `lib/theme/world_theme.dart` — Complete token definitions for Forest and all 30 Worlds.
5. `lib/widgets/ambient_particles_overlay.dart` — Performance-capped procedural particle painter.
6. `lib/widgets/organic_wood_button.dart` — 2D stylized tactile wood button with bevel and press sink.
7. `lib/widgets/parchment_card.dart` — 2D stylized parchment container.
8. `lib/widgets/clash_star_widget.dart` — Bronze/Silver/Gold 3-star milestone indicator.
9. `lib/widgets/achievement_notification_banner.dart` — Sliding top dropdown alert.
10. `lib/screens/achievements_screen.dart` — Dedicated achievements screen with claim buttons.
11. `test/dataset_and_catalog_integrity_test.dart` — Ground truth test for 30 worlds × 120 levels = 3,600 levels.
12. `test/asset_and_theme_mapping_test.dart` — Theme mapping and reduced motion test.
13. `test/achievement_migration_test.dart` — Legacy save migration test.
14. `test/achievement_anti_farming_test.dart` — Replay prevention and anti-farming test.
15. `test/reward_claim_crash_safety_test.dart` — Atomic claim and rollback test.
16. `test/session_kill_streak_test.dart` — Abandoned session and streak test.

### Files to Modify:
1. `lib/models/user_progress.dart` — Add achievement tracking maps, `activeLevelSession`, backfill migration, and atomic save.
2. `lib/screens/home_screen.dart` — Forest theme overhaul, wood buttons, abandoned session check, and achievements button.
3. `lib/screens/levels_map_screen.dart` — Forest theme overhaul for the 30-world roadmap.
4. `lib/screens/settings_screen.dart` — Forest/parchment styling for settings controls.
5. `lib/screens/chapter_levels_screen.dart` — Dynamic per-world theming for the 120-level selection screen.
6. `lib/screens/gameplay_screen.dart` — Dynamic per-world theming, session timer, hint tracking, and achievement event hooks.
7. `lib/services/sound_manager.dart` — Add fanfare sound trigger helper for achievement unlock.
8. `lib/main.dart` — Mount the global achievement notification banner overlay.
9. `pubspec.yaml` — Register new environment image assets.
