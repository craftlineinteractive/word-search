// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_search/models/chapter.dart';
import 'package:word_search/services/level_repository.dart';
import 'package:word_search/engine/word_grid_engine.dart';

void main() {
  group('Phase 2 - 30 Chapters & 1000+ Levels Dataset QA', () {
    test(
      'All 30 chapters exist in catalog and correspond to JSON files on disk',
      () {
        expect(LevelRepository.catalog.length, equals(30));

        for (var meta in LevelRepository.catalog) {
          final jsonFile = File('assets/data/${meta.jsonFile}');
          expect(
            jsonFile.existsSync(),
            isTrue,
            reason: 'File ${meta.jsonFile} must exist',
          );

          final imgFile = File(meta.iconAsset);
          expect(
            imgFile.existsSync(),
            isTrue,
            reason: 'Asset image ${meta.iconAsset} must exist',
          );
        }
      },
    );

    test(
      'Total level count exceeds 1000 across all 30 chapters with 9x9/11x11/13x13/14x14 scaling',
      () {
        int totalLevelsCount = 0;

        for (var meta in LevelRepository.catalog) {
          final file = File('assets/data/${meta.jsonFile}');
          final data = json.decode(file.readAsStringSync());
          final chapter = Chapter.fromJson(data);

          expect(chapter.id, equals(meta.id));
          expect(chapter.title, equals(meta.title));
          expect(chapter.levels.isNotEmpty, isTrue);

          totalLevelsCount += chapter.levels.length;

          for (var level in chapter.levels) {
            // Verify progressive grid scaling: 9x9 (1-9), 11x11 (10-17), 13x13 (18-24), 14x14 (25-35)
            if (level.levelNumber >= 25) {
              expect(level.gridRows, greaterThanOrEqualTo(14));
              expect(level.gridCols, greaterThanOrEqualTo(14));
              expect(level.words.length, greaterThanOrEqualTo(11));
            } else if (level.levelNumber >= 18) {
              expect(level.gridRows, greaterThanOrEqualTo(13));
              expect(level.gridCols, greaterThanOrEqualTo(13));
              expect(level.words.length, greaterThanOrEqualTo(10));
            } else if (level.levelNumber >= 10) {
              expect(level.gridRows, greaterThanOrEqualTo(11));
              expect(level.gridCols, greaterThanOrEqualTo(11));
              expect(level.words.length, greaterThanOrEqualTo(8));
            } else {
              expect(level.gridRows, greaterThanOrEqualTo(9));
              expect(level.gridCols, greaterThanOrEqualTo(9));
              expect(level.words.length, inInclusiveRange(6, 9));
            }

            // Verify that the grid accommodates any word
            for (var w in level.words) {
              final maxDim = level.gridRows > level.gridCols ? level.gridRows : level.gridCols;
              expect(maxDim, greaterThanOrEqualTo(w.word.length));
            }

            // Verify words and educational meanings
            for (var w in level.words) {
              expect(w.word.isNotEmpty, isTrue);
              expect(w.word, equals(w.word.toUpperCase()));
              expect(w.meaning.isNotEmpty, isTrue);
            }
          }
        }

        print(
          'Verified $totalLevelsCount total levels across 30 chapters (Target: 1000+ Levels).',
        );
        expect(totalLevelsCount, greaterThanOrEqualTo(1000));
      },
    );

    test(
      'WordGridEngine successfully generates 9x9, 11x11, 13x13, and 14x14 grids in all 8 directions with 0 unplaced words',
      () {
        // Test early level on 9x9 grid with 8 words
        final res9x9 = WordGridEngine.generateGrid(
          rows: 9,
          cols: 9,
          words: [
            'PIZZA',
            'APPLE',
            'BREAD',
            'CHEESE',
            'BURGER',
            'SALAD',
            'PASTA',
            'STEAK',
          ],
          allowBackwards: true,
          allowDiagonals: true,
        );
        expect(res9x9.unplacedWords, isEmpty);
        expect(res9x9.placedWords.length, equals(8));

        // Test middle level on 11x11 grid with 9 words
        final res11x11 = WordGridEngine.generateGrid(
          rows: 11,
          cols: 11,
          words: [
            'DOCTOR',
            'TEACHER',
            'DRIVER',
            'CHEF',
            'PILOT',
            'NURSE',
            'ARTIST',
            'LAWYER',
            'POLICE',
          ],
          allowBackwards: true,
          allowDiagonals: true,
        );
        expect(res11x11.unplacedWords, isEmpty);
        expect(res11x11.placedWords.length, equals(9));

        // Test late level on 13x13 grid with 11 words
        final res13x13 = WordGridEngine.generateGrid(
          rows: 13,
          cols: 13,
          words: [
            'COMPUTER',
            'INTERNET',
            'SOFTWARE',
            'ALGORITHM',
            'DATABASE',
            'NETWORK',
            'SECURITY',
            'QUANTUM',
            'ENCRYPT',
            'FIREWALL',
            'PROTOCOL',
          ],
          allowBackwards: true,
          allowDiagonals: true,
        );
        expect(res13x13.unplacedWords, isEmpty);
        expect(res13x13.placedWords.length, equals(11));

        // Test expert level on 14x14 grid with 13 long words
        final res14x14 = WordGridEngine.generateGrid(
          rows: 14,
          cols: 14,
          words: [
            'CYBERSECURITY',
            'SUPERCOMPUTER',
            'MICROPROCESSOR',
            'TELECOM',
            'VIRTUALIZATION',
            'INFRASTRUCTURE',
            'AUTHENTICATION',
            'PROGRAMMABLE',
            'SEMICONDUCTOR',
            'NANOTECH',
            'TRANSCEIVER',
            'ARCHITECTURE',
            'DECENTRALIZED',
          ],
          allowBackwards: true,
          allowDiagonals: true,
        );
        expect(res14x14.unplacedWords, isEmpty);
        expect(res14x14.placedWords.length, equals(13));
      },
    );
  });
}
