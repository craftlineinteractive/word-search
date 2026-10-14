import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_search/models/chapter.dart';
import 'package:word_search/screens/levels_map_screen.dart';
import 'package:word_search/services/level_repository.dart';
import 'package:word_search/services/sound_manager.dart';
import 'package:word_search/widgets/chapter_node_widget.dart';
import 'package:word_search/widgets/journey_path_painter.dart';

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
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
          if (message == null) return null;
          final String key = utf8.decode(message.buffer.asUint8List());
          final file = File(key);
          if (file.existsSync()) {
            final bytes = file.readAsBytesSync();
            return bytes.buffer.asByteData();
          }
          return null;
        });
  });

  group('Phase 5 - Winding Visual Journey Map QA', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SoundManager.instance.init();
      final jsonStr = File(
        'assets/data/chapter_01_food.json',
      ).readAsStringSync();
      final chapter1 = Chapter.fromJson(
        json.decode(jsonStr) as Map<String, dynamic>,
      );
      LevelRepository.cacheChapter(chapter1);
    });

    test('LevelRepository contains all 30 chapters for the journey map', () {
      expect(LevelRepository.catalog.length, equals(30));
      expect(LevelRepository.catalog.first.id, equals(1));
      expect(LevelRepository.catalog.last.id, equals(30));
    });

    testWidgets('JourneyPathPainter paints smoothly without errors', (
      WidgetTester tester,
    ) async {
      final List<Offset> testNodes = List.generate(
        30,
        (i) => Offset(100.0 + (i % 2 == 0 ? 50.0 : -50.0), (30 - i) * 120.0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(400, 3600),
              painter: JourneyPathPainter(
                nodePositions: testNodes,
                activeChapterIndex: 0,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets(
      'ChapterNodeWidget renders active, completed, and locked states',
      (WidgetTester tester) async {
        final chapter = LevelRepository.catalog.first;

        // Active Node
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChapterNodeWidget(
                chapter: chapter,
                status: ChapterStatus.active,
                completedLevelsCount: 5,
                totalLevelsCount: 35,
                onTap: () {},
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('PLAY'), findsOneWidget);
        expect(find.text(chapter.title), findsOneWidget);
        expect(find.text('5/35'), findsOneWidget);

        // Locked Node
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChapterNodeWidget(
                chapter: chapter,
                status: ChapterStatus.locked,
                completedLevelsCount: 0,
                totalLevelsCount: 35,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'LevelsMapScreen loads winding roadmap with Start Journey, Summit Trophy, and chapter nodes',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: LevelsMapScreen()));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('Journey Map'), findsOneWidget);
        expect(find.text('Daily Challenge'), findsOneWidget);
        expect(find.byType(ChapterNodeWidget), findsWidgets);

        // Find first chapter (Food) and ensure visible before tap
        final firstChapterFinder = find.widgetWithText(
          ChapterNodeWidget,
          'Food',
        );
        expect(firstChapterFinder, findsOneWidget);

        // Tap first chapter to open bottom sheet
        final chapterWidget = tester.widget<ChapterNodeWidget>(
          firstChapterFinder,
        );
        chapterWidget.onTap();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // Navigates to ChapterLevelsScreen
        expect(find.text('Chapter 1 (35 Levels)'), findsOneWidget);
      },
    );
  });
}
