import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_search/models/chapter.dart';
import 'package:word_search/models/puzzle_level.dart';
import 'package:word_search/models/user_progress.dart';
import 'package:word_search/models/word_item.dart';
import 'package:word_search/screens/gameplay_screen.dart';
import 'package:word_search/services/sound_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers.global'),
          (MethodCall methodCall) async => 1,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers'),
          (MethodCall methodCall) async => 1,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.craftline.wordsearch/haptics'),
          (MethodCall methodCall) async => 1,
        );
  });

  group('Phase 11 - Skip Level Booster & Coin Mechanics QA', () {
    final sampleWords = [
      WordItem(word: 'PIZZA', meaning: 'Italian dish', example: 'Hot pizza'),
      WordItem(word: 'APPLE', meaning: 'Fruit', example: 'Crisp apple'),
      WordItem(word: 'BREAD', meaning: 'Baked dough', example: 'Fresh bread'),
    ];

    final testLevel = PuzzleLevel(
      levelNumber: 1,
      title: 'Food 1',
      gridRows: 9,
      gridCols: 9,
      difficulty: 'normal',
      words: sampleWords,
    );

    final testChapter = Chapter(
      id: 1,
      key: 'food',
      title: 'Food',
      iconAsset: 'assets/chapter_images/food.png',
      themeColor: 0xFFFF5722,
      levels: [testLevel],
    );

    testWidgets(
      'Skip Level Booster deducts 50 coins and awards 0 coins (does NOT give 10 coins)',
      (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        await SoundManager.instance.init();
        await SoundManager.instance.setSoundEnabled(false);

        // User starts with 100 coins
        final initialProgress = await UserProgress.load();
        initialProgress.coins = 100;
        await initialProgress.save();

        await tester.pumpWidget(
          MaterialApp(
            home: GameplayScreen(chapter: testChapter, level: testLevel),
          ),
        );
        await tester.pumpAndSettle();

        // Verify initial coins displayed
        expect(find.text('100'), findsOneWidget);

        // Tap NEXT (Skip level booster)
        final nextButton = find.widgetWithText(ElevatedButton, 'NEXT');
        expect(nextButton, findsOneWidget);

        await tester.tap(nextButton);
        // Advance frames
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // 1. Dialog must show LEVEL SKIPPED and -50 COINS USED
        expect(find.text('LEVEL SKIPPED!'), findsOneWidget);
        expect(find.text('-50 COINS USED'), findsOneWidget);

        // 2. MUST NOT show +10 COINS EARNED
        expect(find.text('+10 COINS EARNED'), findsNothing);

        // 3. Coins must be exactly 50 (100 - 50 = 50, NOT 60!)
        final savedProgress = await UserProgress.load();
        expect(savedProgress.coins, equals(50));
      },
    );

    testWidgets(
      'Skip Level Booster shows not enough coins when user has less than 50 coins',
      (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        await SoundManager.instance.init();
        await SoundManager.instance.setSoundEnabled(false);

        // User starts with only 30 coins (< 50)
        final initialProgress = await UserProgress.load();
        initialProgress.coins = 30;
        await initialProgress.save();

        await tester.pumpWidget(
          MaterialApp(
            home: GameplayScreen(chapter: testChapter, level: testLevel),
          ),
        );
        await tester.pumpAndSettle();

        // Tap NEXT
        final nextButton = find.widgetWithText(ElevatedButton, 'NEXT');
        await tester.tap(nextButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Shows not enough coins message
        expect(find.text('Not Enough Coins!'), findsOneWidget);

        // Coins should remain untouched at 30
        final savedProgress = await UserProgress.load();
        expect(savedProgress.coins, equals(30));
      },
    );
  });
}
