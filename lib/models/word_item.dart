class WordItem {
  final String word;
  final String meaning;
  final String? example;
  bool isFound;
  int? highlightColor;

  WordItem({
    required this.word,
    required this.meaning,
    this.example,
    this.isFound = false,
    this.highlightColor,
  });

  String get normalizedWord => word.trim().toUpperCase();

  WordItem copyWith({
    String? word,
    String? meaning,
    String? example,
    bool? isFound,
    int? highlightColor,
  }) {
    return WordItem(
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      isFound: isFound ?? this.isFound,
      highlightColor: highlightColor ?? this.highlightColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'meaning': meaning,
      if (example != null) 'example': example,
    };
  }

  factory WordItem.fromJson(Map<String, dynamic> json) {
    return WordItem(
      word: (json['word'] as String).trim().toUpperCase(),
      meaning: (json['meaning'] as String?) ?? 'A meaningful term related to the category.',
      example: json['example'] as String?,
    );
  }
}
