import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_search/engine/word_grid_engine.dart';
import 'package:word_search/models/user_progress.dart';
import 'package:word_search/screens/home_screen.dart';
import 'package:word_search/screens/levels_map_screen.dart';
import 'package:word_search/services/sound_manager.dart';
import 'package:word_search/services/theme_manager.dart';
import 'package:word_search/theme/app_theme.dart';
import 'package:word_search/widgets/chapter_node_widget.dart';
import 'package:word_search/widgets/game_3d_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers.global'),
          (MethodCall methodCall) async {
            return 1;
          },
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers'),
          (MethodCall methodCall) async {
            return 1;
          },
        );
  });

  group('Phase 7 - Deterministic Grids, Progress Persistence & 3D Themes QA', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SoundManager.instance.init();
      await ThemeManager.instance.init();
    });

    test(
      'Deterministic grid generation produces identical grid matrix for same chapter and level seed',
      () {
        final words = ['APPLE', 'BANANA', 'CHERRY', 'DATE'];
        const rows = 10;
        const cols = 10;
        final seed = 1 * 100000 + 5 * 7919;

        final res1 = WordGridEngine.generateGrid(
          rows: rows,
          cols: cols,
          words: words,
          random: Random(seed),
        );

        final res2 = WordGridEngine.generateGrid(
          rows: rows,
          cols: cols,
          words: words,
          random: Random(seed),
        );

        expect(res1.grid, equals(res2.grid));
        expect(res1.placedWords.length, equals(res2.placedWords.length));
        for (int i = 0; i < res1.placedWords.length; i++) {
          expect(res1.placedWords[i].word, equals(res2.placedWords[i].word));
          expect(
            res1.placedWords[i].coordinates.length,
            equals(res2.placedWords[i].coordinates.length),
          );
        }
      },
    );

    test('UserProgress saves and restores found words per level', () async {
      final progress = await UserProgress.load();
      expect(progress.getLevelFoundWords(1, 3), isEmpty);

      progress.saveLevelFoundWords(1, 3, ['APPLE', 'BANANA']);
      await progress.save();

      final reloaded = await UserProgress.load();
      expect(reloaded.getLevelFoundWords(1, 3), equals(['APPLE', 'BANANA']));

      // Level completion preserves found words permanently
      reloaded.completeLevel(1, 3);
      await reloaded.save();

      final finalCheck = await UserProgress.load();
      expect(finalCheck.getLevelFoundWords(1, 3), equals(['APPLE', 'BANANA']));
      expect(finalCheck.isLevelCompleted(1, 3), isTrue);
    });

    testWidgets(
      'Game3dButton renders with depth and responds to tap callbacks',
      (WidgetTester tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Game3dButton(
                  color: Game3dButtonColor.green,
                  text: 'START GAME',
                  onPressed: () => tapped = true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('START GAME'), findsOneWidget);
        await tester.tap(find.text('START GAME'));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      },
    );

    testWidgets('HomeScreen renders in Light Mode without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: const HomeScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('WORD SEARCH'), findsWidgets);
      expect(find.text('WORLD MAP'), findsOneWidget);
      expect(find.text('ACHIEVEMENTS'), findsOneWidget);
    });

    testWidgets('LevelsMapScreen renders in Light Mode without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: const LevelsMapScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('SUMMIT MASTER'), findsOneWidget);
      expect(find.byType(ChapterNodeWidget), findsWidgets);
    });

    test(
      'Star gating logic unlocks chapters proportionally to total stars earned',
      () async {
        final progress = UserProgress(
          coins: 300,
          hints: 5,
          activeChapterId: 1,
          unlockedChapters: {1},
        );

        // Chapter 1 is always unlocked
        expect(progress.isChapterUnlocked(1), isTrue);
        // Chapter 2 requires 30 stars (10 completed levels at 3 stars)
        expect(progress.getRequiredStarsForChapter(2), equals(30));
        expect(progress.isChapterUnlocked(2), isFalse);
        expect(progress.getStarsNeededForChapter(2), equals(30));

        // Complete 10 levels in Chapter 1 -> 30 stars
        for (int i = 1; i <= 10; i++) {
          progress.completeLevel(1, i);
        }

        expect(progress.getTotalStars(), equals(30));
        expect(progress.isChapterUnlocked(2), isTrue);
        expect(progress.getStarsNeededForChapter(2), equals(0));
      },
    );
  });
}
