import 'dart:math';
import '../models/grid_coordinate.dart';
import '../models/placed_word.dart';

enum Direction {
  horizontalForward(0, 1),
  horizontalBackward(0, -1),
  verticalDown(1, 0),
  verticalUp(-1, 0),
  diagonalDownRight(1, 1),
  diagonalUpLeft(-1, -1),
  diagonalDownLeft(1, -1),
  diagonalUpRight(-1, 1);

  final int dRow;
  final int dCol;

  const Direction(this.dRow, this.dCol);

  bool get isDiagonal => dRow != 0 && dCol != 0;
  bool get isVertical => dRow != 0 && dCol == 0;
  bool get isHorizontal => dRow == 0 && dCol != 0;
}

class GridGenerationResult {
  final List<List<String>> grid;
  final List<PlacedWord> placedWords;
  final List<String> unplacedWords;

  GridGenerationResult({
    required this.grid,
    required this.placedWords,
    required this.unplacedWords,
  });
}

class WordGridEngine {
  static final Random _defaultRandom = Random();

  // Vibrant highlight colors for found words (like in the reference game screenshots)
  static const List<int> defaultWordColors = [
    0xFFFF5252, // Coral Red
    0xFF448AFF, // Vibrant Blue
    0xFF69F0AE, // Mint Green
    0xFFFFD740, // Sunny Amber
    0xFFE040FB, // Neon Purple
    0xFFFF6E40, // Deep Orange
    0xFF18FFFF, // Bright Cyan
    0xFFFF4081, // Vivid Pink
    0xFFB2FF59, // Lime Green
    0xFF7C4DFF, // Deep Violet
  ];

  /// Generates a word search grid matrix with balanced 8-directional placement (horizontal, vertical, diagonal, backwards).
  static GridGenerationResult generateGrid({
    required int rows,
    required int cols,
    required List<String> words,
    List<Direction>? allowedDirections,
    Random? random,
    bool allowBackwards = true,
    bool allowDiagonals = true,
  }) {
    final rng = random ?? _defaultRandom;

    // Determine active directions
    List<Direction> allDirs = allowedDirections ?? _resolveDirections(allowBackwards, allowDiagonals);

    // Sort words by length descending so longer words get placed first
    List<String> sortedWords = List.from(words)
      ..sort((a, b) => b.length.compareTo(a.length));

    GridGenerationResult? bestResult;

    for (int attempt = 0; attempt < 10; attempt++) {
      // Re-shuffle direction subsets for this attempt
      final List<Direction> diagonalDirs = allDirs.where((d) => d.isDiagonal).toList()..shuffle(rng);
      final List<Direction> verticalDirs = allDirs.where((d) => d.isVertical).toList()..shuffle(rng);
      final List<Direction> horizontalDirs = allDirs.where((d) => d.isHorizontal).toList()..shuffle(rng);

      // Initialize blank grid
      List<List<String?>> matrix = List.generate(
        rows,
        (_) => List<String?>.filled(cols, null),
      );

      List<PlacedWord> placed = [];
      List<String> unplaced = [];

      for (int i = 0; i < sortedWords.length; i++) {
        String cleanWord = sortedWords[i].trim().toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
        if (cleanWord.isEmpty) continue;

        // Cycle prioritized direction family: Diagonal -> Vertical -> Horizontal -> Diagonal ...
        List<Direction> prioritizedDirs = [];
        if (i % 3 == 0 && diagonalDirs.isNotEmpty) {
          prioritizedDirs.addAll(diagonalDirs);
          prioritizedDirs.addAll(verticalDirs);
          prioritizedDirs.addAll(horizontalDirs);
        } else if (i % 3 == 1 && verticalDirs.isNotEmpty) {
          prioritizedDirs.addAll(verticalDirs);
          prioritizedDirs.addAll(diagonalDirs);
          prioritizedDirs.addAll(horizontalDirs);
        } else {
          prioritizedDirs.addAll(horizontalDirs);
          prioritizedDirs.addAll(diagonalDirs);
          prioritizedDirs.addAll(verticalDirs);
        }

        bool wasPlaced = _tryPlaceWord(
          matrix: matrix,
          rows: rows,
          cols: cols,
          word: cleanWord,
          directions: prioritizedDirs,
          rng: rng,
          colorValue: defaultWordColors[i % defaultWordColors.length],
          onPlaced: (placedWord) => placed.add(placedWord),
        );

        if (!wasPlaced) {
          unplaced.add(cleanWord);
        }
      }

      // Fill remaining null cells with random letters
      const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      List<List<String>> finalGrid = List.generate(rows, (r) {
        return List.generate(cols, (c) {
          return matrix[r][c] ?? letters[rng.nextInt(letters.length)];
        });
      });

      final result = GridGenerationResult(
        grid: finalGrid,
        placedWords: placed,
        unplacedWords: unplaced,
      );

      if (unplaced.isEmpty) {
        return result; // 100% placed successfully
      }

      if (bestResult == null || unplaced.length < bestResult.unplacedWords.length) {
        bestResult = result;
      }
    }

    return bestResult!;
  }

  static List<Direction> _resolveDirections(bool allowBackwards, bool allowDiagonals) {
    List<Direction> dirs = [
      Direction.horizontalForward,
      Direction.verticalDown,
    ];

    if (allowBackwards) {
      dirs.add(Direction.horizontalBackward);
      dirs.add(Direction.verticalUp);
    }

    if (allowDiagonals) {
      dirs.add(Direction.diagonalDownRight);
      dirs.add(Direction.diagonalDownLeft);
      if (allowBackwards) {
        dirs.add(Direction.diagonalUpLeft);
        dirs.add(Direction.diagonalUpRight);
      }
    }

    return dirs;
  }

  static bool _tryPlaceWord({
    required List<List<String?>> matrix,
    required int rows,
    required int cols,
    required String word,
    required List<Direction> directions,
    required Random rng,
    required int colorValue,
    required Function(PlacedWord) onPlaced,
  }) {
    List<GridCoordinate> allPositions = [];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        allPositions.add(GridCoordinate(r, c));
      }
    }
    allPositions.shuffle(rng);

    // First attempt: look for positions where the word intersects with existing letters
    for (var dir in directions) {
      for (var pos in allPositions) {
        int intersections = _countIntersections(matrix, rows, cols, word, pos.row, pos.col, dir);
        if (intersections > 0 && _canPlace(matrix, rows, cols, word, pos.row, pos.col, dir)) {
          return _commitPlacement(matrix, word, pos.row, pos.col, dir, colorValue, onPlaced);
        }
      }
    }

    // Second attempt: place in any valid open slot
    for (var dir in directions) {
      for (var pos in allPositions) {
        if (_canPlace(matrix, rows, cols, word, pos.row, pos.col, dir)) {
          return _commitPlacement(matrix, word, pos.row, pos.col, dir, colorValue, onPlaced);
        }
      }
    }

    return false;
  }

  static bool _commitPlacement(
    List<List<String?>> matrix,
    String word,
    int startRow,
    int startCol,
    Direction dir,
    int colorValue,
    Function(PlacedWord) onPlaced,
  ) {
    List<GridCoordinate> coords = [];
    for (int i = 0; i < word.length; i++) {
      int r = startRow + i * dir.dRow;
      int c = startCol + i * dir.dCol;
      matrix[r][c] = word[i];
      coords.add(GridCoordinate(r, c));
    }

    onPlaced(PlacedWord(
      word: word,
      coordinates: coords,
      colorValue: colorValue,
    ));
    return true;
  }

  static int _countIntersections(
    List<List<String?>> matrix,
    int rows,
    int cols,
    String word,
    int startRow,
    int startCol,
    Direction dir,
  ) {
    int endRow = startRow + (word.length - 1) * dir.dRow;
    int endCol = startCol + (word.length - 1) * dir.dCol;

    if (endRow < 0 || endRow >= rows || endCol < 0 || endCol >= cols) {
      return 0;
    }

    int matchCount = 0;
    for (int i = 0; i < word.length; i++) {
      int r = startRow + i * dir.dRow;
      int c = startCol + i * dir.dCol;
      String? current = matrix[r][c];
      if (current != null) {
        if (current == word[i]) {
          matchCount++;
        } else {
          return 0; // conflict
        }
      }
    }
    return matchCount;
  }

  static bool _canPlace(
    List<List<String?>> matrix,
    int rows,
    int cols,
    String word,
    int startRow,
    int startCol,
    Direction dir,
  ) {
    int endRow = startRow + (word.length - 1) * dir.dRow;
    int endCol = startCol + (word.length - 1) * dir.dCol;

    if (endRow < 0 || endRow >= rows || endCol < 0 || endCol >= cols) {
      return false;
    }

    for (int i = 0; i < word.length; i++) {
      int r = startRow + i * dir.dRow;
      int c = startCol + i * dir.dCol;
      String? current = matrix[r][c];
      if (current != null && current != word[i]) {
        return false;
      }
    }

    return true;
  }

  /// Helper to calculate grid line coordinates between start and end cell
  static List<GridCoordinate>? getLineCoordinates(
    GridCoordinate start,
    GridCoordinate end,
  ) {
    int dRow = end.row - start.row;
    int dCol = end.col - start.col;

    // Check if horizontal, vertical, or 45-degree diagonal
    bool isHorizontal = dRow == 0 && dCol != 0;
    bool isVertical = dCol == 0 && dRow != 0;
    bool isDiagonal = dRow.abs() == dCol.abs() && dRow != 0;

    if (!isHorizontal && !isVertical && !isDiagonal) {
      return null;
    }

    int steps = max(dRow.abs(), dCol.abs());
    int stepRow = dRow == 0 ? 0 : (dRow > 0 ? 1 : -1);
    int stepCol = dCol == 0 ? 0 : (dCol > 0 ? 1 : -1);

    List<GridCoordinate> line = [];
    for (int i = 0; i <= steps; i++) {
      line.add(GridCoordinate(
        start.row + i * stepRow,
        start.col + i * stepCol,
      ));
    }
    return line;
  }

  /// Extracts the string for a given coordinate sequence from the grid
  static String getStringForCoordinates(
    List<List<String>> grid,
    List<GridCoordinate> coords,
  ) {
    StringBuffer buffer = StringBuffer();
    for (var c in coords) {
      if (c.row >= 0 && c.row < grid.length && c.col >= 0 && c.col < grid[0].length) {
        buffer.write(grid[c.row][c.col]);
      }
    }
    return buffer.toString();
  }
}
