import 'grid_coordinate.dart';

class PlacedWord {
  final String word;
  final List<GridCoordinate> coordinates;
  final int colorValue;

  PlacedWord({
    required this.word,
    required this.coordinates,
    required this.colorValue,
  });

  GridCoordinate get start => coordinates.first;
  GridCoordinate get end => coordinates.last;

  Map<String, dynamic> toJson() => {
        'word': word,
        'coordinates': coordinates.map((c) => c.toJson()).toList(),
        'colorValue': colorValue,
      };

  factory PlacedWord.fromJson(Map<String, dynamic> json) {
    return PlacedWord(
      word: json['word'] as String,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => GridCoordinate.fromJson(e as Map<String, dynamic>))
          .toList(),
      colorValue: json['colorValue'] as int,
    );
  }
}
