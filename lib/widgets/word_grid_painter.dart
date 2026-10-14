import 'package:flutter/material.dart';
import '../models/grid_coordinate.dart';
import '../models/placed_word.dart';

class WordGridPainter extends CustomPainter {
  static const double gridPadding = 8.0;

  final List<List<String>> grid;
  final List<PlacedWord> foundWords;
  final List<GridCoordinate>? activeSelection;
  final Color activeSelectionColor;
  final GridCoordinate? hintCoordinate;
  final double hintAnimationValue;
  final bool isDark;

  WordGridPainter({
    required this.grid,
    required this.foundWords,
    this.activeSelection,
    this.activeSelectionColor = const Color(0xFFFFD740),
    this.hintCoordinate,
    this.hintAnimationValue = 0.0,
    this.isDark = true,
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
    final cellBgPaint = Paint()
      ..color = isDark ? const Color(0xFF262D3D).withAlpha(150) : const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;

    final cellBorderPaint = Paint()
      ..color = isDark ? const Color(0xFF3F4A63).withAlpha(120) : const Color(0xFFE2E8F0)
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
        color: Color(found.colorValue).withAlpha(isDark ? 150 : 135),
        borderColor: Color(found.colorValue).withAlpha(isDark ? 210 : 190),
      );
    }

    // 4. Draw Active Drag Selection Capsule
    if (activeSelection != null && activeSelection!.isNotEmpty) {
      _drawCapsuleHighlight(
        canvas: canvas,
        coordinates: activeSelection!,
        cellWidth: cellWidth,
        cellHeight: cellHeight,
        color: activeSelectionColor.withAlpha(isDark ? 130 : 110),
        borderColor: activeSelectionColor.withAlpha(isDark ? 220 : 190),
      );
    }

    // 5. Render Cell Letters
    final double fontSize = _calculateFontSize(cellWidth, cellHeight);
    final standardTextStyle = TextStyle(
      color: isDark ? Colors.white : const Color(0xFF0F172A),
      fontSize: 18,
      fontWeight: FontWeight.w700,
      fontFamily: 'Fredoka',
    );

    const hintLetterTextStyle = TextStyle(
      color: Color(0xFF0F172A), // Dark obsidian for maximum contrast over bright yellow hint
      fontSize: 18,
      fontWeight: FontWeight.w900,
      fontFamily: 'Fredoka',
    );

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final isHintCell = (hintCoordinate != null && hintCoordinate!.row == r && hintCoordinate!.col == c);
        final style = isHintCell
            ? hintLetterTextStyle.copyWith(fontSize: fontSize * 1.05)
            : standardTextStyle.copyWith(fontSize: fontSize);

        final textSpan = TextSpan(
          text: grid[r][c],
          style: style,
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout();

        final double x = gridPadding + c * cellWidth + (cellWidth - textPainter.width) / 2;
        final double y = gridPadding + r * cellHeight + (cellHeight - textPainter.height) / 2;

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

    final double radius = cellWidth * 0.40;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (coordinates.length == 1) {
      final c = coordinates.first;
      final center = Offset(
        gridPadding + c.col * cellWidth + cellWidth / 2,
        gridPadding + c.row * cellHeight + cellHeight / 2,
      );
      canvas.drawCircle(center, radius, fillPaint);
      canvas.drawCircle(center, radius, borderPaint);
      return;
    }

    final first = coordinates.first;
    final last = coordinates.last;
    final start = Offset(
      gridPadding + first.col * cellWidth + cellWidth / 2,
      gridPadding + first.row * cellHeight + cellHeight / 2,
    );
    final end = Offset(
      gridPadding + last.col * cellWidth + cellWidth / 2,
      gridPadding + last.row * cellHeight + cellHeight / 2,
    );

    final lineFillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 2
      ..strokeCap = StrokeCap.round;

    final lineBorderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 2 + 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, lineBorderPaint);
    canvas.drawLine(start, end, lineFillPaint);
  }

  double _calculateFontSize(double cellW, double cellH) {
    final double minDim = cellW < cellH ? cellW : cellH;
    return (minDim * 0.52).clamp(12.0, 24.0);
  }

  @override
  bool shouldRepaint(covariant WordGridPainter oldDelegate) {
    return oldDelegate.grid != grid ||
        oldDelegate.foundWords != foundWords ||
        oldDelegate.activeSelection != activeSelection ||
        oldDelegate.activeSelectionColor != activeSelectionColor ||
        oldDelegate.hintCoordinate != hintCoordinate ||
        oldDelegate.hintAnimationValue != hintAnimationValue ||
        oldDelegate.isDark != isDark;
  }
}
