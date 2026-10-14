import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_search/screens/settings_screen.dart';
import 'package:word_search/services/in_app_review_service.dart';
import 'package:word_search/widgets/rating_bottom_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 10 - Official Native In-App Review QA', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('InAppReviewService singleton initializes correctly', () {
      final service1 = InAppReviewService.instance;
      final service2 = InAppReviewService();
      expect(service1, same(service2));
      expect(InAppReviewService.playStoreUrl, contains('com.craftlineinteractive.wordsearch'));
    });

    test('hasAlreadyRated tracks and persists rated state', () async {
      expect(await InAppReviewService.instance.hasAlreadyRated(), isFalse);

      await InAppReviewService.instance.markAsRated();
      expect(await InAppReviewService.instance.hasAlreadyRated(), isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(InAppReviewService.keyHasRated), isTrue);
    });

    test('requestReviewRandomly ignores early levels (< 3)', () async {
      final prefs = await SharedPreferences.getInstance();
      await InAppReviewService.instance.requestReviewRandomly(
        completedLevel: 1,
        probability: 1.0,
      );
      expect(prefs.getInt('wp_last_review_prompt_level'), isNull);

      await InAppReviewService.instance.requestReviewRandomly(
        completedLevel: 2,
        probability: 1.0,
      );
      expect(prefs.getInt('wp_last_review_prompt_level'), isNull);
    });

    test('requestReviewRandomly NEVER prompts if user has already rated', () async {
      // Mark as already rated
      await InAppReviewService.instance.markAsRated();
      expect(await InAppReviewService.instance.hasAlreadyRated(), isTrue);

      final prefs = await SharedPreferences.getInstance();

      // Attempt to prompt with level 10 and 100% probability
      await InAppReviewService.instance.requestReviewRandomly(
        completedLevel: 10,
        probability: 1.0,
      );

      // Verify that it immediately returned and never recorded a prompt level
      expect(prefs.getInt('wp_last_review_prompt_level'), isNull);
      expect(prefs.getInt('wp_review_prompt_count'), isNull);
    });

    test('requestReviewRandomly does not prompt when probability is 0.0', () async {
      final prefs = await SharedPreferences.getInstance();
      await InAppReviewService.instance.requestReviewRandomly(
        completedLevel: 5,
        probability: 0.0,
      );
      expect(prefs.getInt('wp_last_review_prompt_level'), isNull);
    });

    testWidgets('RatingBottomSheet.showRandomly never prompts if already rated', (WidgetTester tester) async {
      await InAppReviewService.instance.markAsRated();

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            RatingBottomSheet.showRandomly(context, probability: 1.0);
            return const Placeholder();
          },
        ),
      );
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('wp_last_review_prompt_level'), isNull);
    });

    testWidgets('SettingsScreen Rate Word Search tile triggers InAppReviewService', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final rateTileFinder = find.text('Rate Word Search');
      expect(rateTileFinder, findsOneWidget);

      // Verify subtitle exists
      expect(find.text('Support us with 5 stars on Play Store'), findsOneWidget);

      // Tap the rate tile
      await tester.tap(rateTileFinder);
      await tester.pumpAndSettle();

      // Ensure NO custom modal bottom sheet appears
      expect(find.text('RATE ON PLAY STORE'), findsNothing);
      expect(find.text('Enjoying Word Search?'), findsNothing);
      expect(find.text('MAYBE LATER'), findsNothing);

      // Verify that interacting with rate tile marks as rated
      expect(await InAppReviewService.instance.hasAlreadyRated(), isTrue);
    });
  });
}
