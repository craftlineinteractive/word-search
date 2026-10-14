import 'dart:math';
import 'package:flutter/material.dart';
import '../engine/word_grid_engine.dart';
import '../models/grid_coordinate.dart';
import '../models/placed_word.dart';
import '../models/word_item.dart';
import '../services/sound_manager.dart';
import 'word_grid_painter.dart';

class WordSearchGrid extends StatefulWidget {
  final List<List<String>> grid;
  final List<WordItem> levelWords;
  final List<PlacedWord> foundWords;
  final GridCoordinate? hintCoordinate;
  final Function(PlacedWord placedWord, WordItem wordItem) onWordFound;

  const WordSearchGrid({
    super.key,
    required this.grid,
    required this.levelWords,
    required this.foundWords,
    this.hintCoordinate,
    required this.onWordFound,
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double size = min(constraints.maxWidth, constraints.maxHeight);

        return Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2430) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 90 : 20),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: isDark ? const Color(0xFF3F4A63) : const Color(0xFFE2E8F0),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
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
                        isDark: isDark,
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
      final line = WordGridEngine.getLineCoordinates(_startCoord!, coord);
      if (line != null) {
        if (_activeSelection == null || line.length != _activeSelection!.length) {
          SoundManager.instance.playLetterTap();
        }
        setState(() {
          _currentCoord = coord;
          _activeSelection = line;
        });
      }
    }
  }

  void _handlePanEnd() {
    _evaluateSelection();
    _resetSelection();
  }

  void _handlePanCancel() {
    _resetSelection();
  }

  void _resetSelection() {
    setState(() {
      _startCoord = null;
      _currentCoord = null;
      _activeSelection = null;
    });
  }

  void _evaluateSelection() {
    if (_activeSelection == null || _activeSelection!.length < 2) return;

    final selectedWordForward = WordGridEngine.getStringForCoordinates(widget.grid, _activeSelection!);
    final selectedWordBackward = selectedWordForward.split('').reversed.join('');

    // Check against level words
    for (var wordItem in widget.levelWords) {
      final cleanTarget = wordItem.word.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');

      // Check if already found
      bool alreadyFound = widget.foundWords.any(
        (fw) => fw.word.toUpperCase() == cleanTarget,
      );
      if (alreadyFound) continue;

      if (cleanTarget == selectedWordForward) {
        final placed = PlacedWord(
          word: cleanTarget,
          coordinates: List.from(_activeSelection!),
          colorValue: _activeColor.toARGB32(),
        );
        SoundManager.instance.playWordFound(streak: widget.foundWords.length + 1);
        widget.onWordFound(placed, wordItem);
        return;
      } else if (cleanTarget == selectedWordBackward) {
        final placed = PlacedWord(
          word: cleanTarget,
          coordinates: List.from(_activeSelection!.reversed),
          colorValue: _activeColor.toARGB32(),
        );
        SoundManager.instance.playWordFound(streak: widget.foundWords.length + 1);
        widget.onWordFound(placed, wordItem);
        return;
      }
    }

    // Invalid word selection
    SoundManager.instance.playError();
  }

  GridCoordinate? _offsetToCoordinate(Offset offset, double boardSize) {
    if (_rows == 0 || _cols == 0) return null;

    const double padding = WordGridPainter.gridPadding;
    final double innerWidth = boardSize - padding * 2;
    final double innerHeight = boardSize - padding * 2;
    final double cellWidth = innerWidth / _cols;
    final double cellHeight = innerHeight / _rows;

    final double x = offset.dx - padding;
    final double y = offset.dy - padding;

    final int col = (x / cellWidth).floor();
    final int row = (y / cellHeight).floor();

    if (row >= 0 && row < _rows && col >= 0 && col < _cols) {
      return GridCoordinate(row, col);
    }
    return null;
  }

  Color _getNextWordColor() {
    final colors = WordGridEngine.defaultWordColors;
    final colorVal = colors[widget.foundWords.length % colors.length];
    return Color(colorVal);
  }
}
