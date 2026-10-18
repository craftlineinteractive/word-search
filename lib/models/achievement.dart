class AchievementTier {
  final int tierNumber; // 1 (Bronze), 2 (Silver), 3 (Gold)
  final int targetValue;
  final int coinReward;
  final int hintReward;

  const AchievementTier({
    required this.tierNumber,
    required this.targetValue,
    required this.coinReward,
    this.hintReward = 0,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final List<AchievementTier> tiers;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.tiers,
  });

  /// Returns the highest completed tier index (1, 2, or 3) for a given stat value, or 0 if none.
  int getCompletedTier(int currentVal) {
    if (tiers.length >= 3 && currentVal >= tiers[2].targetValue) return 3;
    if (tiers.length >= 2 && currentVal >= tiers[1].targetValue) return 2;
    if (tiers.isNotEmpty && currentVal >= tiers[0].targetValue) return 1;
    return 0;
  }

  /// Returns the target value for the next active tier to reach.
  int getNextTierTarget(int claimedTier) {
    if (claimedTier >= tiers.length) {
      return tiers.last.targetValue;
    }
    return tiers[claimedTier].targetValue;
  }
}
