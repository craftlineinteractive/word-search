import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class UserProgress {
  static const String _storageKey = 'word_search_user_progress_v1';

  int coins;
  int hints;
  bool adsRemoved;
  int activeChapterId;
  int activeLevelIndex;
  final Set<String> completedLevels; // format: "chapterId_levelNumber" e.g. "1_1"
  final Set<int> unlockedChapters;
  final Map<String, List<String>> activeLevelWords; // format: "chapterId_levelNumber" -> ["WORD1", "WORD2"]

  // Daily Puzzle Progress Tracking
  final Set<String> completedDailyPuzzles; // format: "YYYY-MM-DD" e.g. "2026-09-02"
  final Map<String, List<String>> dailyPuzzleFoundWords; // format: "YYYY-MM-DD" -> ["WORD1", "WORD2"]

  UserProgress({
    this.coins = 50,
    this.hints = 3,
    this.adsRemoved = false,
    this.activeChapterId = 1,
    this.activeLevelIndex = 1,
    Set<String>? completedLevels,
    Set<int>? unlockedChapters,
    Map<String, List<String>>? activeLevelWords,
    Set<String>? completedDailyPuzzles,
    Map<String, List<String>>? dailyPuzzleFoundWords,
  }) : completedLevels = completedLevels ?? {},
       unlockedChapters = unlockedChapters ?? {1},
       activeLevelWords = activeLevelWords ?? {},
       completedDailyPuzzles = completedDailyPuzzles ?? {},
       dailyPuzzleFoundWords = dailyPuzzleFoundWords ?? {};

  static Future<UserProgress> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(jsonStr);
        return UserProgress.fromJson(data);
      }
    } catch (_) {}
    return UserProgress();
  }

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, json.encode(toJson()));
    } catch (_) {}
  }

  void addCoins(int amount) {
    coins += amount;
  }

  void completeLevel(int chapterId, int levelNumber) {
    completedLevels.add('${chapterId}_$levelNumber');
    // Note: Do NOT delete activeLevelWords so completed words remain visible upon re-entry
    unlockedChapters.add(chapterId);

    // Auto unlock next chapter if enough stars are accumulated
    final nextChapterId = chapterId + 1;
    if (getTotalStars() >= getRequiredStarsForChapter(nextChapterId)) {
      unlockedChapters.add(nextChapterId);
    }
  }

  bool isLevelCompleted(int chapterId, int levelNumber) {
    return completedLevels.contains('${chapterId}_$levelNumber');
  }

  void markLevelCompleted(int chapterId, int levelNumber) {
    completeLevel(chapterId, levelNumber);
  }

  int getTotalStars() {
    return completedLevels.length * 3;
  }

  int getStarsForChapter(int chapterId) {
    return getCompletedLevelsCount(chapterId) * 3;
  }

  int getRequiredStarsForChapter(int chapterId) {
    if (chapterId <= 1) return 0;
    return (chapterId - 1) * 25;
  }

  int getStarsNeededForChapter(int chapterId) {
    final required = getRequiredStarsForChapter(chapterId);
    return max(0, required - getTotalStars());
  }

  bool isChapterUnlocked(int chapterId) {
    if (chapterId <= 1) return true;
    if (unlockedChapters.contains(chapterId)) return true;
    return getTotalStars() >= getRequiredStarsForChapter(chapterId);
  }

  bool isLevelUnlocked(int chapterId, int levelNumber) {
    if (!isChapterUnlocked(chapterId)) return false;
    if (levelNumber <= 1) return true;
    return isLevelCompleted(chapterId, levelNumber) ||
        isLevelCompleted(chapterId, levelNumber - 1);
  }

  void unlockChapter(int chapterId) {
    unlockedChapters.add(chapterId);
  }

  int getCompletedLevelsCount(int chapterId) {
    return completedLevels
        .where((key) => key.startsWith('${chapterId}_'))
        .length;
  }

  // World-oriented aliases for smooth terminology transition
  int get activeWorldId => activeChapterId;
  set activeWorldId(int id) => activeChapterId = id;
  Set<int> get unlockedWorlds => unlockedChapters;
  int getStarsForWorld(int worldId) => getStarsForChapter(worldId);
  int getRequiredStarsForWorld(int worldId) => getRequiredStarsForChapter(worldId);
  int getStarsNeededForWorld(int worldId) => getStarsNeededForChapter(worldId);
  bool isWorldUnlocked(int worldId) => isChapterUnlocked(worldId);
  void unlockWorld(int worldId) => unlockChapter(worldId);

  List<String> getLevelFoundWords(int chapterId, int levelNumber) {
    return activeLevelWords['${chapterId}_$levelNumber'] ?? [];
  }

  void saveLevelFoundWords(int chapterId, int levelNumber, List<String> words) {
    activeLevelWords['${chapterId}_$levelNumber'] = words;
  }

  // ==================== DAILY PUZZLE METHODS ====================
  bool isDailyPuzzleCompleted(String dateKey) {
    return completedDailyPuzzles.contains(dateKey);
  }

  void completeDailyPuzzle(String dateKey) {
    completedDailyPuzzles.add(dateKey);
  }

  List<String> getDailyPuzzleFoundWords(String dateKey) {
    return dailyPuzzleFoundWords[dateKey] ?? [];
  }

  void saveDailyPuzzleFoundWords(String dateKey, List<String> words) {
    dailyPuzzleFoundWords[dateKey] = words;
  }

  Map<String, dynamic> toJson() {
    return {
      'coins': coins,
      'hints': hints,
      'adsRemoved': adsRemoved,
      'activeChapterId': activeChapterId,
      'activeLevelIndex': activeLevelIndex,
      'completedLevels': completedLevels.toList(),
      'unlockedChapters': unlockedChapters.toList(),
      'activeLevelWords': activeLevelWords,
      'completedDailyPuzzles': completedDailyPuzzles.toList(),
      'dailyPuzzleFoundWords': dailyPuzzleFoundWords,
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> wordsMap = {};
    if (json['activeLevelWords'] != null) {
      final rawMap = json['activeLevelWords'] as Map<String, dynamic>;
      rawMap.forEach((key, value) {
        if (value is List) {
          wordsMap[key] = value.map((e) => e.toString()).toList();
        }
      });
    }

    Map<String, List<String>> dailyWordsMap = {};
    if (json['dailyPuzzleFoundWords'] != null) {
      final rawMap = json['dailyPuzzleFoundWords'] as Map<String, dynamic>;
      rawMap.forEach((key, value) {
        if (value is List) {
          dailyWordsMap[key] = value.map((e) => e.toString()).toList();
        }
      });
    }

    return UserProgress(
      coins: json['coins'] as int? ?? 50,
      hints: json['hints'] as int? ?? 3,
      adsRemoved: json['adsRemoved'] as bool? ?? false,
      activeChapterId: json['activeChapterId'] as int? ?? 1,
      activeLevelIndex: json['activeLevelIndex'] as int? ?? 1,
      completedLevels: ((json['completedLevels'] as List<dynamic>?) ?? [])
          .map((e) => e.toString())
          .toSet(),
      unlockedChapters: ((json['unlockedChapters'] as List<dynamic>?) ?? [])
          .map((e) => (e as num).toInt())
          .toSet(),
      activeLevelWords: wordsMap,
      completedDailyPuzzles: ((json['completedDailyPuzzles'] as List<dynamic>?) ?? [])
          .map((e) => e.toString())
          .toSet(),
      dailyPuzzleFoundWords: dailyWordsMap,
    );
  }
}
