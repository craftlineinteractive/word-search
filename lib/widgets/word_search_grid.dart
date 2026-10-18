import 'dart:math';
import 'package:flutter/material.dart';
import '../models/grid_coordinate.dart';
import '../models/placed_word.dart';
import '../models/word_item.dart';
import '../services/sound_manager.dart';
import '../theme/world_theme.dart';
import 'word_grid_painter.dart';

class WordSearchGrid extends StatefulWidget {
  final List<List<String>> grid;
  final List<WordItem> levelWords;
  final List<PlacedWord> foundWords;
  final GridCoordinate? hintCoordinate;
  final Function(PlacedWord placedWord, WordItem wordItem) onWordFound;
  final WorldTheme? worldTheme;

  const WordSearchGrid({
    super.key,
    required this.grid,
    required this.levelWords,
    required this.foundWords,
    this.hintCoordinate,
    required this.onWordFound,
    this.worldTheme,
  });

  @override
  State<WordSearchGrid> createState() => _WordSearchGridState();
}

class _WordSearchGridState extends State<WordSearchGrid>
    with SingleTickerProviderStateMixin {
  GridCoordinate? _startCoord;
  GridCoordinate? _currentCoord;
  List<GridCoordinate>? _activeSelection;
  Color _activeColor = const Color(0xFFFFD740);

  late AnimationController _hintAnimationController;

  int get _rows => widget.grid.length;
  int get _cols => widget.grid.isNotEmpty ? widget.grid[0].length : 0;

  @override
  void initState() {
    super.initState();
    _hintAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    if (widget.hintCoordinate != null) {
      _hintAnimationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant WordSearchGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hintCoordinate != null) {
      if (!_hintAnimationController.isAnimating) {
        _hintAnimationController.repeat(reverse: true);
      }
    } else {
      if (_hintAnimationController.isAnimating) {
        _hintAnimationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _hintAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_rows == 0 || _cols == 0) {
      return const SizedBox.shrink();
    }

    final worldTheme = widget.worldTheme;
    final boardBgColor = worldTheme?.boardBackgroundColor ?? const Color(0xFFFFFDF5);
    final borderColor = worldTheme?.gridBorderColor ?? const Color(0xFF5D4037);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double size = min(constraints.maxWidth, constraints.maxHeight);

        return Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: boardBgColor,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2A1810).withAlpha(60),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: borderColor,
                width: 2.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GestureDetector(
                onPanStart: (details) => _handlePanStart(details.localPosition, size),
                onPanUpdate: (details) => _handlePanUpdate(details.localPosition, size),
                onPanEnd: (_) => _handlePanEnd(),
                onPanCancel: () => _handlePanCancel(),
                child: AnimatedBuilder(
                  animation: _hintAnimationController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(size, size),
                      painter: WordGridPainter(
                        grid: widget.grid,
                        foundWords: widget.foundWords,
                        activeSelection: _activeSelection,
                        activeSelectionColor: _activeColor,
                        hintCoordinate: widget.hintCoordinate,
                        hintAnimationValue: _hintAnimationController.value,
                        isDark: false,
                        worldTheme: worldTheme,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handlePanStart(Offset localPos, double boardSize) {
    final coord = _offsetToCoordinate(localPos, boardSize);
    if (coord != null) {
      SoundManager.instance.playLetterTap();
      setState(() {
        _startCoord = coord;
        _currentCoord = coord;
        _activeSelection = [coord];
        _activeColor = _getNextWordColor();
      });
    }
  }

  void _handlePanUpdate(Offset localPos, double boardSize) {
    if (_startCoord == null) return;

    final coord = _offsetToCoordinate(localPos, boardSize);
    if (coord != null && coord != _currentCoord) {
      _currentCoord = coord;
      final lineCoords = _computeValidLineCoordinates(_startCoord!, coord);
      if (lineCoords != null) {
        if (_activeSelection == null || _activeSelection!.length != lineCoords.length) {
          SoundManager.instance.playLetterTap();
        }
        setState(() {
          _activeSelection = lineCoords;
        });
      }
    }
  }

  void _handlePanEnd() {
    _validateAndSubmitWord();
    setState(() {
      _startCoord = null;
      _currentCoord = null;
      _activeSelection = null;
    });
  }

  void _handlePanCancel() {
    setState(() {
      _startCoord = null;
      _currentCoord = null;
      _activeSelection = null;
    });
  }

  void _validateAndSubmitWord() {
    if (_activeSelection == null || _activeSelection!.length < 2) return;

    // Build word strings in forward and backward directions
    final StringBuffer forwardBuffer = StringBuffer();
    final StringBuffer backwardBuffer = StringBuffer();

    for (final c in _activeSelection!) {
      forwardBuffer.write(widget.grid[c.row][c.col]);
    }
    for (final c in _activeSelection!.reversed) {
      backwardBuffer.write(widget.grid[c.row][c.col]);
    }

    final forwardWord = forwardBuffer.toString().toUpperCase();
    final backwardWord = backwardBuffer.toString().toUpperCase();

    // Check if forward or backward matches any level word
    for (final item in widget.levelWords) {
      final cleanTarget = item.word.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');

      if (cleanTarget == forwardWord || cleanTarget == backwardWord) {
        // Check if already found
        final isAlreadyFound = widget.foundWords.any(
          (w) => w.word.toUpperCase() == cleanTarget,
        );

        if (!isAlreadyFound) {
          final matchedCoords = (cleanTarget == forwardWord)
              ? List<GridCoordinate>.from(_activeSelection!)
              : List<GridCoordinate>.from(_activeSelection!.reversed);

          final placedWord = PlacedWord(
            word: item.word,
            coordinates: matchedCoords,
            colorValue: _activeColor.toARGB32(),
          );

          SoundManager.instance.playWordFound();
          widget.onWordFound(placedWord, item);
          return;
        }
      }
    }

    // Invalid word selection or already found word - play error feedback
    SoundManager.instance.playError();
  }

  GridCoordinate? _offsetToCoordinate(Offset localPos, double boardSize) {
    const double padding = WordGridPainter.gridPadding;
    final double innerWidth = boardSize - padding * 2;
    final double innerHeight = boardSize - padding * 2;

    if (localPos.dx < padding ||
        localPos.dx > boardSize - padding ||
        localPos.dy < padding ||
        localPos.dy > boardSize - padding) {
      return null;
    }

    final double cellWidth = innerWidth / _cols;
    final double cellHeight = innerHeight / _rows;

    final int col = ((localPos.dx - padding) / cellWidth).floor().clamp(0, _cols - 1);
    final int row = ((localPos.dy - padding) / cellHeight).floor().clamp(0, _rows - 1);

    return GridCoordinate(row, col);
  }

  List<GridCoordinate>? _computeValidLineCoordinates(GridCoordinate start, GridCoordinate end) {
    final int deltaRow = end.row - start.row;
    final int deltaCol = end.col - start.col;

    // Check if horizontal, vertical, or diagonal (45 degrees)
    final bool isHorizontal = deltaRow == 0 && deltaCol != 0;
    final bool isVertical = deltaCol == 0 && deltaRow != 0;
    final bool isDiagonal = deltaRow.abs() == deltaCol.abs() && deltaRow != 0;

    if (!isHorizontal && !isVertical && !isDiagonal) {
      return null;
    }

    final int steps = max(deltaRow.abs(), deltaCol.abs());
    final int stepRow = deltaRow == 0 ? 0 : deltaRow ~/ deltaRow.abs();
    final int stepCol = deltaCol == 0 ? 0 : deltaCol ~/ deltaCol.abs();

    final List<GridCoordinate> line = [];
    for (int i = 0; i <= steps; i++) {
      line.add(GridCoordinate(
        start.row + i * stepRow,
        start.col + i * stepCol,
      ));
    }
    return line;
  }

  Color _getNextWordColor() {
    const colors = [
      Color(0xFFE91E63), // Rose
      Color(0xFF9C27B0), // Purple
      Color(0xFF2196F3), // Azure
      Color(0xFF00BCD4), // Cyan
      Color(0xFF4CAF50), // Green
      Color(0xFFFF9800), // Orange
      Color(0xFF795548), // Amber
    ];
    final index = widget.foundWords.length % colors.length;
    return colors[index];
  }
}
