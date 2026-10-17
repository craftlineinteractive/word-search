import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/puzzle_level.dart';
import '../models/user_progress.dart';
import '../services/sound_manager.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_widget.dart';
import 'gameplay_screen.dart';

class ChapterLevelsScreen extends StatefulWidget {
  final Chapter chapter;

  const ChapterLevelsScreen({
    super.key,
    required this.chapter,
  });

  @override
  State<ChapterLevelsScreen> createState() => _ChapterLevelsScreenState();
}

class _ChapterLevelsScreenState extends State<ChapterLevelsScreen> {
  late UserProgress _userProgress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await UserProgress.load();
    if (mounted) {
      setState(() {
        _userProgress = progress;
        _isLoading = false;
      });
    }
  }

  Future<void> _onLevelTap(PuzzleLevel level, bool isUnlocked) async {
    if (!isUnlocked) {
      SoundManager.instance.playError();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete previous levels to unlock this level!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    SoundManager.instance.playButtonClick();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameplayScreen(
          chapter: widget.chapter,
          level: level,
        ),
      ),
    );

    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final textPrimary = AppTheme.getTextPrimaryColor(context);
    final textSecondary = AppTheme.getTextSecondaryColor(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF081226) : const Color(0xFFF8FAFC),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF00E676))),
      );
    }

    final completedCount = _userProgress.getCompletedLevelsCount(widget.chapter.id);
    final totalLevels = widget.chapter.levels.length;
    final chapterStars = completedCount * 3;
    final totalPossibleStars = totalLevels * 3;

    return Scaffold(
      body: Stack(
        children: [
          // Full Screen Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/chapter_map_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                color: isDark ? const Color(0xFF081226) : const Color(0xFFF8FAFC),
              ),
            ),
          ),
          // Subtle Tint Overlay for Readability
          Positioned.fill(
            child: Container(
              color: isDark ? Colors.black.withAlpha(80) : Colors.white.withAlpha(30),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 1. Top Header Bar
                _buildTopHeader(isDark, textPrimary),

                // 2. Chapter Overview Banner Card
                _buildChapterHeroBanner(
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  completedCount: completedCount,
                  totalLevels: totalLevels,
                  chapterStars: chapterStars,
                  totalPossibleStars: totalPossibleStars,
                ),

                const SizedBox(height: 12),

                // 3. Grid of Level Tiles
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 16, top: 4),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: widget.chapter.levels.length,
                      itemBuilder: (context, index) {
                        final level = widget.chapter.levels[index];
                        final isCompleted = _userProgress.isLevelCompleted(widget.chapter.id, level.levelNumber);
                        final isUnlocked = _userProgress.isLevelUnlocked(widget.chapter.id, level.levelNumber);

                        return _buildLevelTile(
                          level: level,
                          isCompleted: isCompleted,
                          isUnlocked: isUnlocked,
                          isDark: isDark,
                          textPrimary: textPrimary,
                        );
                      },
                    ),
                  ),
                ),

                // 4. Banner Ad at Bottom
                const BannerAdWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(bool isDark, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: isDark ? const Color(0xFF1E3A6D) : Colors.white,
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                SoundManager.instance.playButtonClick();
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
              ),
            ),
          ),
          Text(
            widget.chapter.title,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textPrimary,
              letterSpacing: 0.8,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3A6D) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFFFFD700) : const Color(0xFFFFB300),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 50 : 15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 4),
                Text(
                  '${_userProgress.coins}',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    color: textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterHeroBanner({
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required int completedCount,
    required int totalLevels,
    required int chapterStars,
    required int totalPossibleStars,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132347) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E3A6D) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Chapter Thumbnail
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF1E3A6D) : const Color(0xFFF1F5F9),
            ),
            child: ClipOval(
              child: Image.asset(
                widget.chapter.iconAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  Icons.grid_view_rounded,
                  size: 32,
                  color: textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Chapter Stats & Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'World ${widget.chapter.id} ($totalLevels Levels)',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
                        const SizedBox(width: 2),
                        Text(
                          '$chapterStars / $totalPossibleStars',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$completedCount of $totalLevels levels cleared',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: totalLevels > 0 ? (completedCount / totalLevels) : 0,
                    minHeight: 7,
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelTile({
    required PuzzleLevel level,
    required bool isCompleted,
    required bool isUnlocked,
    required bool isDark,
    required Color textPrimary,
  }) {
    Color tileBg;
    Color tileBorder;

    if (isCompleted) {
      tileBg = isDark ? const Color(0xFF00E676).withAlpha(40) : const Color(0xFFE8F5E9);
      tileBorder = const Color(0xFF00E676);
    } else if (isUnlocked) {
      tileBg = isDark ? const Color(0xFF1E88E5).withAlpha(50) : const Color(0xFFE3F2FD);
      tileBorder = isDark ? const Color(0xFF1E88E5) : const Color(0xFF2563EB);
    } else {
      tileBg = isDark ? const Color(0xFF0F172A).withAlpha(160) : const Color(0xFFF1F5F9);
      tileBorder = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    }

    return GestureDetector(
      onTap: () => _onLevelTap(level, isUnlocked),
      child: Container(
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tileBorder, width: isUnlocked ? 1.5 : 1.0),
          boxShadow: [
            if (isUnlocked)
              BoxShadow(
                color: (isCompleted ? const Color(0xFF00E676) : const Color(0xFF1E88E5))
                    .withAlpha(isDark ? 50 : 25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              Icon(
                Icons.lock_rounded,
                size: 20,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              )
            else
              Text(
                '${level.levelNumber}',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            const SizedBox(height: 3),
            // 3-Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (starIdx) {
                return Icon(
                  Icons.star_rounded,
                  size: 11,
                  color: isCompleted
                      ? const Color(0xFFFFD700)
                      : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Backward-compatible alias for WorldLevelsScreen
typedef WorldLevelsScreen = ChapterLevelsScreen;

