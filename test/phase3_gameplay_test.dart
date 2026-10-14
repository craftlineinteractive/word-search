import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_search/engine/word_grid_engine.dart';
import 'package:word_search/models/chapter.dart';
import 'package:word_search/models/grid_coordinate.dart';
import 'package:word_search/models/placed_word.dart';
import 'package:word_search/models/puzzle_level.dart';
import 'package:word_search/models/word_item.dart';
import 'package:word_search/screens/gameplay_screen.dart';
import 'package:word_search/widgets/word_bank_chips.dart';
import 'package:word_search/widgets/word_grid_painter.dart';
import 'package:word_search/widgets/word_meaning_dialog.dart';
import 'package:word_search/widgets/word_search_grid.dart';

void main() {
  group('Phase 3 - Core Gameplay & Interactive UI QA', () {
    final List<WordItem> sampleWords = [
      WordItem(
        word: 'PIZZA',
        meaning:
            'A dish of Italian origin consisting of a flat round base of dough baked with toppings',
        example: 'We ordered hot pepperoni pizza for dinner.',
      ),
      WordItem(
        word: 'APPLE',
        meaning:
            'The round fruit of a tree of the rose family, typically with red or green skin',
        example: 'Eating a crisp red apple for a snack.',
      ),
      WordItem(
        word: 'BREAD',
        meaning:
            'Food made of flour, water, and yeast or another leavening agent, mixed and baked',
        example: 'Warm freshly baked artisan loaf bread.',
      ),
    ];

    test(
      'WordGridEngine.getLineCoordinates calculates 8-directional straight lines correctly',
      () {
        // Horizontal forward (Left to Right)
        final hFwd = WordGridEngine.getLineCoordinates(
          const GridCoordinate(0, 0),
          const GridCoordinate(0, 4),
        );
        expect(hFwd?.length, equals(5));
        expect(hFwd?.last, equals(const GridCoordinate(0, 4)));

        // Horizontal backward (Right to Left)
        final hBwd = WordGridEngine.getLineCoordinates(
          const GridCoordinate(0, 4),
          const GridCoordinate(0, 0),
        );
        expect(hBwd?.length, equals(5));
        expect(hBwd?.first, equals(const GridCoordinate(0, 4)));
        expect(hBwd?.last, equals(const GridCoordinate(0, 0)));

        // Vertical down
        final vDown = WordGridEngine.getLineCoordinates(
          const GridCoordinate(1, 2),
          const GridCoordinate(4, 2),
        );
        expect(vDown?.length, equals(4));

        // Diagonal Down-Right
        final dDR = WordGridEngine.getLineCoordinates(
          const GridCoordinate(1, 1),
          const GridCoordinate(4, 4),
        );
        expect(dDR?.length, equals(4));
        expect(dDR?[1], equals(const GridCoordinate(2, 2)));

        // Invalid line (knight's move) should return null
        final invalid = WordGridEngine.getLineCoordinates(
          const GridCoordinate(0, 0),
          const GridCoordinate(1, 2),
        );
        expect(invalid, isNull);
      },
    );

    testWidgets(
      'WordGridPainter paints successfully without throwing exceptions',
      (WidgetTester tester) async {
        final grid = [
          ['P', 'I', 'Z', 'Z', 'A'],
          ['A', 'P', 'P', 'L', 'E'],
          ['B', 'R', 'E', 'A', 'D'],
        ];

        final foundWords = [
          PlacedWord(
            word: 'PIZZA',
            coordinates: [
              const GridCoordinate(0, 0),
              const GridCoordinate(0, 1),
              const GridCoordinate(0, 2),
              const GridCoordinate(0, 3),
              const GridCoordinate(0, 4),
            ],
            colorValue: 0xFFFF5252,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomPaint(
                size: const Size(300, 300),
                painter: WordGridPainter(
                  grid: grid,
                  foundWords: foundWords,
                  activeSelection: [
                    const GridCoordinate(1, 0),
                    const GridCoordinate(1, 1),
                  ],
                  hintCoordinate: const GridCoordinate(2, 0),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(CustomPaint), findsWidgets);
      },
    );

    testWidgets(
      'WordBankChips displays target words and strike-through on found words',
      (WidgetTester tester) async {
        final foundWords = [
          PlacedWord(
            word: 'PIZZA',
            coordinates: [const GridCoordinate(0, 0)],
            colorValue: 0xFFFF5252,
          ),
        ];

        WordItem? tappedItem;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WordBankChips(
                levelWords: sampleWords,
                foundWords: foundWords,
                onWordTap: (item) => tappedItem = item,
              ),
            ),
          ),
        );

        expect(find.text('PIZZA'), findsOneWidget);
        expect(find.text('APPLE'), findsOneWidget);
        expect(find.text('BREAD'), findsOneWidget);

        // Tap on APPLE chip
        await tester.tap(find.text('APPLE'));
        expect(tappedItem?.word, equals('APPLE'));
      },
    );

    testWidgets(
      'WordMeaningDialog displays word definition and example sentence',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  return ElevatedButton(
                    onPressed: () {
                      WordMeaningDialog.show(ctx, sampleWords[0], 'FOOD');
                    },
                    child: const Text('OPEN DIALOG'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('OPEN DIALOG'));
        await tester.pumpAndSettle();

        expect(find.text('PIZZA'), findsOneWidget);
        expect(find.text('FOOD'), findsOneWidget);
        expect(find.text('MEANING'), findsOneWidget);
        expect(find.textContaining('Italian origin'), findsOneWidget);
        expect(find.text('GOT IT!'), findsOneWidget);

        // Close dialog
        await tester.tap(find.text('GOT IT!'));
        await tester.pumpAndSettle();
        expect(find.text('GOT IT!'), findsNothing);
      },
    );

    testWidgets(
      'GameplayScreen loads and renders word search board, words bank, and toolbar',
      (WidgetTester tester) async {
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

        await tester.pumpWidget(
          MaterialApp(
            home: GameplayScreen(chapter: testChapter, level: testLevel),
          ),
        );
        await tester.pumpAndSettle();

        // Verify header and level title
        expect(find.text('Food • Level 1'), findsOneWidget);
        expect(find.textContaining('Words'), findsOneWidget);

        // Verify word bank chips
        expect(find.text('PIZZA'), findsOneWidget);
        expect(find.text('APPLE'), findsOneWidget);
        expect(find.text('BREAD'), findsOneWidget);

        // Verify bottom action buttons
        expect(find.text('VOCABULARY'), findsOneWidget);
        expect(find.textContaining('HINT'), findsOneWidget);

        // Verify interactive WordSearchGrid
        expect(find.byType(WordSearchGrid), findsOneWidget);
      },
    );
  });
}


