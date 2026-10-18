import 'dart:math';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service managing the official Google Play In-App Review / Store Review API.
///
/// This provides the exact native Google Play bottom sheet review dialog
/// (rating stars, optional comments, submit, and confirmation) without any custom UI.
class InAppReviewService {
  static final InAppReviewService instance = InAppReviewService._internal();

  factory InAppReviewService() => instance;

  InAppReviewService._internal();

  final InAppReview _inAppReview = InAppReview.instance;

  static const String keyHasRated = 'wp_has_rated_app_v1';
  static const String _keyLastPromptLevel = 'wp_last_review_prompt_level';
  static const String _keyPromptCount = 'wp_review_prompt_count';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.craftlineinteractive.wordsearch';

  /// Checks if the user has already rated the game.
  Future<bool> hasAlreadyRated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(keyHasRated) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Marks the user as already rated so they are never prompted again.
  Future<void> markAsRated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyHasRated, true);
    } catch (_) {}
  }

  /// Checks whether native in-app review is available on this platform/device.
  Future<bool> isAvailable() async {
    try {
      return await _inAppReview.isAvailable();
    } catch (_) {
      return false;
    }
  }

  /// Triggers the official native In-App Review dialog (Google Play In-App Review).
  ///
  /// Used for explicit user actions (e.g. tapping "Rate Word Search" in Settings).
  /// - If native In-App Review is available, invokes `requestReview()`, displaying the
  ///   official Google Play review sheet inside the app.
  /// - If not available (or on fallback), directly opens the Google Play Store listing.
  Future<void> requestReviewOrStore({bool forceStoreFallback = true}) async {
    await markAsRated();
    try {
      final available = await isAvailable();
      if (available) {
        await _inAppReview.requestReview();
      } else if (forceStoreFallback) {
        await openStoreListing();
      }
    } catch (_) {
      if (forceStoreFallback) {
        await openStoreListing();
      }
    }
  }

  /// Opens the Google Play Store listing directly.
  Future<void> openStoreListing() async {
    await markAsRated();

    // 1. Try market:// details URI which launches Google Play Store app directly
    try {
      final marketUri = Uri.parse('market://details?id=com.craftlineinteractive.wordsearch');
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    // 2. Try in_app_review plugin
    try {
      await _inAppReview.openStoreListing(
        appStoreId: 'com.craftlineinteractive.wordsearch',
      );
      await markAsRated();
      return;
    } catch (_) {}

    // 3. Fallback to web Play Store link with external browser
    try {
      final uri = Uri.parse(playStoreUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      await markAsRated();
    } catch (_) {
      try {
        final uri = Uri.parse(playStoreUrl);
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }

  /// Triggers the official native in-app review dialog randomly after level completion.
  ///
  /// Key rules:
  /// 1. NEVER shows if the user has already rated (`hasAlreadyRated() == true`).
  /// 2. Uses ONLY the native Google Play In-App Review dialog — NO custom UI.
  /// 3. Respects user onboarding: Only prompts after level >= 3.
  /// 4. Spacing: Requires at least 5 levels completed between prompts.
  /// 5. Respects probability (defaults to 25%).
  /// 6. Never interrupts gameplay with external browser links if review is unavailable.
  /// 7. Once requested, marks the app as rated so the player is NEVER prompted again.
  Future<void> requestReviewRandomly({
    int completedLevel = 1,
    double probability = 0.25,
  }) async {
    try {
      // 1. NEVER prompt if user has already rated
      if (await hasAlreadyRated()) return;

      // 2. Don't prompt on initial levels to ensure positive engagement
      if (completedLevel < 3) return;

      // Guaranteed milestone triggers (Level 5, 15, 30) where user has positive momentum
      final bool isMilestone = (completedLevel == 5 || completedLevel == 15 || completedLevel == 30);

      final prefs = await SharedPreferences.getInstance();
      final lastLevel = prefs.getInt(_keyLastPromptLevel) ?? 0;

      if (!isMilestone) {
        if (completedLevel - lastLevel < 5) return;
        final rand = Random().nextDouble();
        if (rand >= probability) return;
      }

      // Check if native review is available
      final available = await isAvailable();
      if (!available) return;

      // Save prompt level and increment counter
      await prefs.setInt(_keyLastPromptLevel, completedLevel);
      final count = prefs.getInt(_keyPromptCount) ?? 0;
      await prefs.setInt(_keyPromptCount, count + 1);

      // Launch official native Google Play In-App Review dialog
      await _inAppReview.requestReview();

      // Immediately mark as rated so the player is NEVER prompted again
      await markAsRated();
    } catch (_) {}
  }
}
