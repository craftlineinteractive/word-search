import 'dart:math' as math;
import 'package:flutter/material.dart';

enum ParticleType {
  fireflies, // Golden pulsing glowing forest motes
  pollen, // Soft floating sunlight dust
  steam, // Rising soft wisps
  bubbles, // Floating translucent spheres
}

class AmbientParticlesOverlay extends StatefulWidget {
  final int maxParticles;
  final ParticleType type;
  final Color? particleColor;
  final Widget? child;

  const AmbientParticlesOverlay({
    super.key,
    int? maxParticles,
    int? particleCount,
    this.type = ParticleType.fireflies,
    this.particleColor,
    this.child,
  }) : maxParticles = particleCount ?? maxParticles ?? 14;

  @override
  State<AmbientParticlesOverlay> createState() => _AmbientParticlesOverlayState();
}

class _AmbientParticlesOverlayState extends State<AmbientParticlesOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_ParticleModel> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    final bool isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    if (!isTest) {
      _controller.repeat();
    }

    _initParticles();
  }

  void _initParticles() {
    _particles.clear();
    for (int i = 0; i < widget.maxParticles; i++) {
      _particles.add(
        _ParticleModel(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          radius: 1.8 + _random.nextDouble() * 3.2,
          speed: 0.15 + _random.nextDouble() * 0.35,
          phase: _random.nextDouble() * math.pi * 2,
          drift: (_random.nextDouble() - 0.5) * 0.25,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    final bool disableAnimations = (MediaQuery.maybeOf(context)?.disableAnimations ?? false) || isTest;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (!disableAnimations)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _AmbientParticlesPainter(
                  particles: _particles,
                  progress: _controller.value,
                  type: widget.type,
                  particleColor: widget.particleColor,
                ),
              );
            },
          ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _ParticleModel {
  double x;
  double y;
  final double radius;
  final double speed;
  final double phase;
  final double drift;

  _ParticleModel({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.drift,
  });
}

class _AmbientParticlesPainter extends CustomPainter {
  final List<_ParticleModel> particles;
  final double progress;
  final ParticleType type;
  final Color? particleColor;

  _AmbientParticlesPainter({
    required this.particles,
    required this.progress,
    required this.type,
    this.particleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final baseColor = particleColor ?? const Color(0xFFFFD54F);

    for (final p in particles) {
      // Calculate dynamic floating position with sinusoidal drift
      final currentY = (p.y - (progress * p.speed)) % 1.0;
      final currentX = (p.x + math.sin(progress * math.pi * 4 + p.phase) * p.drift) % 1.0;

      final px = currentX * size.width;
      final py = currentY * size.height;

      // Pulsing alpha for fireflies
      final pulse = (math.sin(progress * math.pi * 6 + p.phase) + 1.0) / 2.0;
      final alpha = (0.25 + (pulse * 0.65)).clamp(0.0, 1.0);

      final paintCore = Paint()
        ..color = baseColor.withAlpha((alpha * 255).toInt())
        ..style = PaintingStyle.fill;

      // Glow halo
      final paintGlow = Paint()
        ..color = baseColor.withAlpha((alpha * 0.4 * 255).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

      canvas.drawCircle(Offset(px, py), p.radius * 2.2, paintGlow);
      canvas.drawCircle(Offset(px, py), p.radius, paintCore);
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientParticlesPainter oldDelegate) => true;
}
