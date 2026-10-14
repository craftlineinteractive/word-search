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

class LevelRepository {
  static final List<ChapterMeta> catalog = [
    const ChapterMeta(id: 1, key: 'food', title: 'Food', iconAsset: 'assets/chapter_images/food.png', themeColor: 0xFFFF5722, jsonFile: 'chapter_01_food.json'),
    const ChapterMeta(id: 2, key: 'holiday', title: 'Holiday', iconAsset: 'assets/chapter_images/holiday.png', themeColor: 0xFF00BCD4, jsonFile: 'chapter_02_holiday.json'),
    const ChapterMeta(id: 3, key: 'jobs', title: 'Jobs', iconAsset: 'assets/chapter_images/jobs.png', themeColor: 0xFF3F51B5, jsonFile: 'chapter_03_jobs.json'),
    const ChapterMeta(id: 4, key: 'electronics', title: 'Electronics', iconAsset: 'assets/chapter_images/electronics.png', themeColor: 0xFF2196F3, jsonFile: 'chapter_04_electronics.json'),
    const ChapterMeta(id: 5, key: 'books', title: 'Books', iconAsset: 'assets/chapter_images/books.png', themeColor: 0xFF795548, jsonFile: 'chapter_05_books.json'),
    const ChapterMeta(id: 6, key: 'games', title: 'Games', iconAsset: 'assets/chapter_images/games.png', themeColor: 0xFF9C27B0, jsonFile: 'chapter_06_games.json'),
    const ChapterMeta(id: 7, key: 'plants', title: 'Plants', iconAsset: 'assets/chapter_images/plants.png', themeColor: 0xFF4CAF50, jsonFile: 'chapter_07_plants.json'),
    const ChapterMeta(id: 8, key: 'painting', title: 'Painting', iconAsset: 'assets/chapter_images/painting.png', themeColor: 0xFFFF9800, jsonFile: 'chapter_08_painting.json'),
    const ChapterMeta(id: 9, key: 'words', title: 'Words', iconAsset: 'assets/chapter_images/words.png', themeColor: 0xFF673AB7, jsonFile: 'chapter_09_words.json'),
    const ChapterMeta(id: 10, key: 'professional', title: 'Professional', iconAsset: 'assets/chapter_images/professional.png', themeColor: 0xFF607D8B, jsonFile: 'chapter_10_professional.json'),
    const ChapterMeta(id: 11, key: 'religion', title: 'Religion', iconAsset: 'assets/chapter_images/religion.png', themeColor: 0xFF8D6E63, jsonFile: 'chapter_11_religion.json'),
    const ChapterMeta(id: 12, key: 'music', title: 'Music', iconAsset: 'assets/chapter_images/music.png', themeColor: 0xFFE91E63, jsonFile: 'chapter_12_music.json'),
    const ChapterMeta(id: 13, key: 'hobby', title: 'Hobby', iconAsset: 'assets/chapter_images/hobby.png', themeColor: 0xFFFF5722, jsonFile: 'chapter_13_hobby.json'),
    const ChapterMeta(id: 14, key: 'nature', title: 'Nature', iconAsset: 'assets/chapter_images/nature.png', themeColor: 0xFF2E7D32, jsonFile: 'chapter_14_nature.json'),
    const ChapterMeta(id: 15, key: 'tournament', title: 'Tournament', iconAsset: 'assets/chapter_images/tournament.png', themeColor: 0xFFFFC107, jsonFile: 'chapter_15_tournament.json'),
    const ChapterMeta(id: 16, key: 'education', title: 'Education', iconAsset: 'assets/chapter_images/education.png', themeColor: 0xFF3F51B5, jsonFile: 'chapter_16_education.json'),
    const ChapterMeta(id: 17, key: 'technology', title: 'Technology', iconAsset: 'assets/chapter_images/technology.png', themeColor: 0xFF009688, jsonFile: 'chapter_17_technology.json'),
    const ChapterMeta(id: 18, key: 'birds', title: 'Birds', iconAsset: 'assets/chapter_images/birds.png', themeColor: 0xFF03A9F4, jsonFile: 'chapter_18_birds.json'),
    const ChapterMeta(id: 19, key: 'pets', title: 'Pets', iconAsset: 'assets/chapter_images/pets.png', themeColor: 0xFFFF9800, jsonFile: 'chapter_19_pets.json'),
    const ChapterMeta(id: 20, key: 'wild-animals', title: 'Wild Animals', iconAsset: 'assets/chapter_images/wild-animals.png', themeColor: 0xFFE65100, jsonFile: 'chapter_20_wild-animals.json'),
    const ChapterMeta(id: 21, key: 'ocean', title: 'Ocean', iconAsset: 'assets/chapter_images/ocean.png', themeColor: 0xFF0288D1, jsonFile: 'chapter_21_ocean.json'),
    const ChapterMeta(id: 22, key: 'weather', title: 'Weather', iconAsset: 'assets/chapter_images/weather.png', themeColor: 0xFF00ACC1, jsonFile: 'chapter_22_weather.json'),
    const ChapterMeta(id: 23, key: 'sports', title: 'Sports', iconAsset: 'assets/chapter_images/sports.png', themeColor: 0xFF4CAF50, jsonFile: 'chapter_23_sports.json'),
    const ChapterMeta(id: 24, key: 'vehicles', title: 'Vehicles', iconAsset: 'assets/chapter_images/vehicles.png', themeColor: 0xFFF44336, jsonFile: 'chapter_24_vehicles.json'),
    const ChapterMeta(id: 25, key: 'city', title: 'City', iconAsset: 'assets/chapter_images/city.png', themeColor: 0xFF3F51B5, jsonFile: 'chapter_25_city.json'),
    const ChapterMeta(id: 26, key: 'home', title: 'Home', iconAsset: 'assets/chapter_images/home.png', themeColor: 0xFF8D6E63, jsonFile: 'chapter_26_home.json'),
    const ChapterMeta(id: 27, key: 'fashion', title: 'Fashion', iconAsset: 'assets/chapter_images/fashion.png', themeColor: 0xFFE91E63, jsonFile: 'chapter_27_fashion.json'),
    const ChapterMeta(id: 28, key: 'entertainment', title: 'Entertainment', iconAsset: 'assets/chapter_images/entertainment.png', themeColor: 0xFFFF5722, jsonFile: 'chapter_28_entertainment.json'),
    const ChapterMeta(id: 29, key: 'adventure', title: 'Adventure', iconAsset: 'assets/chapter_images/adventure.png', themeColor: 0xFFFF9800, jsonFile: 'chapter_29_adventure.json'),
    const ChapterMeta(id: 30, key: 'fantasy', title: 'Fantasy', iconAsset: 'assets/chapter_images/fantasy.png', themeColor: 0xFF9C27B0, jsonFile: 'chapter_30_fantasy.json'),
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

  static Future<Chapter> loadChapter(String filename) async {
    if (_cachedChaptersByFile.containsKey(filename)) {
      return _cachedChaptersByFile[filename]!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/data/$filename');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final chapter = Chapter.fromJson(jsonData);
      _cachedChaptersByFile[filename] = chapter;
      _cachedChaptersById[chapter.id] = chapter;
      return chapter;
    } catch (e) {
      throw Exception('Failed to load chapter from assets/data/$filename: $e');
    }
  }

  static void cacheChapter(Chapter chapter) {
    _cachedChaptersById[chapter.id] = chapter;
    final meta = catalog.firstWhere((m) => m.id == chapter.id, orElse: () => catalog.first);
    _cachedChaptersByFile[meta.jsonFile] = chapter;
  }

  static Chapter? getCached(int chapterId) => _cachedChaptersById[chapterId];

  static void clearCache() {
    _cachedChaptersByFile.clear();
    _cachedChaptersById.clear();
  }
}
