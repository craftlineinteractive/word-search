import 'package:flutter/material.dart';

/// Renders a storybook woodland cobblestone trail connecting all 30 World nodes.
/// Employs smooth cubic Bezier curves, textured flagstones, and ambient sunlight
/// glows along completed path segments.
class JourneyPathPainter extends CustomPainter {
  final List<Offset> nodePositions;
  final int activeChapterIndex;
  final double roadWidth;
  final bool isDark;

  const JourneyPathPainter({
    required this.nodePositions,
    required this.activeChapterIndex,
    this.roadWidth = 16.0,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePositions.length < 2) return;

    // Outer glow for unlocked journey
    final Paint glowPaint = Paint()
      ..color = const Color(0xFFFFD54F).withAlpha(85)
      ..strokeWidth = roadWidth + 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Trail border (dark bark brown for storybook outline)
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..strokeWidth = roadWidth + 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Unlocked cobblestone road fill (warm cream/terracotta cobblestone)
    final Paint unlockedRoadPaint = Paint()
      ..color = const Color(0xFFFFE082)
      ..strokeWidth = roadWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Locked road border (muted earthen stroke)
    final Paint lockedBorderPaint = Paint()
      ..color = const Color(0xFF795548).withAlpha(150)
      ..strokeWidth = roadWidth + 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Locked road fill (rustic dirt trail)
    final Paint lockedRoadPaint = Paint()
      ..color = const Color(0xFFD7CCC8)
      ..strokeWidth = roadWidth - 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Center cobblestone highlight dash
    final Paint centerDashedPaint = Paint()
      ..color = const Color(0xFFFFF8E1)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < nodePositions.length - 1; i++) {
      final p1 = nodePositions[i];
      final p2 = nodePositions[i + 1];

      final Path segmentPath = Path();
      segmentPath.moveTo(p1.dx, p1.dy);

      // Smooth vertical cubic Bezier curve
      final double dy = (p2.dy - p1.dy).abs();
      final Offset c1 = Offset(p1.dx, p1.dy - dy * 0.5);
      final Offset c2 = Offset(p2.dx, p2.dy + dy * 0.5);

      segmentPath.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);

      final bool isSegmentUnlocked = i < activeChapterIndex;

      if (isSegmentUnlocked) {
        // Glowing sunlight halo + border + warm path
        canvas.drawPath(segmentPath, glowPaint);
        canvas.drawPath(segmentPath, borderPaint);
        canvas.drawPath(segmentPath, unlockedRoadPaint);
        _drawDashedPath(canvas, segmentPath, centerDashedPaint, dashLength: 10.0, gapLength: 8.0);
      } else {
        // Rustic earthen trail with soft border
        canvas.drawPath(segmentPath, lockedBorderPaint);
        canvas.drawPath(segmentPath, lockedRoadPaint);
      }

      // Draw stepping stone dots along curve
      _drawSteppingStones(canvas, p1, p2, isSegmentUnlocked);
    }
  }

  void _drawSteppingStones(Canvas canvas, Offset p1, Offset p2, bool isUnlocked) {
    final stoneShadowPaint = Paint()
      ..color = const Color(0xFF3E2723).withAlpha(80)
      ..style = PaintingStyle.fill;

    final stonePaint = Paint()
      ..color = isUnlocked
          ? const Color(0xFFFFB300)
          : const Color(0xFF8D6E63)
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha(isUnlocked ? 160 : 70)
      ..style = PaintingStyle.fill;

    // 3 intermediate stepping stones between nodes
    for (double t = 0.25; t <= 0.75; t += 0.25) {
      final double dy = (p2.dy - p1.dy).abs();
      final Offset c1 = Offset(p1.dx, p1.dy - dy * 0.5);
      final Offset c2 = Offset(p2.dx, p2.dy + dy * 0.5);

      final double u = 1 - t;
      final double tt = t * t;
      final double uu = u * u;
      final double uuu = uu * u;
      final double ttt = tt * t;

      final double x = uuu * p1.dx + 3 * uu * t * c1.dx + 3 * u * tt * c2.dx + ttt * p2.dx;
      final double y = uuu * p1.dy + 3 * uu * t * c1.dy + 3 * u * tt * c2.dy + ttt * p2.dy;

      final center = Offset(x, y);
      final radius = isUnlocked ? 4.5 : 3.5;

      // Drop shadow
      canvas.drawCircle(center.translate(0, 1.5), radius, stoneShadowPaint);
      // Main stone
      canvas.drawCircle(center, radius, stonePaint);
      // Subtle top highlight
      canvas.drawCircle(center.translate(-1, -1), radius * 0.4, highlightPaint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path sourcePath, Paint paint, {required double dashLength, required double gapLength}) {
    final pathMetrics = sourcePath.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = draw ? dashLength : gapLength;
        if (draw) {
          final Path extract = metric.extractPath(distance, (distance + len).clamp(0.0, metric.length));
          canvas.drawPath(extract, paint);
        }
        distance += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant JourneyPathPainter oldDelegate) {
    return oldDelegate.activeChapterIndex != activeChapterIndex ||
        oldDelegate.roadWidth != roadWidth ||
        oldDelegate.nodePositions != nodePositions ||
        oldDelegate.isDark != isDark;
  }
}
