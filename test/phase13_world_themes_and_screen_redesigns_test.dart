import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_search/models/chapter.dart';
import 'package:word_search/models/puzzle_level.dart';
import 'package:word_search/models/word_item.dart';
import 'package:word_search/screens/chapter_levels_screen.dart';
import 'package:word_search/screens/gameplay_screen.dart';
import 'package:word_search/screens/levels_map_screen.dart';
import 'package:word_search/screens/shop_screen.dart';
import 'package:word_search/theme/world_theme.dart';
import 'package:word_search/widgets/chapter_node_widget.dart';
import 'package:word_search/widgets/organic_wood_button.dart';
import 'package:word_search/widgets/parchment_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'user_coins': 500,
      'user_hints': 5,
      'completed_levels': ['1_1', '1_2'],
      'unlocked_chapters': [1, 2],
    });
  });

  group('WorldTheme Catalog Tests', () {
    test('World 1 (Food) theme has rich culinary attributes and props', () {
      final theme = WorldTheme.getTheme(1);
      expect(theme.worldId, 1);
      expect(theme.title, 'Food');
      expect(theme.ambientParticleType, 'crumbs');
      expect(theme.decorativeProps, contains('assets/game_art/worlds/w01_food/food_apple.png'));
      expect(theme.decorativeProps, contains('assets/game_art/worlds/w01_food/food_bread.png'));
      expect(theme.decorativeProps, contains('assets/game_art/worlds/w01_food/food_soup.png'));
      expect(theme.primaryColor, const Color(0xFFE65100));
    });

    test('All 30 Worlds return valid non-null themes with gradients and colors', () {
      for (int i = 1; i <= 30; i++) {
        final theme = WorldTheme.getTheme(i);
        expect(theme.worldId, i);
        expect(theme.title.isNotEmpty, isTrue);
        expect(theme.backgroundGradient.length, greaterThanOrEqualTo(2));
        expect(theme.primaryColor, isNotNull);
        expect(theme.boardBackgroundColor, isNotNull);
      }
    });

    test('Forest default theme is configured correctly', () {
      const forest = WorldTheme.forest;
      expect(forest.worldId, 0);
      expect(forest.title, 'Enchanted Forest');
      expect(forest.ambientParticleType, 'fireflies');
      expect(forest.decorativeProps, contains('assets/game_art/shared/forest/forest_bush.png'));
    });
  });

  group('LevelsMapScreen Widget Tests', () {
    testWidgets('Renders LevelsMapScreen with storybook header, road, and nodes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LevelsMapScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Header components
      expect(find.byType(ParchmentCard), findsWidgets);
      expect(find.textContaining('WORLD'), findsOneWidget);
      expect(find.text('Journey Map'), findsOneWidget);
      expect(find.text('Daily Challenge'), findsOneWidget);

      // Verify node widgets exist
      expect(find.byType(ChapterNodeWidget), findsWidgets);
    });
  });

  group('ChapterLevelsScreen Widget Tests', () {
    testWidgets('Renders ChapterLevelsScreen with World 1 Food Theme & 120 level tiles', (tester) async {
      final sampleChapter = Chapter(
        id: 1,
        key: 'food',
        title: 'Food',
        iconAsset: 'assets/chapter_images/food.png',
        themeColor: 0xFFFF5722,
        levels: List.generate(
          120,
          (i) => PuzzleLevel(
            levelNumber: i + 1,
            title: 'Level ${i + 1}',
            gridRows: 8,
            gridCols: 8,
            words: [
              WordItem(word: 'PIZZA', meaning: 'Italian dish'),
              WordItem(word: 'BREAD', meaning: 'Baked dough'),
            ],
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChapterLevelsScreen(chapter: sampleChapter),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Food'), findsWidgets);
      expect(find.textContaining('World 1: Food'), findsOneWidget);
      expect(find.text('1'), findsWidgets); // Level 1 tile
    });
  });

  group('GameplayScreen Widget Tests', () {
    testWidgets('Renders GameplayScreen with WorldTheme, grid, chips, and tactile booster buttons', (tester) async {
      final sampleChapter = Chapter(
        id: 1,
        key: 'food',
        title: 'Food',
        iconAsset: 'assets/chapter_images/food.png',
        themeColor: 0xFFFF5722,
        levels: [
          PuzzleLevel(
            levelNumber: 1,
            title: 'Level 1',
            gridRows: 6,
            gridCols: 6,
            words: [
              WordItem(word: 'APPLE', meaning: 'A crisp fruit'),
              WordItem(word: 'BREAD', meaning: 'Baked grain food'),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: GameplayScreen(
            chapter: sampleChapter,
            level: sampleChapter.levels.first,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Header info
      expect(find.textContaining('Food • Level 1'), findsOneWidget);
      expect(find.text('VOCABULARY'), findsOneWidget);
      expect(find.textContaining('HINT'), findsOneWidget);
      expect(find.text('NEXT'), findsOneWidget);

      // Wooden booster buttons
      expect(find.byType(OrganicWoodButton), findsWidgets);
    });
  });

  group('ShopScreen Widget Tests', () {
    testWidgets('Renders ShopScreen with Village Market, ParchmentCards, and wood buy buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ShopScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Coin Shop'), findsOneWidget);
      expect(find.text('COIN & HINT PACKS'), findsOneWidget);
      expect(find.text('REMOVE ALL ADS'), findsOneWidget);
      expect(find.text('Free Video Reward'), findsOneWidget);
      expect(find.byType(ParchmentCard), findsWidgets);
      expect(find.byType(OrganicWoodButton), findsWidgets);
    });
  });
}
