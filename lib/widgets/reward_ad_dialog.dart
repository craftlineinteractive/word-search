import 'package:flutter/material.dart';
import '../models/user_progress.dart';
import '../services/ad_manager.dart';
import '../services/sound_manager.dart';

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

  void _watchAd() {
    SoundManager.instance.playButtonClick();
    setState(() => _isLoadingAd = true);

    AdManager.instance.showRewardedAd(
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
              ),
              backgroundColor: const Color(0xFF00E676),
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
              content: Text('Ad is loading or unavailable. Please try again shortly.'),
              backgroundColor: Color(0xFFE53935),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCoins = _selectedType == RewardType.coins;

    return AlertDialog(
      backgroundColor: const Color(0xFF0C1938),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFF1E3A6D), width: 1.5),
      ),
      title: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF9100)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9100).withAlpha(150),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              isCoins ? Icons.monetization_on_rounded : Icons.lightbulb_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Free Rewards!',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Watch a short sponsored video to claim your reward instantly:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 14,
              color: Color(0xFF90A4AE),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 18),

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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isCoins ? const Color(0xFF1E88E5) : const Color(0xFF132347),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCoins ? const Color(0xFF42A5F5) : const Color(0xFF1E3A6D),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD700), size: 28),
                        SizedBox(height: 4),
                        Text(
                          '+50 COINS',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    SoundManager.instance.playButtonClick();
                    setState(() => _selectedType = RewardType.hint);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !isCoins ? const Color(0xFF1E88E5) : const Color(0xFF132347),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: !isCoins ? const Color(0xFF42A5F5) : const Color(0xFF1E3A6D),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.lightbulb_rounded, color: Color(0xFFFFB300), size: 28),
                        SizedBox(height: 4),
                        Text(
                          '+1 FREE HINT',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _isLoadingAd ? null : _watchAd,
              icon: _isLoadingAd
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.play_circle_filled_rounded, size: 24),
              label: Text(
                _isLoadingAd ? 'LOADING AD...' : 'WATCH VIDEO',
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
