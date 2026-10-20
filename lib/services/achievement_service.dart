import '../models/achievement.dart';
import '../models/user_progress.dart';

class AchievementService {
  static final AchievementService instance = AchievementService._internal();
  factory AchievementService() => instance;
  AchievementService._internal();

  static const List<Achievement> catalog = [
    Achievement(
      id: 'word_hunter',
      title: 'Word Hunter',
      description: 'Find target words across puzzle levels',
      tiers: [
        AchievementTier(tierNumber: 1, targetValue: 100, coinReward: 10, hintReward: 1),
        AchievementTier(tierNumber: 2, targetValue: 1000, coinReward: 25, hintReward: 1),
        AchievementTier(tierNumber: 3, targetValue: 5000, coinReward: 40, hintReward: 2),
      ],
    ),
    Achievement(
      id: 'world_wanderer',
      title: 'World Wanderer',
      description: 'Complete all 120 levels in different Worlds',
      tiers: [
        AchievementTier(tierNumber: 1, targetValue: 1, coinReward: 15, hintReward: 1),
        AchievementTier(tierNumber: 2, targetValue: 10, coinReward: 30, hintReward: 2),
        AchievementTier(tierNumber: 3, targetValue: 30, coinReward: 50, hintReward: 3),
      ],
    ),
    Achievement(
      id: 'level_champion',
      title: 'Level Champion',
      description: 'Complete unique puzzle levels',
      tiers: [
        AchievementTier(tierNumber: 1, targetValue: 25, coinReward: 10, hintReward: 1),
        AchievementTier(tierNumber: 2, targetValue: 250, coinReward: 25, hintReward: 1),
        AchievementTier(tierNumber: 3, targetValue: 1000, coinReward: 40, hintReward: 2),
      ],
    ),
    Achievement(
      id: 'speed_demon',
      title: 'Speed Demon',
      description: 'Find 3 words in under 20 seconds during fresh level victory',
      tiers: [
        AchievementTier(tierNumber: 1, targetValue: 5, coinReward: 10, hintReward: 1),
        AchievementTier(tierNumber: 2, targetValue: 25, coinReward: 20, hintReward: 1),
        AchievementTier(tierNumber: 3, targetValue: 100, coinReward: 35, hintReward: 2),
      ],
    ),
    Achievement(
      id: 'sharp_mind',
      title: 'Sharp Mind',
      description: 'Clear levels without using any hints or skips',
      tiers: [
        AchievementTier(tierNumber: 1, targetValue: 10, coinReward: 10, hintReward: 1),
        AchievementTier(tierNumber: 2, targetValue: 50, coinReward: 25, hintReward: 1),
        AchievementTier(tierNumber: 3, targetValue: 200, coinReward: 40, hintReward: 2),
      ],
    ),
    Achievement(
      id: 'coin_tycoon',
      title: 'Coin Tycoon',
      description: 'Amass lifetime gold coins through clever play',
      tiers: [
        AchievementTier(tierNumber: 1, targetValue: 500, coinReward: 10, hintReward: 1),
        AchievementTier(tierNumber: 2, targetValue: 2000, coinReward: 20, hintReward: 1),
        AchievementTier(tierNumber: 3, targetValue: 10000, coinReward: 35, hintReward: 2),
      ],
    ),
    Achievement(
      id: 'star_collector',
      title: 'Star Collector',
      description: 'Collect gameplay stars across all levels',
      tiers: [
        AchievementTier(tierNumber: 1, targetValue: 100, coinReward: 10, hintReward: 1),
        AchievementTier(tierNumber: 2, targetValue: 1000, coinReward: 25, hintReward: 2),
        AchievementTier(tierNumber: 3, targetValue: 3000, coinReward: 45, hintReward: 2),
      ],
    ),
    Achievement(
      id: 'daily_master',
      title: 'Daily Master',
      description: 'Solve daily challenge puzzle levels',
      tiers: [
        AchievementTier(tierNumber: 1, targetValue: 3, coinReward: 15, hintReward: 1),
        AchievementTier(tierNumber: 2, targetValue: 14, coinReward: 25, hintReward: 1),
        AchievementTier(tierNumber: 3, targetValue: 60, coinReward: 45, hintReward: 2),
      ],
    ),
    Achievement(
      id: 'vocabulary_scholar',
      title: 'Vocab Scholar',
      description: 'Inspect unique dictionary word definitions in-game',
      tiers: [
        AchievementTier(tierNumber: 1, targetValue: 10, coinReward: 10, hintReward: 1),
        AchievementTier(tierNumber: 2, targetValue: 50, coinReward: 20, hintReward: 1),
        AchievementTier(tierNumber: 3, targetValue: 200, coinReward: 30, hintReward: 2),
      ],
    ),
    Achievement(
      id: 'hint_strategist',
      title: 'Hint Strategist',
      description: 'Deploy hint boosters when facing tricky words',
      tiers: [
        AchievementTier(tierNumber: 1, targetValue: 5, coinReward: 10, hintReward: 1),
        AchievementTier(tierNumber: 2, targetValue: 25, coinReward: 20, hintReward: 1),
        AchievementTier(tierNumber: 3, targetValue: 100, coinReward: 35, hintReward: 2),
      ],
    ),
    Achievement(
      id: 'food_connoisseur',
      title: 'Master Chef',
      description: 'Complete levels in World 1 (Food)',
      tiers: [
        AchievementTier(tierNumber: 1, targetValue: 20, coinReward: 10, hintReward: 1),
        AchievementTier(tierNumber: 2, targetValue: 60, coinReward: 20, hintReward: 1),
        AchievementTier(tierNumber: 3, targetValue: 120, coinReward: 30, hintReward: 2),
      ],
    ),
    Achievement(
      id: 'ocean_diver',
      title: 'Deep Diver',
      description: 'Complete levels in World 20 (Ocean)',
      tiers: [
        AchievementTier(tierNumber: 1, targetValue: 20, coinReward: 10, hintReward: 1),
        AchievementTier(tierNumber: 2, targetValue: 60, coinReward: 20, hintReward: 1),
        AchievementTier(tierNumber: 3, targetValue: 120, coinReward: 30, hintReward: 2),
      ],
    ),
    Achievement(
      id: 'avian_watcher',
      title: 'Sky Watcher',
      description: 'Complete levels in World 18 (Birds)',
      tiers: [
        AchievementTier(tierNumber: 1, targetValue: 20, coinReward: 10, hintReward: 1),
        AchievementTier(tierNumber: 2, targetValue: 60, coinReward: 20, hintReward: 1),
        AchievementTier(tierNumber: 3, targetValue: 120, coinReward: 30, hintReward: 2),
      ],
    ),
    Achievement(
      id: 'safari_ranger',
      title: 'Safari Ranger',
      description: 'Complete levels in World 26 (Wild Animals)',
      tiers: [
        AchievementTier(tierNumber: 1, targetValue: 20, coinReward: 10, hintReward: 1),
        AchievementTier(tierNumber: 2, targetValue: 60, coinReward: 20, hintReward: 1),
        AchievementTier(tierNumber: 3, targetValue: 120, coinReward: 30, hintReward: 2),
      ],
    ),
    Achievement(
      id: 'flawless_streak',
      title: 'Flawless Streak',
      description: 'Win consecutive levels without quitting or failing',
      tiers: [
        AchievementTier(tierNumber: 1, targetValue: 5, coinReward: 10, hintReward: 1),
        AchievementTier(tierNumber: 2, targetValue: 15, coinReward: 20, hintReward: 1),
        AchievementTier(tierNumber: 3, targetValue: 50, coinReward: 40, hintReward: 2),
      ],
    ),
    Achievement(
      id: 'legend_of_words',
      title: 'Legend of Words',
      description: 'Complete all 3,600 unique levels across all 30 Worlds',
      tiers: [
        AchievementTier(tierNumber: 1, targetValue: 500, coinReward: 20, hintReward: 1),
        AchievementTier(tierNumber: 2, targetValue: 1800, coinReward: 40, hintReward: 2),
        AchievementTier(tierNumber: 3, targetValue: 3600, coinReward: 60, hintReward: 3),
      ],
    ),
  ];

  int getStatValue(UserProgress progress, String achievementId) {
    switch (achievementId) {
      case 'word_hunter':
        return progress.completedLevels.length * 5; // average 5 words per level found
      case 'world_wanderer':
        return _countCompletedWorlds(progress);
      case 'level_champion':
      case 'legend_of_words':
        return progress.completedLevels.length;
      case 'star_collector':
        return progress.getTotalStars();
      case 'daily_master':
        return progress.completedDailyPuzzles.length;
      case 'food_connoisseur':
        return _countWorldLevels(progress, 1);
      case 'ocean_diver':
        return _countWorldLevels(progress, 20);
      case 'avian_watcher':
        return _countWorldLevels(progress, 18);
      case 'safari_ranger':
        return _countWorldLevels(progress, 26);
      case 'coin_tycoon':
        return progress.coins;
      default:
        return progress.completedLevels.length;
    }
  }

  int _countWorldLevels(UserProgress progress, int worldId) {
    int count = 0;
    for (int lvl = 1; lvl <= 120; lvl++) {
      if (progress.isLevelCompleted(worldId, lvl)) {
        count++;
      }
    }
    return count;
  }

  int _countCompletedWorlds(UserProgress progress) {
    int worlds = 0;
    for (int w = 1; w <= 30; w++) {
      if (_countWorldLevels(progress, w) >= 120) {
        worlds++;
      }
    }
    return worlds;
  }
}
