import 'dart:math';
import 'package:flutter/material.dart';

enum ConfettiShape { rectangle, circle, star, diamond }

class ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double rotation;
  double vRotation;
  double scale;
  double opacity;
  Color color;
  ConfettiShape shape;
  double swayOffset;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.vRotation,
    required this.scale,
    required this.opacity,
    required this.color,
    required this.shape,
    required this.swayOffset,
  });
}

class ConfettiCelebrationOverlay extends StatefulWidget {
  final Widget? child;
  final bool autoStart;
  final Duration duration;

  const ConfettiCelebrationOverlay({
    super.key,
    this.child,
    this.autoStart = true,
    this.duration = const Duration(milliseconds: 3000),
  });

  @override
  State<ConfettiCelebrationOverlay> createState() => _ConfettiCelebrationOverlayState();
}

class _ConfettiCelebrationOverlayState extends State<ConfettiCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();

  static const List<Color> _palette = [
    Color(0xFFFF5252), // Coral
    Color(0xFFFFD700), // Gold
    Color(0xFF00E676), // Mint
    Color(0xFF00E5FF), // Cyan
    Color(0xFFE040FB), // Magenta
    Color(0xFFFF9100), // Orange
    Color(0xFF7C4DFF), // Purple
    Color(0xFFFFFFFF), // White Sparkle
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addListener(() {
        _updateParticles();
        setState(() {});
      });

    if (widget.autoStart) {
      _startCelebration();
    }
  }

  void _startCelebration() {
    _particles.clear();
    // Spawn 75 confetti pieces
    for (int i = 0; i < 75; i++) {
      final shape = ConfettiShape.values[_random.nextInt(ConfettiShape.values.length)];
      final color = _palette[_random.nextInt(_palette.length)];
      final angle = _random.nextDouble() * pi * 2;
      final speed = _random.nextDouble() * 350 + 150;

      _particles.add(
        ConfettiParticle(
          x: 0.5, // Center normalized
          y: 0.35,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed - 250, // initial upward thrust
          rotation: _random.nextDouble() * pi * 2,
          vRotation: (_random.nextDouble() - 0.5) * 8,
          scale: _random.nextDouble() * 0.6 + 0.7,
          opacity: 1.0,
          color: color,
          shape: shape,
          swayOffset: _random.nextDouble() * pi * 2,
        ),
      );
    }
    _controller.forward(from: 0.0);
  }

  void _updateParticles() {
    final double dt = 1.0 / 60.0;
    const double gravity = 550.0;
    final double progress = _controller.value;

    for (var p in _particles) {
      p.vy += gravity * dt;
      p.x += (p.vx + sin(progress * 10 + p.swayOffset) * 40) * dt / 350.0;
      p.y += p.vy * dt / 600.0;
      p.rotation += p.vRotation * dt;

      // Fade out smoothly in the last 30% of animation
      if (progress > 0.7) {
        p.opacity = ((1.0 - progress) / 0.3).clamp(0.0, 1.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ConfettiPainter(particles: _particles),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      if (p.opacity <= 0.0) continue;

      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;

      final double px = p.x * size.width;
      final double py = p.y * size.height;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation);
      canvas.scale(p.scale, p.scale);

      switch (p.shape) {
        case ConfettiShape.rectangle:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(-6, -3, 12, 6),
              const Radius.circular(2),
            ),
            paint,
          );
          break;
        case ConfettiShape.circle:
          canvas.drawCircle(Offset.zero, 4.5, paint);
          break;
        case ConfettiShape.diamond:
          final path = Path()
            ..moveTo(0, -6)
            ..lineTo(4, 0)
            ..lineTo(0, 6)
            ..lineTo(-4, 0)
            ..close();
          canvas.drawPath(path, paint);
          break;
        case ConfettiShape.star:
          _drawStar(canvas, 5, 6, 3, paint);
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, int points, double outerRadius, double innerRadius, Paint paint) {
    final Path path = Path();
    final double step = pi / points;
    double angle = -pi / 2;

    for (int i = 0; i < points * 2; i++) {
      final double r = i.isEven ? outerRadius : innerRadius;
      final double x = cos(angle) * r;
      final double y = sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      angle += step;
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
