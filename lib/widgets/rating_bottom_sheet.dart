import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/in_app_review_service.dart';
import '../services/sound_manager.dart';
import '../theme/app_theme.dart';

class RatingBottomSheet extends StatefulWidget {
  const RatingBottomSheet({super.key});

  static const String keyHasRated = InAppReviewService.keyHasRated;
  static const String playStoreUrl = InAppReviewService.playStoreUrl;

  /// Triggers native Google Play in-app review randomly if not already rated. No custom UI.
  static Future<void> showRandomly(BuildContext context, {double probability = 0.25}) async {
    if (await InAppReviewService.instance.hasAlreadyRated()) return;
    await InAppReviewService.instance.requestReviewRandomly(probability: probability);
  }

  /// Triggers native Google Play in-app review dialog or store listing fallback. No custom UI.
  static Future<void> show(BuildContext context) async {
    await InAppReviewService.instance.requestReviewOrStore();
  }

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  int _selectedStars = 5;

  Future<void> _submitRating() async {
    SoundManager.instance.playButtonClick();
    await InAppReviewService.instance.markAsRated();

    if (!mounted) return;
    Navigator.pop(context);

    if (_selectedStars >= 4) {
      // Redirect to Google Play Store page
      try {
        final uri = Uri.parse(RatingBottomSheet.playStoreUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(uri);
        }
      } catch (_) {}
    } else {
      // Thank user for feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Thank you for your valuable feedback!',
            style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xFF1E88E5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final bgColor = isDark ? const Color(0xFF0C1838) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF90A4AE) : const Color(0xFF64748B);
    final starColor = const Color(0xFFFFD700);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(30) : Colors.black.withAlpha(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle pill
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: starColor.withAlpha(35),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.stars_rounded, color: starColor, size: 48),
          ),

          const SizedBox(height: 16),

          Text(
            'Enjoying Word Search?',
            style: TextStyle(
              color: textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Fredoka',
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Tap stars to rate us on Google Play Store!\nYour support helps us create more worlds.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textSecondary,
              fontSize: 14,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 24),

          // 5 Stars Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starNum = index + 1;
              final isSelected = starNum <= _selectedStars;
              return IconButton(
                onPressed: () {
                  SoundManager.instance.playButtonClick();
                  setState(() => _selectedStars = starNum);
                },
                iconSize: 42,
                icon: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isSelected ? starColor : (isDark ? Colors.white30 : Colors.black26),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          // Submit Action Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Text(
                _selectedStars >= 4 ? 'RATE ON PLAY STORE' : 'SUBMIT FEEDBACK',
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () {
              SoundManager.instance.playButtonClick();
              Navigator.pop(context);
            },
            child: Text(
              'MAYBE LATER',
              style: TextStyle(
                color: textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
