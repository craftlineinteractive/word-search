import 'word_item.dart';

class PuzzleLevel {
  final int levelNumber;
  final String title;
  final int gridRows;
  final int gridCols;
  final List<WordItem> words;
  final String difficulty;
  final List<List<String>>? prebakedGrid;

  PuzzleLevel({
    required this.levelNumber,
    required this.title,
    required this.gridRows,
    required this.gridCols,
    required this.words,
    this.difficulty = 'normal',
    this.prebakedGrid,
  });

  Map<String, dynamic> toJson() {
    return {
      'levelNumber': levelNumber,
      'title': title,
      'gridRows': gridRows,
      'gridCols': gridCols,
      'difficulty': difficulty,
      'words': words.map((w) => w.toJson()).toList(),
      if (prebakedGrid != null) 'prebakedGrid': prebakedGrid,
    };
  }

  factory PuzzleLevel.fromJson(Map<String, dynamic> json) {
    var rawWords = json['words'] as List<dynamic>? ?? [];
    List<WordItem> parsedWords = [];
    for (var item in rawWords) {
      if (item is String) {
        parsedWords.add(WordItem(word: item, meaning: 'Search and find $item'));
      } else if (item is Map<String, dynamic>) {
        parsedWords.add(WordItem.fromJson(item));
      }
    }

    List<List<String>>? prebaked;
    if (json['prebakedGrid'] != null) {
      prebaked = (json['prebakedGrid'] as List<dynamic>)
          .map((row) => (row as List<dynamic>).map((c) => c.toString()).toList())
          .toList();
    }

    return PuzzleLevel(
      levelNumber: json['levelNumber'] as int? ?? 1,
      title: json['title'] as String? ?? 'Level ${json['levelNumber'] ?? 1}',
      gridRows: json['gridRows'] as int? ?? 8,
      gridCols: json['gridCols'] as int? ?? 8,
      difficulty: json['difficulty'] as String? ?? 'normal',
      words: parsedWords,
      prebakedGrid: prebaked,
    );
  }
}
