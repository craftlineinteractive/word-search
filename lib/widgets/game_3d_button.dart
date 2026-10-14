import 'package:flutter/material.dart';
import '../services/sound_manager.dart';

enum Game3dButtonColor {
  gold,
  green,
  blue,
  orange,
  red,
  purple,
  glass,
}

class Game3dButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final String? text;
  final IconData? icon;
  final Game3dButtonColor color;
  final double height;
  final double? width;
  final double depth;
  final double borderRadius;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;

  const Game3dButton({
    super.key,
    this.onPressed,
    this.child,
    this.text,
    this.icon,
    this.color = Game3dButtonColor.gold,
    this.height = 54,
    this.width,
    this.depth = 4.0,
    this.borderRadius = 16.0,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  State<Game3dButton> createState() => _Game3dButtonState();
}

class _Game3dButtonState extends State<Game3dButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  ({Color top, Color bottom, Color shadow, Color text}) _getColorPalette() {
    switch (widget.color) {
      case Game3dButtonColor.gold:
        return (
          top: const Color(0xFFFFD54F),
          bottom: const Color(0xFFFF8F00),
          shadow: const Color(0xFFC67100),
          text: const Color(0xFF3E2723),
        );
      case Game3dButtonColor.green:
        return (
          top: const Color(0xFF10B981),
          bottom: const Color(0xFF059669),
          shadow: const Color(0xFF047857),
          text: Colors.white,
        );
      case Game3dButtonColor.blue:
        return (
          top: const Color(0xFF3B82F6),
          bottom: const Color(0xFF2563EB),
          shadow: const Color(0xFF1D4ED8),
          text: Colors.white,
        );
      case Game3dButtonColor.orange:
        return (
          top: const Color(0xFFF97316),
          bottom: const Color(0xFFEA580C),
          shadow: const Color(0xFFC2410C),
          text: Colors.white,
        );
      case Game3dButtonColor.red:
        return (
          top: const Color(0xFFEF4444),
          bottom: const Color(0xFFDC2626),
          shadow: const Color(0xFFB91C1C),
          text: Colors.white,
        );
      case Game3dButtonColor.purple:
        return (
          top: const Color(0xFFA855F7),
          bottom: const Color(0xFF9333EA),
          shadow: const Color(0xFF7E22CE),
          text: Colors.white,
        );
      case Game3dButtonColor.glass:
        return (
          top: const Color(0xFF3B465E),
          bottom: const Color(0xFF2C3547),
          shadow: const Color(0xFF1E2430),
          text: Colors.white,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _getColorPalette();
    final effectiveDepth = _isPressed ? 1.0 : widget.depth;
    final translateY = _isPressed ? widget.depth - 1.0 : 0.0;

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressed = true);
          SoundManager.instance.playButtonClick();
        }
      },
      onTapUp: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressed = false);
          widget.onPressed!();
        }
      },
      onTapCancel: () {
        if (_isPressed) {
          setState(() => _isPressed = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: widget.width,
        height: widget.height,
        margin: EdgeInsets.only(top: translateY, bottom: widget.depth - translateY),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.top, palette.bottom],
          ),
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              offset: Offset(0, effectiveDepth),
              blurRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withAlpha(40),
              offset: Offset(0, effectiveDepth + 2),
              blurRadius: 4,
            ),
          ],
        ),
        padding: widget.padding,
        child: Center(
          child: widget.child ??
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: palette.text, size: 22),
                    const SizedBox(width: 8),
                  ],
                  if (widget.text != null)
                    Text(
                      widget.text!,
                      style: widget.textStyle ??
                          TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: palette.text,
                            shadows: [
                              Shadow(
                                color: Colors.white.withAlpha(50),
                                offset: const Offset(0, 1),
                                blurRadius: 1,
                              ),
                            ],
                          ),
                    ),
                ],
              ),
        ),
      ),
    );
  }
}
