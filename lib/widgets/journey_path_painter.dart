import 'package:flutter/material.dart';

class JourneyPathPainter extends CustomPainter {
  final List<Offset> nodePositions;
  final int activeChapterIndex;
  final double roadWidth;
  final bool isDark;

  const JourneyPathPainter({
    required this.nodePositions,
    required this.activeChapterIndex,
    this.roadWidth = 14.0,
    this.isDark = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePositions.length < 2) return;

    // 1. Glowing outer ambient trail for completed / active path
    final Paint glowPaint = Paint()
      ..color = (isDark ? const Color(0xFF00E676) : const Color(0xFF10B981)).withAlpha(isDark ? 60 : 40)
      ..strokeWidth = roadWidth + 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint completedRoadPaint = Paint()
      ..color = isDark ? const Color(0xFF1E88E5) : const Color(0xFF3B82F6)
      ..strokeWidth = roadWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint lockedRoadPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)
      ..strokeWidth = roadWidth - 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint centerDashedPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 2.5
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
        // Glowing halo + Unlocked Road
        canvas.drawPath(segmentPath, glowPaint);
        canvas.drawPath(segmentPath, completedRoadPaint);
        _drawDashedPath(canvas, segmentPath, centerDashedPaint, dashLength: 8.0, gapLength: 6.0);
      } else {
        // Dimmed / Locked Road
        canvas.drawPath(segmentPath, lockedRoadPaint);
      }

      // Draw stepping stone dots along curve
      _drawSteppingStones(canvas, p1, p2, isSegmentUnlocked);
    }
  }

  void _drawSteppingStones(Canvas canvas, Offset p1, Offset p2, bool isUnlocked) {
    final stonePaint = Paint()
      ..color = isUnlocked
          ? const Color(0xFFFFD700).withAlpha(200)
          : (isDark ? const Color(0xFF334155) : const Color(0xFF94A3B8))
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

      canvas.drawCircle(Offset(x, y), isUnlocked ? 3.5 : 2.5, stonePaint);
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
