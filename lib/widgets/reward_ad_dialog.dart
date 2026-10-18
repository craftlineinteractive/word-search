import 'package:flutter/material.dart';
import '../models/user_progress.dart';
import '../services/ad_manager.dart';
import '../services/sound_manager.dart';
import 'organic_wood_button.dart';
import 'parchment_card.dart';

enum RewardType { coins, hint }

class RewardAdDialog extends StatefulWidget {
  final RewardType initialType;
  final Function(RewardType type) onRewardClaimed;

  const RewardAdDialog({
    super.key,
    this.initialType = RewardType.coins,
    required this.onRewardClaimed,
  });

  static Future<void> show(
    BuildContext context, {
    RewardType type = RewardType.coins,
    required Function(RewardType type) onRewardClaimed,
  }) {
    return showDialog(
      context: context,
      builder: (_) => RewardAdDialog(
        initialType: type,
        onRewardClaimed: onRewardClaimed,
      ),
    );
  }

  @override
  State<RewardAdDialog> createState() => _RewardAdDialogState();
}

class _RewardAdDialogState extends State<RewardAdDialog> {
  late RewardType _selectedType;
  bool _isLoadingAd = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    AdManager.instance.preloadRewarded();
  }

  Future<void> _watchAd() async {
    if (_isLoadingAd) return;
    SoundManager.instance.playButtonClick();
    setState(() => _isLoadingAd = true);

    await AdManager.instance.showRewardedAd(
      onUserEarnedReward: (reward) async {
        final progress = await UserProgress.load();
        if (_selectedType == RewardType.coins) {
          progress.addCoins(50);
        } else {
          progress.hints += 1;
        }
        await progress.save();

        SoundManager.instance.playLevelWin();

        if (mounted) {
          Navigator.pop(context);
          widget.onRewardClaimed(_selectedType);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _selectedType == RewardType.coins
                    ? '🎉 You earned +50 Free Coins!'
                    : '💡 You earned +1 Free Hint!',
                style: const TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFF2E7D32),
            ),
          );
        }
      },
      onAdDismissed: () {
        if (mounted) setState(() => _isLoadingAd = false);
      },
      onAdFailedToLoad: () {
        if (mounted) {
          setState(() => _isLoadingAd = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Ad is loading or unavailable. Please try again shortly.',
                style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold),
              ),
              backgroundColor: Color(0xFFC62828),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCoins = _selectedType == RewardType.coins;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: ParchmentCard(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reward Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD54F), Color(0xFFFF9800)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF5D4037), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2A1810).withAlpha(100),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isCoins ? Icons.monetization_on_rounded : Icons.lightbulb_rounded,
                size: 38,
                color: const Color(0xFF2A1810),
              ),
            ),
            const SizedBox(height: 14),

            const Text(
              'Free Rewards!',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2A1810),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              'Watch a short sponsored video to claim your reward instantly:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 13,
                color: Color(0xFF5D4037),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),

            // Reward Selection Tabs
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      SoundManager.instance.playButtonClick();
                      setState(() => _selectedType = RewardType.coins);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isCoins ? const Color(0xFFFFD54F) : const Color(0xFFFFFDF5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCoins ? const Color(0xFFE65100) : const Color(0xFFD7CCC8),
                          width: isCoins ? 2.0 : 1.2,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.monetization_on_rounded, color: Color(0xFFE65100), size: 26),
                          SizedBox(height: 4),
                          Text(
                            '+50 COINS',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              color: Color(0xFF2A1810),
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      SoundManager.instance.playButtonClick();
                      setState(() => _selectedType = RewardType.hint);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !isCoins ? const Color(0xFFFFD54F) : const Color(0xFFFFFDF5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: !isCoins ? const Color(0xFFE65100) : const Color(0xFFD7CCC8),
                          width: !isCoins ? 2.0 : 1.2,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.lightbulb_rounded, color: Color(0xFFFFA000), size: 26),
                          SizedBox(height: 4),
                          Text(
                            '+1 FREE HINT',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              color: Color(0xFF2A1810),
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Watch Video Button
            OrganicWoodButton(
              text: _isLoadingAd ? 'LOADING AD...' : 'WATCH VIDEO',
              icon: Icons.play_circle_filled_rounded,
              variant: WoodButtonVariant.forest,
              height: 48,
              onPressed: _isLoadingAd ? () {} : _watchAd,
            ),
            const SizedBox(height: 8),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'MAYBE LATER',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8D6E63),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
