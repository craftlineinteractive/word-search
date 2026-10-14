import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_search/models/user_progress.dart';
import 'package:word_search/services/daily_puzzle_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 10 - Daily Unique Puzzle & Permanent Word State QA', () {
    test('DailyPuzzleService generates deterministic words and grid for any date', () async {
      final date1 = DateTime(2026, 9, 2);
      final level1 = await DailyPuzzleService.getDailyPuzzle(date1);

      expect(level1.words.length, greaterThanOrEqualTo(6));
      expect(level1.gridRows, equals(10));
      expect(level1.gridCols, equals(10));

      final date2 = DateTime(2026, 9, 3);
      final level2 = await DailyPuzzleService.getDailyPuzzle(date2);
      expect(level2.words.isNotEmpty, isTrue);

      // Same date must generate identical words
      final level1Repeat = await DailyPuzzleService.getDailyPuzzle(date1);
      expect(level1.words.map((w) => w.word).toList(), equals(level1Repeat.words.map((w) => w.word).toList()));
    });

    test('UserProgress retains completed levels and active found words permanently', () async {
      final progress = await UserProgress.load();

      // Find words in Level 1
      progress.saveLevelFoundWords(1, 1, ['APPLE', 'BANANA', 'CHERRY']);
      progress.completeLevel(1, 1);
      await progress.save();

      // Reload from storage
      final reloaded = await UserProgress.load();
      expect(reloaded.isLevelCompleted(1, 1), isTrue);
      expect(reloaded.getLevelFoundWords(1, 1), equals(['APPLE', 'BANANA', 'CHERRY']));
    });

    test('Daily Puzzle completion persists dateKey and found words', () async {
      final progress = await UserProgress.load();
      const todayKey = '2026-09-02';

      expect(progress.isDailyPuzzleCompleted(todayKey), isFalse);

      progress.saveDailyPuzzleFoundWords(todayKey, ['SOLVED1', 'SOLVED2']);
      progress.completeDailyPuzzle(todayKey);
      progress.addCoins(50);
      await progress.save();

      final reloaded = await UserProgress.load();
      expect(reloaded.isDailyPuzzleCompleted(todayKey), isTrue);
      expect(reloaded.getDailyPuzzleFoundWords(todayKey), equals(['SOLVED1', 'SOLVED2']));
      expect(reloaded.coins, equals(50 + 50));
    });
  });
}
