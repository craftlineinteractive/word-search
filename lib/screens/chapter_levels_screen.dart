import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/puzzle_level.dart';
import '../models/user_progress.dart';
import '../services/sound_manager.dart';
import '../theme/world_theme.dart';
import '../widgets/ambient_particles_overlay.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/parchment_card.dart';
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
          backgroundColor: Color(0xFFC62828),
          content: Text(
            'Complete previous levels to unlock this level!',
            style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold),
          ),
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
    final worldTheme = WorldTheme.getTheme(widget.chapter.id);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFBF8F1),
        body: Center(
          child: CircularProgressIndicator(color: worldTheme.primaryColor),
        ),
      );
    }

    final completedCount = _userProgress.getCompletedLevelsCount(widget.chapter.id);
    final totalLevels = widget.chapter.levels.length;
    final chapterStars = completedCount * 3;
    final totalPossibleStars = totalLevels * 3;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F1),
      body: Stack(
        children: [
          // 1. World-Themed Storybook Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: worldTheme.backgroundGradient,
                ),
              ),
            ),
          ),

          // 2. Thematic Decorative Props in Background
          if (worldTheme.decorativeProps.isNotEmpty) ...[
            Positioned(
              left: -12,
              bottom: 80,
              child: Opacity(
                opacity: 0.28,
                child: Image.asset(
                  worldTheme.decorativeProps.first,
                  width: 90,
                  height: 90,
                  errorBuilder: (ctx, err, stack) => const SizedBox(),
                ),
              ),
            ),
            if (worldTheme.decorativeProps.length > 1)
              Positioned(
                right: -10,
                top: 140,
                child: Opacity(
                  opacity: 0.28,
                  child: Image.asset(
                    worldTheme.decorativeProps[1],
                    width: 85,
                    height: 85,
                    errorBuilder: (ctx, err, stack) => const SizedBox(),
                  ),
                ),
              ),
          ],

          // 3. Ambient Drifting Particles
          Positioned.fill(
            child: AmbientParticlesOverlay(
              particleCount: 12,
              particleColor: worldTheme.accentColor,
            ),
          ),

          // 4. Main Foreground Content
          SafeArea(
            child: Column(
              children: [
                // Top Header Bar
                _buildTopHeader(worldTheme),

                // World Hero Banner Card
                _buildChapterHeroBanner(
                  worldTheme: worldTheme,
                  completedCount: completedCount,
                  totalLevels: totalLevels,
                  chapterStars: chapterStars,
                  totalPossibleStars: totalPossibleStars,
                ),

                const SizedBox(height: 8),

                // Grid of 120 Tactile Level Blocks
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 16, top: 4),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
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
                          worldTheme: worldTheme,
                        );
                      },
                    ),
                  ),
                ),

                // Banner Ad at Bottom
                const BannerAdWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(WorldTheme worldTheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: ParchmentCard(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Material(
              color: const Color(0xFF8D6E63),
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  SoundManager.instance.playButtonClick();
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.all(7.0),
                  child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.chapter.title,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2A1810),
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF5D4037), width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFB300), size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${_userProgress.coins}',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      color: Color(0xFF2A1810),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterHeroBanner({
    required WorldTheme worldTheme,
    required int completedCount,
    required int totalLevels,
    required int chapterStars,
    required int totalPossibleStars,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: ParchmentCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // World Icon in Carved Wooden Frame
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: worldTheme.primaryColor,
                border: Border.all(color: const Color(0xFF5D4037), width: 2.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2A1810).withAlpha(80),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                    widget.chapter.iconAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => const Icon(
                      Icons.landscape_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // World Stats & Thematic Flavor
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'World ${widget.chapter.id}: ${widget.chapter.title}',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2A1810),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 18),
                          const SizedBox(width: 2),
                          Text(
                            '$chapterStars / $totalPossibleStars',
                            style: const TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    'World ${widget.chapter.id} (${widget.chapter.levels.length} Levels)',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                  if (worldTheme.flavorQuote.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      worldTheme.flavorQuote,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 11,
                        color: Color(0xFF8D6E63),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$completedCount of $totalLevels levels cleared',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      Text(
                        '${((completedCount / (totalLevels > 0 ? totalLevels : 1)) * 100).toInt()}%',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: totalLevels > 0 ? (completedCount / totalLevels) : 0,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFD7CCC8),
                      valueColor: AlwaysStoppedAnimation<Color>(worldTheme.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelTile({
    required PuzzleLevel level,
    required bool isCompleted,
    required bool isUnlocked,
    required WorldTheme worldTheme,
  }) {
    Color tileBg;
    Color tileBorder;
    Color textColor;

    if (isCompleted) {
      tileBg = const Color(0xFFFFF9E6);
      tileBorder = const Color(0xFF5D4037);
      textColor = const Color(0xFF2A1810);
    } else if (isUnlocked) {
      tileBg = worldTheme.cellSelectedColor;
      tileBorder = worldTheme.primaryColor;
      textColor = const Color(0xFF2A1810);
    } else {
      tileBg = const Color(0xFFD7CCC8);
      tileBorder = const Color(0xFF8D6E63);
      textColor = const Color(0xFF8D6E63);
    }

    return GestureDetector(
      onTap: () => _onLevelTap(level, isUnlocked),
      child: Container(
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tileBorder, width: isUnlocked ? 2.0 : 1.2),
          boxShadow: [
            if (isUnlocked)
              BoxShadow(
                color: const Color(0xFF2A1810).withAlpha(40),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              const Icon(
                Icons.lock_rounded,
                size: 20,
                color: Color(0xFF5D4037),
              )
            else
              Text(
                '${level.levelNumber}',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            const SizedBox(height: 2),
            // 3-Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (starIdx) {
                return Icon(
                  Icons.star_rounded,
                  size: 11,
                  color: isCompleted
                      ? const Color(0xFFFFB300)
                      : const Color(0xFFBCAAA4),
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
