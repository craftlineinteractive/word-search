import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_search/models/user_progress.dart';
import 'package:word_search/screens/shop_screen.dart';
import 'package:word_search/services/ad_manager.dart';
import 'package:word_search/services/iap_manager.dart';
import 'package:word_search/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 9 - In-App Purchases & Coin Shop QA', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('IAP product catalog has low prices and correct coin/hint values', () {
      final catalog = IapManager.catalog;
      expect(catalog.length, equals(6));

      final removeAds = catalog.firstWhere((p) => p.isRemoveAds);
      expect(removeAds.id, equals(IapManager.idRemoveAds));

      final coins500 = catalog.firstWhere((p) => p.id == IapManager.idCoins500);
      expect(coins500.coins, equals(500));

      final coins1500 = catalog.firstWhere((p) => p.id == IapManager.idCoins1500);
      expect(coins1500.coins, equals(1500));
      expect(coins1500.hints, equals(5));

      final coins5000 = catalog.firstWhere((p) => p.id == IapManager.idCoins5000);
      expect(coins5000.coins, equals(5000));
      expect(coins5000.hints, equals(20));
    });

    test('deliverProduct correctly awards coins and hints', () async {
      final iap = IapManager.instance;

      // Deliver 500 coins
      await iap.deliverProduct(IapManager.idCoins500);
      var progress = await UserProgress.load();
      expect(progress.coins, equals(50 + 500));

      // Deliver 1500 coins + 5 hints
      await iap.deliverProduct(IapManager.idCoins1500);
      progress = await UserProgress.load();
      expect(progress.coins, equals(550 + 1500));
      expect(progress.hints, equals(3 + 5));

      // Deliver Remove Ads
      expect(progress.adsRemoved, isFalse);
      await iap.deliverProduct(IapManager.idRemoveAds);
      progress = await UserProgress.load();
      expect(progress.adsRemoved, isTrue);
      expect(AdManager.instance.isAdsRemoved, isTrue);
    });

    testWidgets('ShopScreen renders in Dark Mode with all products and Restore button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const ShopScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Coin Shop'), findsOneWidget);
      expect(find.text('REMOVE ALL ADS'), findsOneWidget);
      expect(find.text('Handful of Coins'), findsOneWidget);
      expect(find.text('Chest of Coins'), findsOneWidget);
      expect(find.text('Vault of Coins'), findsOneWidget);
      expect(find.text('Free Video Reward'), findsOneWidget);
      expect(find.text('Restore Purchases'), findsOneWidget);
    });

    testWidgets('ShopScreen renders in Light Mode without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: const ShopScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Coin Shop'), findsOneWidget);
      expect(find.text('REMOVE ALL ADS'), findsOneWidget);
      expect(find.text('Handful of Coins'), findsOneWidget);
    });
  });
}
