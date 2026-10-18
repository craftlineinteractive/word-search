import 'package:flutter/material.dart';

class ParchmentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? borderColor;
  final List<Color>? gradientColors;
  final double borderWidth;
  final VoidCallback? onTap;

  const ParchmentCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.borderRadius = 20.0,
    this.borderColor,
    this.gradientColors,
    this.borderWidth = 2.5,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color strokeDark = Color(0xFF2A1810); // 2D Cartoon Dark Ink
    final colors = gradientColors ??
        const [
          Color(0xFFFFFDF8), // Light antique cream parchment
          Color(0xFFF9F3E5),
          Color(0xFFF2E6CD),
        ];

    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: colors.first,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? strokeDark,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: strokeDark.withAlpha(45),
            blurRadius: 8.0,
            offset: const Offset(0, 4.0),
          ),
          // Inner light bevel illusion
          BoxShadow(
            color: Colors.white.withAlpha(200),
            blurRadius: 0,
            offset: const Offset(0, -1.0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
            ),
          ),
          child: Stack(
            children: [
              // Subtle corner aesthetic rivets
              Positioned(
                top: 6,
                left: 6,
                child: _buildRivet(),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: _buildRivet(),
              ),
              Positioned(
                bottom: 6,
                left: 6,
                child: _buildRivet(),
              ),
              Positioned(
                bottom: 6,
                right: 6,
                child: _buildRivet(),
              ),

              // Content
              Padding(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }

  Widget _buildRivet() {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFB45309).withAlpha(120),
        border: Border.all(
          color: const Color(0xFF2A1810).withAlpha(100),
          width: 0.8,
        ),
      ),
    );
  }
}
