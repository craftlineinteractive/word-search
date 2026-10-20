import 'package:flutter_test/flutter_test.dart';
import 'package:word_search/models/achievement.dart';
import 'package:word_search/models/user_progress.dart';
import 'package:word_search/services/achievement_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 14 - Stars, Hint Ratings, and 3-Star Achievement Rewards', () {
    test('Level stars are tracked properly and update to higher stars on replay', () {
      final progress = UserProgress();

      // Complete level 1 with 1 star (e.g. used 2 hints)
      progress.completeLevel(1, 1, stars: 1);
      expect(progress.isLevelCompleted(1, 1), isTrue);
      expect(progress.getLevelStars(1, 1), equals(1));
      expect(progress.getTotalStars(), equals(1));
      expect(progress.getStarsForChapter(1), equals(1));

      // Replay level 1 with 2 stars (e.g. used 1 hint) -> increases to 2
      progress.completeLevel(1, 1, stars: 2);
      expect(progress.getLevelStars(1, 1), equals(2));
      expect(progress.getTotalStars(), equals(2));

      // Replay level 1 with 3 stars (0 hints) -> increases to 3
      progress.completeLevel(1, 1, stars: 3);
      expect(progress.getLevelStars(1, 1), equals(3));
      expect(progress.getTotalStars(), equals(3));

      // Replaying with lower stars does not downgrade the high score
      progress.completeLevel(1, 1, stars: 1);
      expect(progress.getLevelStars(1, 1), equals(3));
      expect(progress.getTotalStars(), equals(3));

      // Complete level 2 with 2 stars
      progress.completeLevel(1, 2, stars: 2);
      expect(progress.getLevelStars(1, 2), equals(2));
      expect(progress.getTotalStars(), equals(5));
      expect(progress.getStarsForChapter(1), equals(5));
    });

    test('UserProgress serialization and deserialization preserves levelStars', () {
      final progress = UserProgress(
        coins: 120,
        hints: 4,
        levelStars: {'1_1': 3, '1_2': 2, '1_3': 1},
        completedLevels: {'1_1', '1_2', '1_3'},
      );

      final jsonMap = progress.toJson();
      expect(jsonMap['levelStars'], isNotNull);
      expect(jsonMap['levelStars']['1_1'], equals(3));
      expect(jsonMap['levelStars']['1_2'], equals(2));
      expect(jsonMap['levelStars']['1_3'], equals(1));

      final restored = UserProgress.fromJson(jsonMap);
      expect(restored.getLevelStars(1, 1), equals(3));
      expect(restored.getLevelStars(1, 2), equals(2));
      expect(restored.getLevelStars(1, 3), equals(1));
      expect(restored.getTotalStars(), equals(6));
    });

    test('Each achievement in catalog has exactly 3 star tiers with small rewards', () {
      final catalog = AchievementService.catalog;
      expect(catalog.length, equals(16));

      for (final ach in catalog) {
        expect(ach.tiers.length, equals(3), reason: '${ach.title} must have exactly 3 star tiers');
        expect(ach.tiers[0].tierNumber, equals(1));
        expect(ach.tiers[1].tierNumber, equals(2));
        expect(ach.tiers[2].tierNumber, equals(3));

        // Verify rewards are modest (10 to 60 coins, 1 to 3 hints)
        for (final tier in ach.tiers) {
          expect(tier.coinReward, inInclusiveRange(10, 60));
          expect(tier.hintReward, inInclusiveRange(1, 3));
        }
      }
    });

    test('Achievement claim progression handles Star 1, Star 2, and Star 3 sequentially', () {
      final progress = UserProgress();
      const ach = Achievement(
        id: 'test_ach',
        title: 'Test Star Achievement',
        description: 'Test description',
        tiers: [
          AchievementTier(tierNumber: 1, targetValue: 10, coinReward: 10, hintReward: 1),
          AchievementTier(tierNumber: 2, targetValue: 25, coinReward: 20, hintReward: 1),
          AchievementTier(tierNumber: 3, targetValue: 50, coinReward: 35, hintReward: 2),
        ],
      );

      // Initially no stars completed
      expect(ach.getCompletedTier(5), equals(0));
      expect(progress.getClaimedAchievementTier(ach.id), equals(0));

      // Reach Star 1 target (10)
      expect(ach.getCompletedTier(12), equals(1));
      progress.claimAchievementTier(ach.id, 1);
      expect(progress.getClaimedAchievementTier(ach.id), equals(1));
      expect(progress.isAchievementTierClaimed(ach.id, 1), isTrue);
      expect(progress.isAchievementTierClaimed(ach.id, 2), isFalse);

      // Reach Star 2 target (25)
      expect(ach.getCompletedTier(30), equals(2));
      progress.claimAchievementTier(ach.id, 2);
      expect(progress.getClaimedAchievementTier(ach.id), equals(2));
      expect(progress.isAchievementTierClaimed(ach.id, 2), isTrue);
      expect(progress.isAchievementTierClaimed(ach.id, 3), isFalse);

      // Reach Star 3 target (50)
      expect(ach.getCompletedTier(55), equals(3));
      progress.claimAchievementTier(ach.id, 3);
      expect(progress.getClaimedAchievementTier(ach.id), equals(3));
      expect(progress.isAchievementTierClaimed(ach.id, 3), isTrue);
    });

    test('World unlock requirements are smooth and achievable for any gamer', () {
      final progress = UserProgress();

      // World 1 requires 0 stars
      expect(progress.getRequiredStarsForChapter(1), equals(0));
      expect(progress.isChapterUnlocked(1), isTrue);

      // World 2 requires 30 stars (achievable in 10-15 levels out of 120)
      expect(progress.getRequiredStarsForChapter(2), equals(30));

      // World 3 requires 60 stars
      expect(progress.getRequiredStarsForChapter(3), equals(60));

      // World 30 requires 870 stars
      expect(progress.getRequiredStarsForChapter(30), equals(870));
    });
  });
}
