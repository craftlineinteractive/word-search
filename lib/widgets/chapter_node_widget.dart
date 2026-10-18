import 'package:flutter/material.dart';
import '../services/level_repository.dart';
import '../theme/app_theme.dart';

enum ChapterStatus { locked, active, completed }

/// Backward-compatible aliases for World terminology
typedef WorldStatus = ChapterStatus;
typedef WorldNodeWidget = ChapterNodeWidget;

class ChapterNodeWidget extends StatefulWidget {
  final ChapterMeta chapter;
  final ChapterStatus status;
  final int completedLevelsCount;
  final int totalLevelsCount;
  final int requiredStars;
  final VoidCallback onTap;

  const ChapterNodeWidget({
    super.key,
    required this.chapter,
    required this.status,
    this.completedLevelsCount = 0,
    this.totalLevelsCount = 120,
    this.requiredStars = 0,
    required this.onTap,
  });

  @override
  State<ChapterNodeWidget> createState() => _ChapterNodeWidgetState();
}

class _ChapterNodeWidgetState extends State<ChapterNodeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: -7.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.status == ChapterStatus.active) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ChapterNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == ChapterStatus.active) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLocked = widget.status == ChapterStatus.locked;
    final bool isActive = widget.status == ChapterStatus.active;
    final bool isCompleted = widget.status == ChapterStatus.completed;
    final Color textPrimary = AppTheme.getTextPrimaryColor(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active Marker Pin ("PLAY")
          if (isActive)
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceAnimation.value),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD54F), Color(0xFFFF9800)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF5D4037), width: 1.8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3E2723).withAlpha(120),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded, color: Color(0xFF2A1810), size: 14),
                        SizedBox(width: 2),
                        Text(
                          'PLAY',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2A1810),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // Main Floating World Node Pedestal
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Pulsing Outer Sunlight Glow for Active Node
              if (isActive)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFD54F).withAlpha(45),
                          border: Border.all(
                            color: const Color(0xFFFFB300).withAlpha(180),
                            width: 2.2,
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // Carved Wood Outer Pedestal
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLocked
                      ? const Color(0xFF78909C)
                      : isCompleted
                          ? const Color(0xFFFFA000)
                          : const Color(0xFF5D4037),
                  border: Border.all(
                    color: isLocked
                        ? const Color(0xFF455A64)
                        : const Color(0xFF3E2723),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2A1810).withAlpha(100),
                      blurRadius: isActive ? 12 : 7,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFFDF5),
                      border: Border.all(
                        color: const Color(0xFFD7CCC8),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // World Category Image
                          Opacity(
                            opacity: isLocked ? 0.35 : 1.0,
                            child: Image.asset(
                              widget.chapter.iconAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Center(
                                child: Icon(
                                  Icons.landscape_rounded,
                                  color: textPrimary,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),

                          // Locked Iron Padlock Overlay
                          if (isLocked)
                            Container(
                              color: Colors.black.withAlpha(110),
                              child: const Center(
                                child: Icon(
                                  Icons.lock_rounded,
                                  color: Color(0xFFFFF9E6),
                                  size: 26,
                                ),
                              ),
                            ),

                          // Completed Golden Seal Badge
                          if (isCompleted)
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E676),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF2E7D32), width: 1.5),
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // World Number Badge (Wood Token on Top Left)
              Positioned(
                top: -3,
                left: -3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isLocked
                          ? const [Color(0xFF78909C), Color(0xFF546E7A)]
                          : const [Color(0xFFFFB300), Color(0xFFE65100)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFFDF5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2A1810).withAlpha(70),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${widget.chapter.id}',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Parchment Plaque for World Title
          Container(
            constraints: const BoxConstraints(minWidth: 70, maxWidth: 132),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive
                    ? const Color(0xFFE65100)
                    : isCompleted
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF8D6E63),
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2A1810).withAlpha(40),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.chapter.title,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  color: isLocked
                      ? const Color(0xFF8D6E63)
                      : const Color(0xFF2A1810),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 3),

          // Progress Stars / Lock Info
          FittedBox(
            fit: BoxFit.scaleDown,
            child: isLocked
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFB300)),
                      const SizedBox(width: 2),
                      Text(
                        '${widget.requiredStars}',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          color: Color(0xFF6D4C41),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: isCompleted
                            ? const Color(0xFFFFB300)
                            : const Color(0xFF8D6E63),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${widget.completedLevelsCount}/${widget.totalLevelsCount}',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          color: Color(0xFF4E342E),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
