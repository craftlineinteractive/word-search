import 'puzzle_level.dart';

class Chapter {
  final int id;
  final String key;
  final String title;
  final String iconAsset;
  final int themeColor;
  final List<PuzzleLevel> levels;

  Chapter({
    required this.id,
    required this.key,
    required this.title,
    required this.iconAsset,
    required this.themeColor,
    required this.levels,
  });

  int get totalLevels => levels.length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'title': title,
      'iconAsset': iconAsset,
      'themeColor': themeColor,
      'levels': levels.map((l) => l.toJson()).toList(),
    };
  }

  factory Chapter.fromJson(Map<String, dynamic> json) {
    var rawLevels = json['levels'] as List<dynamic>? ?? [];
    return Chapter(
      id: json['id'] as int? ?? 1,
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? 'World',
      iconAsset: json['iconAsset'] as String? ?? '',
      themeColor: json['themeColor'] as int? ?? 0xFF4CAF50,
      levels: rawLevels
          .map((l) => PuzzleLevel.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Backward-compatible alias for the user-facing 'World' concept
typedef World = Chapter;

