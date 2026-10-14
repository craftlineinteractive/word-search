import 'package:flutter/material.dart';
import '../services/level_repository.dart';
import '../theme/app_theme.dart';

enum ChapterStatus { locked, active, completed }

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
    this.totalLevelsCount = 35,
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
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: -6.0).animate(
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
    final bool isDark = AppTheme.isDark(context);
    final Color textPrimary = AppTheme.getTextPrimaryColor(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active Player Pin Marker ("PLAY")
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
                        colors: [Color(0xFFFFD700), Color(0xFFFF9100)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9100).withAlpha(150),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 2),
                        Text(
                          'PLAY',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // Main Floating Island Node
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Pulsing Outer Glow Ring for Active Node
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
                          color: (isDark ? const Color(0xFF00E676) : const Color(0xFF10B981)).withAlpha(isDark ? 40 : 25),
                          border: Border.all(
                            color: (isDark ? const Color(0xFF00E676) : const Color(0xFF10B981)).withAlpha(180),
                            width: 2.0,
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // Island Pedestal Container
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isLocked
                        ? (isDark
                            ? const [Color(0xFF1E293B), Color(0xFF0F172A)]
                            : const [Color(0xFFE2E8F0), Color(0xFFCBD5E1)])
                        : isActive
                            ? const [Color(0xFF00E676), Color(0xFF00B0FF)]
                            : const [Color(0xFFFFD700), Color(0xFFFF9100)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isLocked
                          ? Colors.black.withAlpha(isDark ? 90 : 20)
                          : isActive
                              ? const Color(0xFF00E676).withAlpha(120)
                              : const Color(0xFFFFD700).withAlpha(100),
                      blurRadius: isActive ? 16 : 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF0B192C) : Colors.white,
                      border: Border.all(
                        color: isLocked
                            ? (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))
                            : Colors.white.withAlpha(80),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Category Image
                          Opacity(
                            opacity: isLocked ? 0.35 : 1.0,
                            child: Image.asset(
                              widget.chapter.iconAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Center(
                                child: Icon(
                                  Icons.grid_view_rounded,
                                  color: textPrimary,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),

                          // Locked Padlock Overlay
                          if (isLocked)
                            Container(
                              color: Colors.black.withAlpha(isDark ? 140 : 100),
                              child: const Center(
                                child: Icon(
                                  Icons.lock_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ),

                          // Completed Golden Checkmark
                          if (isCompleted)
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00E676),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Chapter Number Badge on Top Left
              Positioned(
                top: -4,
                left: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isLocked
                        ? (isDark ? const Color(0xFF334155) : const Color(0xFF64748B))
                        : const Color(0xFF0288D1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 80 : 30),
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
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Chapter Title Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A).withAlpha(230) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? const Color(0xFF00E676)
                    : isCompleted
                        ? const Color(0xFFFFD700)
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 40 : 10),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.chapter.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Fredoka',
                color: isLocked
                    ? (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))
                    : textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
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
                        '${widget.requiredStars} ⭐',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
                            ? const Color(0xFFFFD700)
                            : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${widget.completedLevelsCount}/${widget.totalLevelsCount}',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
