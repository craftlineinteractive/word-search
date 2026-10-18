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

  void _claimTier(Achievement achievement, int tierIndex) async {
    if (_progress == null) return;
    final tier = achievement.tiers[tierIndex];
    SoundManager.instance.playVictoryFanfare();

    setState(() {
      _progress!.addCoins(tier.coinReward);
      if (tier.hintReward > 0) {
        _progress!.hints += tier.hintReward;
      }
    });

    await _progress!.save();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Claimed +${tier.coinReward} Coins! ★'),
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
                          final nextTarget = ach.getNextTierTarget(completedTier);
                          final double progressFraction =
                              (currentVal / (nextTarget > 0 ? nextTarget : 1)).clamp(0.0, 1.0);

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

                                // Claimable Rewards Button if completed
                                if (completedTier > 0) ...[
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: OrganicWoodButton(
                                      height: 38,
                                      fontSize: 13,
                                      variant: WoodButtonVariant.primary,
                                      text:
                                          'Claim +${ach.tiers[completedTier - 1].coinReward} Coins',
                                      onPressed: () => _claimTier(ach, completedTier - 1),
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
