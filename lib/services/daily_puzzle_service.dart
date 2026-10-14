import 'dart:math';
import '../models/chapter.dart';
import '../models/puzzle_level.dart';
import '../models/word_item.dart';
import 'level_repository.dart';

class DailyPuzzleService {
  static String getTodayKey([DateTime? date]) {
    final d = date ?? DateTime.now();
    final year = d.year.toString().padLeft(4, '0');
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String getFormattedDate([DateTime? date]) {
    final d = date ?? DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  /// Generates a deterministic, unique handcrafted daily puzzle for any given calendar day
  static Future<PuzzleLevel> getDailyPuzzle([DateTime? date]) async {
    final d = date ?? DateTime.now();
    final int dateSeed = d.year * 10000 + d.month * 100 + d.day;
    final random = Random(dateSeed);

    // Pick 2-3 distinct chapters from the catalog to curate diverse daily words
    final catalog = LevelRepository.catalog;
    final selectedChapterIndices = <int>{};
    while (selectedChapterIndices.length < 3 && selectedChapterIndices.length < catalog.length) {
      selectedChapterIndices.add(random.nextInt(catalog.length));
    }

    final List<WordItem> pool = [];
    for (var idx in selectedChapterIndices) {
      try {
        final chapter = await LevelRepository.loadChapter(catalog[idx].jsonFile);
        for (var lvl in chapter.levels) {
          pool.addAll(lvl.words);
        }
      } catch (_) {}
    }

    // Shuffle pool with deterministic seed and pick 7 unique words
    pool.shuffle(random);
    final Set<String> seenWords = {};
    final List<WordItem> dailyWords = [];

    for (var item in pool) {
      final clean = item.word.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
      if (clean.length >= 3 && clean.length <= 8 && !seenWords.contains(clean)) {
        seenWords.add(clean);
        dailyWords.add(item);
        if (dailyWords.length >= 7) break;
      }
    }

    // Fallback if pool is empty
    if (dailyWords.isEmpty) {
      dailyWords.addAll([
        WordItem(word: 'BRILLIANT', meaning: 'Exceptionally clever, talented, or impressive.'),
        WordItem(word: 'DISCOVER', meaning: 'Find unexpectedly or in the course of a search.'),
        WordItem(word: 'CHALLENGE', meaning: 'A task or situation that tests someone\'s abilities.'),
        WordItem(word: 'VICTORY', meaning: 'An act of defeating an opponent or overcoming difficulty.'),
        WordItem(word: 'INSPIRE', meaning: 'Fill someone with the urge or ability to do something creative.'),
        WordItem(word: 'JOURNEY', meaning: 'An act of traveling from one place to another.'),
      ]);
    }

    return PuzzleLevel(
      levelNumber: d.day,
      title: 'Daily Challenge',
      gridRows: 10,
      gridCols: 10,
      words: dailyWords,
      difficulty: 'Daily',
    );
  }

  static Chapter getDailyChapter([DateTime? date]) {
    final formatted = getFormattedDate(date);
    return Chapter(
      id: 9999,
      key: 'daily_puzzle',
      title: 'Daily - $formatted',
      iconAsset: 'assets/chapter_images/words.png',
      themeColor: 0xFF673AB7,
      levels: [],
    );
  }
}
