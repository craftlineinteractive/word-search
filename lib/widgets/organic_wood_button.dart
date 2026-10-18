import 'package:flutter/material.dart';
import '../services/sound_manager.dart';

enum WoodButtonVariant {
  primary, // Vibrant Golden Honey / Forest Green Play CTA
  secondary, // Carved Warm Oak Wood Plank
  forest, // Emerald Foliage Tone
  parchment, // Light Antique Wood / Cream
}

class OrganicWoodButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final String? text;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final double? width;
  final double height;
  final WoodButtonVariant variant;
  final double fontSize;
  final double borderRadius;
  final bool enabled;

  const OrganicWoodButton({
    super.key,
    required this.onPressed,
    this.child,
    this.text,
    this.icon,
    this.leading,
    this.trailing,
    this.width,
    this.height = 54.0,
    this.variant = WoodButtonVariant.primary,
    this.fontSize = 17.0,
    this.borderRadius = 16.0,
    this.enabled = true,
  });

  @override
  State<OrganicWoodButton> createState() => _OrganicWoodButtonState();
}

class _OrganicWoodButtonState extends State<OrganicWoodButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // 2D Cartoon Game Color Schemes with Cel Shading
    final List<Color> surfaceGradient;
    final Color bevelLight;
    final Color bevelShadow;
    final Color textColor;
    const Color strokeDark = Color(0xFF2A1810); // 2D Cartoon Dark Chocolate Ink

    switch (widget.variant) {
      case WoodButtonVariant.primary:
        surfaceGradient = const [
          Color(0xFFFFC107), // Vibrant Amber Top
          Color(0xFFF59E0B),
          Color(0xFFD97706), // Deep Golden Honey
        ];
        bevelLight = const Color(0xFFFFE082);
        bevelShadow = const Color(0xFF92400E);
        textColor = const Color(0xFF2A1810);
        break;

      case WoodButtonVariant.forest:
        surfaceGradient = const [
          Color(0xFF22C55E), // Lush Meadow Top
          Color(0xFF16A34A),
          Color(0xFF15803D), // Deep Emerald Wood
        ];
        bevelLight = const Color(0xFF86EFAC);
        bevelShadow = const Color(0xFF14532D);
        textColor = Colors.white;
        break;

      case WoodButtonVariant.secondary:
        surfaceGradient = const [
          Color(0xFFB45309), // Carved Oak Top
          Color(0xFF8B4513),
          Color(0xFF6B3A0E), // Deep Walnut
        ];
        bevelLight = const Color(0xFFD97706);
        bevelShadow = const Color(0xFF451A03);
        textColor = const Color(0xFFFFFBEB);
        break;

      case WoodButtonVariant.parchment:
        surfaceGradient = const [
          Color(0xFFFEF3C7), // Antique Cream
          Color(0xFFFDE68A),
          Color(0xFFF59E0B),
        ];
        bevelLight = const Color(0xFFFFFDF5);
        bevelShadow = const Color(0xFFB45309);
        textColor = const Color(0xFF2A1810);
        break;
    }

    final double depthOffset = _isPressed ? 1.0 : 4.5;
    final double buttonHeight = widget.height;

    return Semantics(
      button: true,
      enabled: widget.enabled && widget.onPressed != null,
      label: widget.text,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          splashFactory: NoSplash.splashFactory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
        onPressed: widget.enabled && widget.onPressed != null
            ? () {
                SoundManager.instance.playButtonClick();
                widget.onPressed!();
              }
            : null,
        child: Listener(
          onPointerDown: (_) {
            if (widget.enabled) setState(() => _isPressed = true);
          },
          onPointerUp: (_) {
            if (widget.enabled) setState(() => _isPressed = false);
          },
          onPointerCancel: (_) {
            if (widget.enabled) setState(() => _isPressed = false);
          },
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: widget.enabled ? 1.0 : 0.55,
            child: SizedBox(
              width: widget.width,
            height: buttonHeight + 5.0, // extra room for 3D bottom bevel
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Bottom Drop Bevel (The 3D Wood Thickness)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 5.0,
                  height: buttonHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: bevelShadow,
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      border: Border.all(
                        color: strokeDark,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: strokeDark.withAlpha(90),
                          blurRadius: 6.0,
                          offset: const Offset(0, 3.5),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Front Interactive Plank (Compresses down on tap)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 60),
                  curve: Curves.easeOutQuad,
                  left: 0,
                  right: 0,
                  top: depthOffset,
                  height: buttonHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: surfaceGradient,
                      ),
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      border: Border.all(
                        color: strokeDark,
                        width: 2.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.borderRadius - 2.5),
                      child: Stack(
                        children: [
                          // Top 45-degree volumetric light rim
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: buttonHeight * 0.42,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    bevelLight.withAlpha(140),
                                    bevelLight.withAlpha(0),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Subtle Wood Grain Texture Rings
                          CustomPaint(
                            size: Size(widget.width ?? double.infinity, buttonHeight),
                            painter: _WoodGrainPainter(bevelShadow.withAlpha(25)),
                          ),

                          // Button Content (Icons, Text, Custom Widget)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: widget.child ??
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (widget.leading != null) ...[
                                          widget.leading!,
                                          const SizedBox(width: 6),
                                        ] else if (widget.icon != null) ...[
                                          Icon(
                                            widget.icon,
                                            color: textColor,
                                            size: widget.fontSize * 1.25,
                                          ),
                                          const SizedBox(width: 6),
                                        ],
                                        if (widget.text != null)
                                          Text(
                                            widget.text!,
                                            style: TextStyle(
                                              fontFamily: 'Fredoka',
                                              fontSize: widget.fontSize,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                              letterSpacing: 0.6,
                                              shadows: [
                                                Shadow(
                                                  color: widget.variant == WoodButtonVariant.secondary ||
                                                          widget.variant == WoodButtonVariant.forest
                                                      ? strokeDark.withAlpha(160)
                                                      : bevelLight.withAlpha(180),
                                                  offset: const Offset(0, 1.2),
                                                  blurRadius: 1.0,
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (widget.trailing != null) ...[
                                          const SizedBox(width: 6),
                                          widget.trailing!,
                                        ],
                                      ],
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

/// Lightweight subtle wood grain lines drawn on canvas (0 KB memory)
class _WoodGrainPainter extends CustomPainter {
  final Color grainColor;

  const _WoodGrainPainter(this.grainColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = grainColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.15,
        size.width * 0.5,
        size.height * 0.35,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.55,
        size.width,
        size.height * 0.3,
      );

    final path2 = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.85,
        size.width * 0.7,
        size.height * 0.65,
      )
      ..lineTo(size.width, size.height * 0.7);

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _WoodGrainPainter oldDelegate) => false;
}
