import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_search/models/grid_coordinate.dart';
import 'package:word_search/models/word_item.dart';
import 'package:word_search/models/placed_word.dart';
import 'package:word_search/models/chapter.dart';
import 'package:word_search/models/user_progress.dart';
import 'package:word_search/engine/word_grid_engine.dart';

void main() {
  group('Phase 1 - Data Models Tests', () {
    test('GridCoordinate equality and JSON roundtrip', () {
      const coord1 = GridCoordinate(2, 5);
      const coord2 = GridCoordinate(2, 5);
      const coord3 = GridCoordinate(3, 5);

      expect(coord1, equals(coord2));
      expect(coord1.hashCode, equals(coord2.hashCode));
      expect(coord1 == coord3, isFalse);

      final json = coord1.toJson();
      final restored = GridCoordinate.fromJson(json);
      expect(restored, equals(coord1));
    });

    test('WordItem normalization and JSON serialization', () {
      final item = WordItem(
        word: '  pizza  ',
        meaning: 'Savory Italian dish',
        example: 'Tasty pizza slice',
      );

      expect(item.normalizedWord, equals('PIZZA'));
      final json = item.toJson();
      final restored = WordItem.fromJson(json);
      expect(restored.word, equals('PIZZA'));
      expect(restored.meaning, equals('Savory Italian dish'));
    });

    test('PlacedWord coordinates and start/end helpers', () {
      final placed = PlacedWord(
        word: 'FOOD',
        coordinates: const [
          GridCoordinate(0, 0),
          GridCoordinate(0, 1),
          GridCoordinate(0, 2),
          GridCoordinate(0, 3),
        ],
        colorValue: 0xFFFF0000,
      );

      expect(placed.start, equals(const GridCoordinate(0, 0)));
      expect(placed.end, equals(const GridCoordinate(0, 3)));
      expect(placed.coordinates.length, equals(4));

      final json = placed.toJson();
      final restored = PlacedWord.fromJson(json);
      expect(restored.word, equals('FOOD'));
      expect(restored.coordinates.length, equals(4));
    });

    test('UserProgress unlocks and level completion tracking', () {
      final progress = UserProgress(coins: 300, hints: 5);
      expect(progress.isChapterUnlocked(1), isTrue);
      expect(progress.isChapterUnlocked(2), isFalse);

      progress.unlockChapter(2);
      expect(progress.isChapterUnlocked(2), isTrue);

      expect(progress.isLevelCompleted(1, 1), isFalse);
      progress.markLevelCompleted(1, 1);
      expect(progress.isLevelCompleted(1, 1), isTrue);
      expect(progress.getCompletedLevelsCount(1), equals(1));

      final json = progress.toJson();
      final restored = UserProgress.fromJson(json);
      expect(restored.coins, equals(300));
      expect(restored.isChapterUnlocked(2), isTrue);
      expect(restored.isLevelCompleted(1, 1), isTrue);
    });
  });

  group('Phase 1 - WordGridEngine Placement & Math Tests', () {
    test('Generate grid places all target words within boundaries', () {
      final words = ['PIZZA', 'APPLE', 'BREAD', 'CHEESE'];
      final result = WordGridEngine.generateGrid(
        rows: 8,
        cols: 8,
        words: words,
      );

      expect(result.grid.length, equals(8));
      expect(result.grid[0].length, equals(8));
      expect(result.placedWords.length, equals(words.length));
      expect(result.unplacedWords, isEmpty);

      // Verify that every coordinate on the grid is within 0..7
      for (var placed in result.placedWords) {
        for (var coord in placed.coordinates) {
          expect(coord.row, inInclusiveRange(0, 7));
          expect(coord.col, inInclusiveRange(0, 7));
          // Verify letter at grid position matches the word character
          int charIndex = placed.coordinates.indexOf(coord);
          expect(
            result.grid[coord.row][coord.col],
            equals(placed.word[charIndex]),
          );
        }
      }
    });

    test(
      'Grid line coordinate calculation for horizontal, vertical, diagonal',
      () {
        // Horizontal forward
        final hLine = WordGridEngine.getLineCoordinates(
          const GridCoordinate(2, 1),
          const GridCoordinate(2, 4),
        );
        expect(hLine, isNotNull);
        expect(hLine!.length, equals(4));
        expect(
          hLine,
          equals([
            const GridCoordinate(2, 1),
            const GridCoordinate(2, 2),
            const GridCoordinate(2, 3),
            const GridCoordinate(2, 4),
          ]),
        );

        // Vertical downward
        final vLine = WordGridEngine.getLineCoordinates(
          const GridCoordinate(1, 3),
          const GridCoordinate(4, 3),
        );
        expect(vLine, isNotNull);
        expect(vLine!.length, equals(4));
        expect(
          vLine,
          equals([
            const GridCoordinate(1, 3),
            const GridCoordinate(2, 3),
            const GridCoordinate(3, 3),
            const GridCoordinate(4, 3),
          ]),
        );

        // Diagonal down-right
        final dLine = WordGridEngine.getLineCoordinates(
          const GridCoordinate(1, 1),
          const GridCoordinate(3, 3),
        );
        expect(dLine, isNotNull);
        expect(dLine!.length, equals(3));
        expect(
          dLine,
          equals([
            const GridCoordinate(1, 1),
            const GridCoordinate(2, 2),
            const GridCoordinate(3, 3),
          ]),
        );

        // Non-aligned knight move / irregular slope should return null
        final invalidLine = WordGridEngine.getLineCoordinates(
          const GridCoordinate(0, 0),
          const GridCoordinate(1, 2),
        );
        expect(invalidLine, isNull);
      },
    );

    test('getStringForCoordinates extracts exact sequence', () {
      final testGrid = [
        ['C', 'A', 'T', 'S'],
        ['D', 'O', 'G', 'S'],
        ['F', 'I', 'S', 'H'],
        ['B', 'I', 'R', 'D'],
      ];

      final word1 = WordGridEngine.getStringForCoordinates(testGrid, [
        const GridCoordinate(0, 0),
        const GridCoordinate(0, 1),
        const GridCoordinate(0, 2),
      ]);
      expect(word1, equals('CAT'));

      final word2 = WordGridEngine.getStringForCoordinates(testGrid, [
        const GridCoordinate(2, 0),
        const GridCoordinate(2, 1),
        const GridCoordinate(2, 2),
        const GridCoordinate(2, 3),
      ]);
      expect(word2, equals('FISH'));
    });
  });

  group('Phase 1 - World/Chapter JSON Files Integrity QA', () {
    test('world_01_food.json is valid and contains word meanings', () {
      final file = File('assets/data/world_01_food.json');
      expect(file.existsSync(), isTrue);

      final jsonStr = file.readAsStringSync();
      final Map<String, dynamic> data = json.decode(jsonStr);
      final chapter = Chapter.fromJson(data);

      expect(chapter.id, equals(1));
      expect(chapter.key, equals('food'));
      expect(chapter.title, equals('Food'));
      expect(chapter.levels.isNotEmpty, isTrue);

      for (var level in chapter.levels) {
        expect(level.words.isNotEmpty, isTrue);
        for (var word in level.words) {
          expect(word.word.isNotEmpty, isTrue);
          expect(word.meaning.isNotEmpty, isTrue);
        }
      }
    });

    test('world_02_holiday.json is valid and contains word meanings', () {
      final file = File('assets/data/world_02_holiday.json');
      expect(file.existsSync(), isTrue);

      final jsonStr = file.readAsStringSync();
      final Map<String, dynamic> data = json.decode(jsonStr);
      final chapter = Chapter.fromJson(data);

      expect(chapter.id, equals(2));
      expect(chapter.key, equals('holiday'));
      expect(chapter.title, equals('Holiday'));
      expect(chapter.levels.isNotEmpty, isTrue);

      for (var level in chapter.levels) {
        expect(level.words.isNotEmpty, isTrue);
        for (var word in level.words) {
          expect(word.word.isNotEmpty, isTrue);
          expect(word.meaning.isNotEmpty, isTrue);
        }
      }
    });
  });
}
