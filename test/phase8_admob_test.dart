import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_search/services/ad_manager.dart';
import 'package:word_search/widgets/banner_ad_widget.dart';
import 'package:word_search/widgets/reward_ad_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 8 - Google AdMob Ads & Monetization Architecture QA', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('AdManager contains valid user production and test ad unit IDs', () {
      final manager = AdManager.instance;
      expect(
        AdManager.prodAppId,
        equals('ca-app-pub-9274756665778143~5341916389'),
      );
      expect(
        AdManager.prodBannerAdUnitId,
        equals('ca-app-pub-9274756665778143/1314895679'),
      );
      expect(
        AdManager.prodInterstitialAdUnitId,
        equals('ca-app-pub-9274756665778143/6375650663'),
      );
      expect(
        AdManager.prodRewardedAdUnitId,
        equals('ca-app-pub-9274756665778143/6470274573'),
      );

      expect(manager.bannerAdUnitId, isNotEmpty);
      expect(manager.interstitialAdUnitId, isNotEmpty);
      expect(manager.rewardedAdUnitId, isNotEmpty);
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
