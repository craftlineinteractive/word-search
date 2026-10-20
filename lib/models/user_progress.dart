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

  // Achievements Progress Tracking: achievementId -> highestClaimedTierNumber (1, 2, or 3)
  final Map<String, int> claimedAchievementTiers;

  // Level Stars Tracking: "chapterId_levelNumber" -> stars earned (1, 2, or 3)
  final Map<String, int> levelStars;

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
    Map<String, int>? claimedAchievementTiers,
    Map<String, int>? levelStars,
  }) : completedLevels = completedLevels ?? {},
       unlockedChapters = unlockedChapters ?? {1},
       activeLevelWords = activeLevelWords ?? {},
       completedDailyPuzzles = completedDailyPuzzles ?? {},
       dailyPuzzleFoundWords = dailyPuzzleFoundWords ?? {},
       claimedAchievementTiers = claimedAchievementTiers ?? {},
       levelStars = levelStars ?? {};

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

  void completeLevel(int chapterId, int levelNumber, {int stars = 3}) {
    final key = '${chapterId}_$levelNumber';
    completedLevels.add(key);
    final existingStars = levelStars[key] ?? 0;
    levelStars[key] = max(existingStars, stars.clamp(1, 3));
    // Note: Do NOT delete activeLevelWords so completed words remain visible upon re-entry
    unlockedChapters.add(chapterId);

    // Auto unlock next chapter if enough stars are accumulated
    final nextChapterId = chapterId + 1;
    if (getTotalStars() >= getRequiredStarsForChapter(nextChapterId)) {
      unlockedChapters.add(nextChapterId);
    }
  }

  int getLevelStars(int chapterId, int levelNumber) {
    final key = '${chapterId}_$levelNumber';
    if (!completedLevels.contains(key)) return 0;
    return levelStars[key] ?? 3;
  }

  bool isLevelCompleted(int chapterId, int levelNumber) {
    return completedLevels.contains('${chapterId}_$levelNumber');
  }

  void markLevelCompleted(int chapterId, int levelNumber, {int stars = 3}) {
    completeLevel(chapterId, levelNumber, stars: stars);
  }

  int getTotalStars() {
    int total = 0;
    for (final key in completedLevels) {
      total += levelStars[key] ?? 3;
    }
    return total;
  }

  int getStarsForChapter(int chapterId) {
    int total = 0;
    for (final key in completedLevels) {
      if (key.startsWith('${chapterId}_')) {
        total += levelStars[key] ?? 3;
      }
    }
    return total;
  }

  int getRequiredStarsForChapter(int chapterId) {
    if (chapterId <= 1) return 0;
    return (chapterId - 1) * 30;
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

  // ==================== ACHIEVEMENTS METHODS ====================
  int getClaimedAchievementTier(String achievementId) {
    return claimedAchievementTiers[achievementId] ?? 0;
  }

  void claimAchievementTier(String achievementId, int tierNumber) {
    claimedAchievementTiers[achievementId] = tierNumber;
  }

  bool isAchievementTierClaimed(String achievementId, int tierNumber) {
    return (claimedAchievementTiers[achievementId] ?? 0) >= tierNumber;
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
      'claimedAchievementTiers': claimedAchievementTiers,
      'levelStars': levelStars,
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

    Map<String, int> claimedTiersMap = {};
    if (json['claimedAchievementTiers'] != null) {
      final rawMap = json['claimedAchievementTiers'] as Map<String, dynamic>;
      rawMap.forEach((key, value) {
        if (value is num) {
          claimedTiersMap[key] = value.toInt();
        }
      });
    }

    Map<String, int> levelStarsMap = {};
    if (json['levelStars'] != null) {
      final rawMap = json['levelStars'] as Map<String, dynamic>;
      rawMap.forEach((key, value) {
        if (value is num) {
          levelStarsMap[key] = value.toInt();
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
      claimedAchievementTiers: claimedTiersMap,
      levelStars: levelStarsMap,
    );
  }
}
