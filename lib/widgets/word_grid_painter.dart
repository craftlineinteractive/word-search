import 'package:flutter/material.dart';
import '../models/grid_coordinate.dart';
import '../models/placed_word.dart';
import '../theme/world_theme.dart';

class WordGridPainter extends CustomPainter {
  static const double gridPadding = 8.0;

  final List<List<String>> grid;
  final List<PlacedWord> foundWords;
  final List<GridCoordinate>? activeSelection;
  final Color activeSelectionColor;
  final GridCoordinate? hintCoordinate;
  final double hintAnimationValue;
  final bool isDark;
  final WorldTheme? worldTheme;

  WordGridPainter({
    required this.grid,
    required this.foundWords,
    this.activeSelection,
    this.activeSelectionColor = const Color(0xFFFFD740),
    this.hintCoordinate,
    this.hintAnimationValue = 0.0,
    this.isDark = false,
    this.worldTheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (grid.isEmpty || grid[0].isEmpty) return;

    final int rows = grid.length;
    final int cols = grid[0].length;
    final double innerWidth = size.width - gridPadding * 2;
    final double innerHeight = size.height - gridPadding * 2;
    final double cellWidth = innerWidth / cols;
    final double cellHeight = innerHeight / rows;

    // 1. Draw subtle grid background cells with symmetrical padding
    final cellBgColor = worldTheme?.cellBackgroundColor ??
        (isDark ? const Color(0xFF262D3D).withAlpha(150) : const Color(0xFFF1F5F9));
    final cellBorderColor = worldTheme != null
        ? worldTheme!.gridBorderColor.withAlpha(90)
        : (isDark ? const Color(0xFF3F4A63).withAlpha(120) : const Color(0xFFE2E8F0));

    final cellBgPaint = Paint()
      ..color = cellBgColor
      ..style = PaintingStyle.fill;

    final cellBorderPaint = Paint()
      ..color = cellBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            gridPadding + c * cellWidth + 1.5,
            gridPadding + r * cellHeight + 1.5,
            cellWidth - 3,
            cellHeight - 3,
          ),
          const Radius.circular(8),
        );
        canvas.drawRRect(rect, cellBgPaint);
        canvas.drawRRect(rect, cellBorderPaint);
      }
    }

    // 2. Draw Radiant Animated Hint Beacon
    if (hintCoordinate != null) {
      final c = hintCoordinate!.col;
      final r = hintCoordinate!.row;
      final center = Offset(
        gridPadding + c * cellWidth + cellWidth / 2,
        gridPadding + r * cellHeight + cellHeight / 2,
      );
      final baseRadius = cellWidth * 0.44;

      // Outer expanding radar pulse wave
      final double waveRadius = baseRadius + (hintAnimationValue * cellWidth * 0.40);
      final int waveAlpha = (180 * (1.0 - hintAnimationValue)).clamp(0, 180).toInt();
      final pulsePaint = Paint()
        ..color = const Color(0xFFFFD700).withAlpha(waveAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(center, waveRadius, pulsePaint);

      // Glowing halo layer
      final haloPaint = Paint()
        ..color = const Color(0xFFFF9100).withAlpha(160)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, baseRadius * 1.15, haloPaint);

      // Core Solid Glowing Yellow/Gold Spotlight
      final corePaint = Paint()
        ..shader = RadialGradient(
          colors: const [
            Color(0xFFFFF176), // Bright sunburst center
            Color(0xFFFFD700), // Gold
            Color(0xFFFF9100), // Amber edge
          ],
          stops: const [0.0, 0.65, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: baseRadius))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, baseRadius, corePaint);

      // Outer illuminated border ring
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(center, baseRadius, borderPaint);
    }

    // 3. Draw Completed / Found Words Highlight Capsules
    for (final found in foundWords) {
      if (found.coordinates.isEmpty) continue;
      _drawCapsuleHighlight(
        canvas: canvas,
        coordinates: found.coordinates,
        cellWidth: cellWidth,
        cellHeight: cellHeight,
        color: Color(found.colorValue).withAlpha(140),
        borderColor: Color(found.colorValue).withAlpha(210),
      );
    }

    // 4. Draw Active Drag Selection Capsule
    if (activeSelection != null && activeSelection!.isNotEmpty) {
      _drawCapsuleHighlight(
        canvas: canvas,
        coordinates: activeSelection!,
        cellWidth: cellWidth,
        cellHeight: cellHeight,
        color: activeSelectionColor.withAlpha(130),
        borderColor: activeSelectionColor.withAlpha(220),
      );
    }

    // 5. Render Cell Letters
    final double fontSize = _calculateFontSize(cellWidth, cellHeight);
    final letterColor = worldTheme?.letterColor ??
        (isDark ? Colors.white : const Color(0xFF2A1810));

    final standardTextStyle = TextStyle(
      color: letterColor,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      fontFamily: 'Fredoka',
    );

    final hintLetterTextStyle = TextStyle(
      color: const Color(0xFF2A1810),
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      fontFamily: 'Fredoka',
    );

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final letter = grid[r][c];
        final isHint = hintCoordinate != null &&
            hintCoordinate!.row == r &&
            hintCoordinate!.col == c;

        final textPainter = TextPainter(
          text: TextSpan(
            text: letter,
            style: isHint ? hintLetterTextStyle : standardTextStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final x = gridPadding + c * cellWidth + (cellWidth - textPainter.width) / 2;
        final y = gridPadding + r * cellHeight + (cellHeight - textPainter.height) / 2;

        textPainter.paint(canvas, Offset(x, y));
      }
    }
  }

  void _drawCapsuleHighlight({
    required Canvas canvas,
    required List<GridCoordinate> coordinates,
    required double cellWidth,
    required double cellHeight,
    required Color color,
    required Color borderColor,
  }) {
    if (coordinates.isEmpty) return;

    final first = coordinates.first;
    final last = coordinates.last;

    final startCenter = Offset(
      gridPadding + first.col * cellWidth + cellWidth / 2,
      gridPadding + first.row * cellHeight + cellHeight / 2,
    );
    final endCenter = Offset(
      gridPadding + last.col * cellWidth + cellWidth / 2,
      gridPadding + last.row * cellHeight + cellHeight / 2,
    );

    final radius = cellWidth * 0.42;

    final fillPaint = Paint()
      ..color = color
      ..strokeWidth = radius * 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final borderStrokePaint = Paint()
      ..color = borderColor
      ..strokeWidth = radius * 2 + 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw border halo then inner fill
    canvas.drawLine(startCenter, endCenter, borderStrokePaint);
    canvas.drawLine(startCenter, endCenter, fillPaint);
  }

  double _calculateFontSize(double cellWidth, double cellHeight) {
    final minDim = cellWidth < cellHeight ? cellWidth : cellHeight;
    return (minDim * 0.52).clamp(14.0, 26.0);
  }

  @override
  bool shouldRepaint(covariant WordGridPainter oldDelegate) {
    return oldDelegate.grid != grid ||
        oldDelegate.foundWords != foundWords ||
        oldDelegate.activeSelection != activeSelection ||
        oldDelegate.activeSelectionColor != activeSelectionColor ||
        oldDelegate.hintCoordinate != hintCoordinate ||
        oldDelegate.hintAnimationValue != hintAnimationValue ||
        oldDelegate.isDark != isDark ||
        oldDelegate.worldTheme != worldTheme;
  }
}
