import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/chapter.dart';

class ChapterMeta {
  final int id;
  final String key;
  final String title;
  final String iconAsset;
  final int themeColor;
  final String jsonFile;

  const ChapterMeta({
    required this.id,
    required this.key,
    required this.title,
    required this.iconAsset,
    required this.themeColor,
    required this.jsonFile,
  });
}

/// Backward-compatible alias for the user-facing 'WorldMeta' concept
typedef WorldMeta = ChapterMeta;

class LevelRepository {
  static final List<ChapterMeta> catalog = [
    const ChapterMeta(id: 1, key: 'food', title: 'Food', iconAsset: 'assets/chapter_images/food.png', themeColor: 0xFFFF5722, jsonFile: 'world_01_food.json'),
    const ChapterMeta(id: 2, key: 'holiday', title: 'Holiday', iconAsset: 'assets/chapter_images/holiday.png', themeColor: 0xFF00BCD4, jsonFile: 'world_02_holiday.json'),
    const ChapterMeta(id: 3, key: 'jobs', title: 'Jobs', iconAsset: 'assets/chapter_images/jobs.png', themeColor: 0xFF3F51B5, jsonFile: 'world_03_jobs.json'),
    const ChapterMeta(id: 4, key: 'electronics', title: 'Electronics', iconAsset: 'assets/chapter_images/electronics.png', themeColor: 0xFF2196F3, jsonFile: 'world_04_electronics.json'),
    const ChapterMeta(id: 5, key: 'books', title: 'Books', iconAsset: 'assets/chapter_images/books.png', themeColor: 0xFF795548, jsonFile: 'world_05_books.json'),
    const ChapterMeta(id: 6, key: 'games', title: 'Games', iconAsset: 'assets/chapter_images/games.png', themeColor: 0xFF9C27B0, jsonFile: 'world_06_games.json'),
    const ChapterMeta(id: 7, key: 'plants', title: 'Plants', iconAsset: 'assets/chapter_images/plants.png', themeColor: 0xFF4CAF50, jsonFile: 'world_07_plants.json'),
    const ChapterMeta(id: 8, key: 'painting', title: 'Painting', iconAsset: 'assets/chapter_images/painting.png', themeColor: 0xFFFF9800, jsonFile: 'world_08_painting.json'),
    const ChapterMeta(id: 9, key: 'words', title: 'Words', iconAsset: 'assets/chapter_images/words.png', themeColor: 0xFF673AB7, jsonFile: 'world_09_words.json'),
    const ChapterMeta(id: 10, key: 'professional', title: 'Professional', iconAsset: 'assets/chapter_images/professional.png', themeColor: 0xFF607D8B, jsonFile: 'world_10_professional.json'),
    const ChapterMeta(id: 11, key: 'religion', title: 'Religion', iconAsset: 'assets/chapter_images/religion.png', themeColor: 0xFF8D6E63, jsonFile: 'world_11_religion.json'),
    const ChapterMeta(id: 12, key: 'music', title: 'Music', iconAsset: 'assets/chapter_images/music.png', themeColor: 0xFFE91E63, jsonFile: 'world_12_music.json'),
    const ChapterMeta(id: 13, key: 'hobby', title: 'Hobby', iconAsset: 'assets/chapter_images/hobby.png', themeColor: 0xFFFF5722, jsonFile: 'world_13_hobby.json'),
    const ChapterMeta(id: 14, key: 'nature', title: 'Nature', iconAsset: 'assets/chapter_images/nature.png', themeColor: 0xFF2E7D32, jsonFile: 'world_14_nature.json'),
    const ChapterMeta(id: 15, key: 'tournament', title: 'Tournament', iconAsset: 'assets/chapter_images/tournament.png', themeColor: 0xFFFFC107, jsonFile: 'world_15_tournament.json'),
    const ChapterMeta(id: 16, key: 'education', title: 'Education', iconAsset: 'assets/chapter_images/education.png', themeColor: 0xFF3F51B5, jsonFile: 'world_16_education.json'),
    const ChapterMeta(id: 17, key: 'technology', title: 'Technology', iconAsset: 'assets/chapter_images/technology.png', themeColor: 0xFF009688, jsonFile: 'world_17_technology.json'),
    // Animal worlds separated across different positions as requested (Birds: 18, Pets: 22, Wild Animals: 26)
    const ChapterMeta(id: 18, key: 'birds', title: 'Birds', iconAsset: 'assets/chapter_images/birds.png', themeColor: 0xFF03A9F4, jsonFile: 'world_18_birds.json'),
    const ChapterMeta(id: 19, key: 'weather', title: 'Weather', iconAsset: 'assets/chapter_images/weather.png', themeColor: 0xFF00ACC1, jsonFile: 'world_19_weather.json'),
    const ChapterMeta(id: 20, key: 'ocean', title: 'Ocean', iconAsset: 'assets/chapter_images/ocean.png', themeColor: 0xFF0288D1, jsonFile: 'world_20_ocean.json'),
    const ChapterMeta(id: 21, key: 'sports', title: 'Sports', iconAsset: 'assets/chapter_images/sports.png', themeColor: 0xFF4CAF50, jsonFile: 'world_21_sports.json'),
    const ChapterMeta(id: 22, key: 'pets', title: 'Pets', iconAsset: 'assets/chapter_images/pets.png', themeColor: 0xFFFF9800, jsonFile: 'world_22_pets.json'),
    const ChapterMeta(id: 23, key: 'vehicles', title: 'Vehicles', iconAsset: 'assets/chapter_images/vehicles.png', themeColor: 0xFFF44336, jsonFile: 'world_23_vehicles.json'),
    const ChapterMeta(id: 24, key: 'city', title: 'City', iconAsset: 'assets/chapter_images/city.png', themeColor: 0xFF3F51B5, jsonFile: 'world_24_city.json'),
    const ChapterMeta(id: 25, key: 'home', title: 'Home', iconAsset: 'assets/chapter_images/home.png', themeColor: 0xFF8D6E63, jsonFile: 'world_25_home.json'),
    const ChapterMeta(id: 26, key: 'wild-animals', title: 'Wild Animals', iconAsset: 'assets/chapter_images/wild-animals.png', themeColor: 0xFFE65100, jsonFile: 'world_26_wild-animals.json'),
    const ChapterMeta(id: 27, key: 'fashion', title: 'Fashion', iconAsset: 'assets/chapter_images/fashion.png', themeColor: 0xFFE91E63, jsonFile: 'world_27_fashion.json'),
    const ChapterMeta(id: 28, key: 'entertainment', title: 'Entertainment', iconAsset: 'assets/chapter_images/entertainment.png', themeColor: 0xFFFF5722, jsonFile: 'world_28_entertainment.json'),
    const ChapterMeta(id: 29, key: 'adventure', title: 'Adventure', iconAsset: 'assets/chapter_images/adventure.png', themeColor: 0xFFFF9800, jsonFile: 'world_29_adventure.json'),
    const ChapterMeta(id: 30, key: 'fantasy', title: 'Fantasy', iconAsset: 'assets/chapter_images/fantasy.png', themeColor: 0xFF9C27B0, jsonFile: 'world_30_fantasy.json'),
  ];

  static final Map<String, Chapter> _cachedChaptersByFile = {};
  static final Map<int, Chapter> _cachedChaptersById = {};

  static Future<Chapter> loadChapterById(int id) async {
    if (_cachedChaptersById.containsKey(id)) {
      return _cachedChaptersById[id]!;
    }

    final meta = catalog.firstWhere(
      (m) => m.id == id,
      orElse: () => catalog.first,
    );

    return loadChapter(meta.jsonFile);
  }

  static Future<World> loadWorldById(int id) => loadChapterById(id);

  static Future<Chapter> loadChapter(String filename) async {
    if (_cachedChaptersByFile.containsKey(filename)) {
      return _cachedChaptersByFile[filename]!;
    }

    try {
      String jsonString;
      try {
        jsonString = await rootBundle.loadString('assets/data/$filename');
      } catch (_) {
        // Fallback for seamless transition between world_ and chapter_ filenames
        final fallbackName = filename.startsWith('world_')
            ? filename.replaceFirst('world_', 'chapter_')
            : filename.replaceFirst('chapter_', 'world_');
        jsonString = await rootBundle.loadString('assets/data/$fallbackName');
      }

      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final chapter = Chapter.fromJson(jsonData);
      _cachedChaptersByFile[filename] = chapter;
      _cachedChaptersById[chapter.id] = chapter;
      return chapter;
    } catch (e) {
      throw Exception('Failed to load world/chapter from assets/data/$filename: $e');
    }
  }

  static Future<World> loadWorld(String filename) => loadChapter(filename);

  static void cacheChapter(Chapter chapter) {
    _cachedChaptersById[chapter.id] = chapter;
    final meta = catalog.firstWhere((m) => m.id == chapter.id, orElse: () => catalog.first);
    _cachedChaptersByFile[meta.jsonFile] = chapter;
  }

  static void cacheWorld(World world) => cacheChapter(world);

  static Chapter? getCached(int chapterId) => _cachedChaptersById[chapterId];
  static World? getCachedWorld(int worldId) => getCached(worldId);

  static void clearCache() {
    _cachedChaptersByFile.clear();
    _cachedChaptersById.clear();
  }
}

