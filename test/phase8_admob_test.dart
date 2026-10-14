import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_search/services/ad_manager.dart';
import 'package:word_search/widgets/banner_ad_widget.dart';
import 'package:word_search/widgets/reward_ad_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 8 - Unity LevelPlay Ads & Monetization Architecture QA', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('AdManager contains valid user Unity LevelPlay credentials', () {
      final manager = AdManager.instance;
      expect(
        AdManager.prodAppKey,
        equals('28024314d'),
      );
      expect(
        AdManager.prodBannerAdUnitId,
        equals('7n3t4ahi0tyf7rbh'),
      );
      expect(
        AdManager.prodInterstitialAdUnitId,
        equals('bktm1o6v90p3nn67'),
      );
      expect(
        AdManager.prodRewardedAdUnitId,
        equals('wu6ot3k21l8yqukp'),
      );

      expect(manager.appKey, equals('28024314d'));
      expect(manager.bannerAdUnitId, equals('7n3t4ahi0tyf7rbh'));
      expect(manager.interstitialAdUnitId, equals('bktm1o6v90p3nn67'));
      expect(manager.rewardedAdUnitId, equals('wu6ot3k21l8yqukp'));
    });

    test('AdManager respects Ads Removed purchase state', () {
      final manager = AdManager.instance;
      manager.setAdsRemoved(true);
      expect(manager.isAdsRemoved, isTrue);

      bool callbackFired = false;
      manager.showInterstitialIfEligible(
        onAdClosed: () => callbackFired = true,
      );
      expect(callbackFired, isTrue);

      manager.setAdsRemoved(false);
      expect(manager.isAdsRemoved, isFalse);
    });

    testWidgets(
      'BannerAdWidget renders graceful fallback when running in test environment',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: BannerAdWidget())),
        );
        await tester.pumpAndSettle();

        expect(find.text('AD SPACE RESERVED'), findsOneWidget);
      },
    );

    testWidgets(
      'RewardAdDialog renders coins and hint options and switches tabs',
      (WidgetTester tester) async {
        RewardType? claimedReward;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RewardAdDialog(
                initialType: RewardType.coins,
                onRewardClaimed: (type) => claimedReward = type,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Free Rewards!'), findsOneWidget);
        expect(find.text('+50 COINS'), findsOneWidget);
        expect(find.text('+1 FREE HINT'), findsOneWidget);
        expect(find.text('WATCH VIDEO'), findsOneWidget);

        // Switch to Hint tab
        await tester.tap(find.text('+1 FREE HINT'));
        await tester.pumpAndSettle();

        expect(claimedReward, isNull);
      },
    );
  });
}
