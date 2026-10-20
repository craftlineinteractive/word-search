import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/user_progress.dart';
import '../services/achievement_service.dart';
import '../services/sound_manager.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_particles_overlay.dart';
import '../widgets/organic_wood_button.dart';
import '../widgets/parchment_card.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  UserProgress? _progress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await UserProgress.load();
    if (mounted) {
      setState(() {
        _progress = progress;
        _isLoading = false;
      });
    }
  }

  int _calculateMilestoneStars() {
    if (_progress == null) return 0;
    int stars = 0;
    for (final ach in AchievementService.catalog) {
      final currentVal = AchievementService.instance.getStatValue(_progress!, ach.id);
      stars += ach.getCompletedTier(currentVal);
    }
    return stars;
  }

  void _claimTier(Achievement achievement, int tierNumber) async {
    if (_progress == null) return;
    final tier = achievement.tiers[tierNumber - 1];
    SoundManager.instance.playVictoryFanfare();

    setState(() {
      _progress!.addCoins(tier.coinReward);
      if (tier.hintReward > 0) {
        _progress!.hints += tier.hintReward;
      }
      _progress!.claimAchievementTier(achievement.id, tierNumber);
    });

    await _progress!.save();

    if (mounted) {
      final hintText = tier.hintReward > 0 ? ' & +${tier.hintReward} Hint${tier.hintReward > 1 ? 's' : ''}' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Claimed ★ Star $tierNumber: +${tier.coinReward} Coins$hintText!'),
          backgroundColor: const Color(0xFF15803D),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color strokeDark = Color(0xFF2A1810);
    final totalMilestoneStars = _calculateMilestoneStars();

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Achievements',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: strokeDark,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: strokeDark),
          onPressed: () {
            SoundManager.instance.playButtonClick();
            Navigator.pop(context);
          },
        ),
        actions: [
          if (_progress != null)
            Padding(
              padding: const EdgeInsets.only(right: 14.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9E6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: strokeDark, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFB300), size: 16),
                        const SizedBox(width: 3),
                        Text(
                          '${_progress!.coins}',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            color: strokeDark,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: strokeDark, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_rounded, color: Color(0xFF0284C7), size: 16),
                        const SizedBox(width: 3),
                        Text(
                          '${_progress!.hints}',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            color: strokeDark,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Ambient Forest Fireflies Overlay
                const AmbientParticlesOverlay(
                  maxParticles: 12,
                  type: ParticleType.fireflies,
                ),

                Column(
                  children: [
                    // Top Milestone Stars Summary Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      child: ParchmentCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/game_art/shared/ui/ui_star_gold.png',
                              width: 36,
                              height: 36,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFB300),
                                size: 36,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Milestone Stars',
                                    style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: strokeDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$totalMilestoneStars / 48 Stars Earned across 16 Achievements',
                                    style: const TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 12,
                                      color: Color(0xFF6B584E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB300),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: strokeDark, width: 1.5),
                              ),
                              child: Text(
                                '$totalMilestoneStars ★',
                                style: const TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: strokeDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Scrollable List of 16 Achievements
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        itemCount: AchievementService.catalog.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final ach = AchievementService.catalog[index];
                          final currentVal =
                              AchievementService.instance.getStatValue(_progress!, ach.id);
                          final completedTier = ach.getCompletedTier(currentVal);
                          final claimedTier = _progress!.getClaimedAchievementTier(ach.id);
                          final nextTarget = ach.getNextTierTarget(completedTier);
                          final double progressFraction =
                              (currentVal / (nextTarget > 0 ? nextTarget : 1)).clamp(0.0, 1.0);
                          final bool canClaim = completedTier > claimedTier;
                          final int tierToClaim = claimedTier + 1;

                          return ParchmentCard(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ach.title,
                                            style: const TextStyle(
                                              fontFamily: 'Fredoka',
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: strokeDark,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            ach.description,
                                            style: const TextStyle(
                                              fontFamily: 'Fredoka',
                                              fontSize: 12,
                                              color: Color(0xFF6B584E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // 3-Star Milestone Indicators
                                    Row(
                                      children: List.generate(3, (starIdx) {
                                        final isEarned = starIdx < completedTier;
                                        return Padding(
                                          padding: const EdgeInsets.only(left: 3.0),
                                          child: Icon(
                                            isEarned ? Icons.star_rounded : Icons.star_border_rounded,
                                            color: isEarned
                                                ? (starIdx == 2
                                                    ? const Color(0xFFFFB300) // Gold
                                                    : starIdx == 1
                                                        ? const Color(0xFF94A3B8) // Silver
                                                        : const Color(0xFFB45309)) // Bronze
                                                : const Color(0xFFCBD5E1),
                                            size: 22,
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Progress Bar and Values
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: progressFraction,
                                          minHeight: 8,
                                          backgroundColor: const Color(0xFFE2E8F0),
                                          valueColor: const AlwaysStoppedAnimation<Color>(
                                            Color(0xFF16A34A),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '$currentVal / $nextTarget',
                                      style: const TextStyle(
                                        fontFamily: 'Fredoka',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: strokeDark,
                                      ),
                                    ),
                                  ],
                                ),


                                // Claimable Rewards Button or Claimed Status Badge
                                if (canClaim) ...[
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: OrganicWoodButton(
                                      height: 38,
                                      fontSize: 13,
                                      variant: WoodButtonVariant.forest,
                                      text: () {
                                        final t = ach.tiers[tierToClaim - 1];
                                        final hintPart = t.hintReward > 0
                                            ? ', +${t.hintReward} Hint${t.hintReward > 1 ? 's' : ''}'
                                            : '';
                                        return 'Claim ★ Star $tierToClaim (+${t.coinReward} Coins$hintPart)';
                                      }(),
                                      onPressed: () => _claimTier(ach, tierToClaim),
                                    ),
                                  ),
                                ] else if (claimedTier >= ach.tiers.length) ...[
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFF2E7D32), width: 1.2),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF2E7D32)),
                                          SizedBox(width: 4),
                                          Text(
                                            'All 3 Stars Claimed',
                                            style: TextStyle(
                                              fontFamily: 'Fredoka',
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1B5E20),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ] else if (claimedTier > 0) ...[
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFF94A3B8), width: 1.0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.check_rounded, size: 14, color: Color(0xFF475569)),
                                          const SizedBox(width: 4),
                                          Text(
                                            '★ Star $claimedTier of 3 Claimed',
                                            style: const TextStyle(
                                              fontFamily: 'Fredoka',
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF475569),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
