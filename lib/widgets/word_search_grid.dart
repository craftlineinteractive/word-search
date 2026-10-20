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
        final double availableWidth = constraints.maxWidth;
        final double availableHeight = constraints.maxHeight;
        const double previewHeight = 44.0;
        const double spacing = 6.0;

        // Ensure board is a square fitting comfortably within remaining bounds
        final double maxBoardHeight = max(100.0, availableHeight - previewHeight - spacing);
        final double size = min(availableWidth, maxBoardHeight);

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Live Selected Word Alphabet Tile Display
              SizedBox(
                height: previewHeight,
                child: Center(
                  child: _buildSelectedWordPreview(availableWidth),
                ),
              ),

              const SizedBox(height: spacing),

              // 2. Interactive Word Search Grid Board
              Container(
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedWordPreview(double availableWidth) {
    final bool hasSelection = _activeSelection != null && _activeSelection!.isNotEmpty;

    if (!hasSelection) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF5).withAlpha(200),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF8D6E63).withAlpha(80),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2A1810).withAlpha(15),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_rounded, size: 15, color: Color(0xFF8D6E63)),
            SizedBox(width: 6),
            Text(
              'SWIPE LETTERS TO FIND WORDS',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: Color(0xFF5D4037),
              ),
            ),
          ],
        ),
      );
    }

    // Extract letters for the active selection
    final List<String> letters = [];
    for (final coord in _activeSelection!) {
      if (coord.row >= 0 && coord.row < _rows && coord.col >= 0 && coord.col < _cols) {
        letters.add(widget.grid[coord.row][coord.col]);
      }
    }

    final forwardWord = letters.join().toUpperCase();
    final backwardWord = letters.reversed.join().toUpperCase();

    // Check if current selection matches a target level word
    bool isTargetWord = false;
    for (final item in widget.levelWords) {
      final clean = item.word.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
      if (clean == forwardWord || clean == backwardWord) {
        isTargetWord = true;
        break;
      }
    }

    // Sizing computation for each alphabet tile
    final int count = letters.length;
    const double maxTileWidth = 38.0;
    final double computedWidth = ((availableWidth - 32) / max(count, 1)) - 6.0;
    final double tileWidth = computedWidth.clamp(24.0, maxTileWidth);
    final double tileHeight = (tileWidth * 1.12).clamp(28.0, 42.0);
    final double fontSize = (tileWidth * 0.56).clamp(13.0, 20.0);

    final tileBorderColor = isTargetWord ? const Color(0xFF2E7D32) : _activeColor;
    final tileGlowColor = isTargetWord ? const Color(0xFF4CAF50) : _activeColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1810).withAlpha(20),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < letters.length; i++)
              Container(
                width: tileWidth,
                height: tileHeight,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isTargetWord
                        ? [
                            const Color(0xFFE8F5E9),
                            const Color(0xFFC8E6C9),
                          ]
                        : [
                            const Color(0xFFFFFDF5),
                            const Color(0xFFFFF9E6),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: tileBorderColor,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: tileGlowColor.withAlpha(90),
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                    BoxShadow(
                      color: const Color(0xFF2A1810).withAlpha(30),
                      blurRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    letters[i],
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: fontSize,
                      fontWeight: FontWeight.w900,
                      color: isTargetWord ? const Color(0xFF1B5E20) : const Color(0xFF2A1810),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
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
