# Findings & Discoveries

## 1. Android Startup Screen Behavior
- Devices with Android 12+ (API 31+) enforce the WindowManager SplashScreen API.
- If the device is set to Dark Mode and `values-night` / `values-night-v31` lacks explicit `android:windowSplashScreenBackground`, the system renders a dark/black splash screen before launching Flutter.
- Setting `android:windowSplashScreenBackground` to `@color/splash_background` in `values-v31` and adding `values-night-v31` guarantees consistent color across both light and dark OS themes.
- Removing `windowIsTranslucent` prevents startup delay.

## 2. Achievement Star-Based Rewards
- Each of the 16 achievements currently defines 3 tiers (`tierNumber: 1, 2, 3`), which represent Star 1, Star 2, and Star 3.
- Completed stars are calculated dynamically via `ach.getCompletedTier(currentVal)`.
- Previously, the UI referred to them as "Tier X". Rebranding and styling them as "★ Star 1", "★ Star 2", and "★ Star 3" with their respective rewards directly satisfies the user requirement that each achievement has 3 star-based rewards.
- The claim mechanism should allow claiming Star 1 reward upon achieving Star 1, Star 2 reward upon achieving Star 2, and Star 3 reward upon achieving Star 3.

## 3. Level Stars Calculation by Hint Usage
- Currently, `UserProgress.getTotalStars()` simply computed `completedLevels.length * 3`, without recording individual level star ratings.
- In `GameplayScreen`, hints are deducted without recording `_hintsUsedThisLevel`.
- User specification:
  - 0 hints used -> 3 stars (perfect solve)
  - 1 hint used -> 2 stars
  - 2+ hints used (or skipped) -> 1 star
- Needs:
  - Store `Map<String, int> levelStars` in `UserProgress` (with JSON serialization & migration default).
  - Update `completeLevel(chapterId, levelNumber, {int stars = 3})` to store `max(existingStars, newStars)`.
  - In `gameplay_screen.dart`, count `_hintsUsedThisLevel` and compute stars earned upon victory.
  - Display the stars earned (1, 2, or 3) on the celebration dialog.
  - In `chapter_levels_screen.dart`, display the earned stars (1 to 3) on each level tile.

## 4. World Unlock Star Requirements
- Currently `(chapterId - 1) * 60` was required.
- If a player gets 1 star on some levels or plays casually, 60 stars required 60 levels out of 120.
- Rebalancing to `(chapterId - 1) * 30` makes World 2 unlockable in 10-15 levels (or 30 levels at 1 star), making progression smooth and achievable for any gamer.
