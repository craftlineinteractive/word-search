import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/puzzle_level.dart';
import '../models/user_progress.dart';
import '../services/daily_puzzle_service.dart';
import '../services/level_repository.dart';
import '../services/sound_manager.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_particles_overlay.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/organic_wood_button.dart';
import '../widgets/parchment_card.dart';
import 'achievements_screen.dart';
import 'gameplay_screen.dart';
import 'levels_map_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onPlayTap;

  const HomeScreen({super.key, this.onPlayTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _coins = 50;
  int _hints = 3;
  int _clearedLevels = 0;
  int _totalStars = 0;
  int _nextLevelOverall = 1;
  bool _isDailyCompleted = false;
  Chapter? _nextChapter;
  PuzzleLevel? _nextLevel;

  late final AnimationController _cloudController;

  @override
  void initState() {
    super.initState();
    _loadProgress();
    SoundManager.instance.startContinuousBgm();

    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _cloudController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final progress = await UserProgress.load();
    final cleared = progress.completedLevels.length;
    final stars = progress.getTotalStars();
    final todayKey = DailyPuzzleService.getTodayKey();
    final isDailyDone = progress.isDailyPuzzleCompleted(todayKey);

    // Resolve which chapter and level corresponds to next uncompleted level
    Chapter? targetChapter;
    PuzzleLevel? targetLevel;

    // 1. Try player's active chapter first
    int activeId = progress.activeChapterId;
    if (!progress.isChapterUnlocked(activeId)) {
      activeId = 1;
    }

    final activeMeta = LevelRepository.catalog.firstWhere(
      (c) => c.id == activeId,
      orElse: () => LevelRepository.catalog.first,
    );

    final activeChapter = await LevelRepository.loadChapter(activeMeta.jsonFile);

    // Check uncompleted levels in active chapter at or after activeLevelIndex
    final uncompletedFromActive = activeChapter.levels.where(
      (lvl) => lvl.levelNumber >= progress.activeLevelIndex && !progress.isLevelCompleted(activeChapter.id, lvl.levelNumber),
    );

    if (uncompletedFromActive.isNotEmpty) {
      targetChapter = activeChapter;
      targetLevel = uncompletedFromActive.first;
    } else {
      // Check any uncompleted level in active chapter
      final anyUncompletedInActive = activeChapter.levels.where(
        (lvl) => !progress.isLevelCompleted(activeChapter.id, lvl.levelNumber),
      );

      if (anyUncompletedInActive.isNotEmpty) {
        targetChapter = activeChapter;
        targetLevel = anyUncompletedInActive.first;
      } else {
        // Active chapter is 100% completed! Look for next unlocked chapter with uncompleted levels
        for (final meta in LevelRepository.catalog) {
          if (!progress.isChapterUnlocked(meta.id)) continue;
          final chapter = await LevelRepository.loadChapter(meta.jsonFile);
          final uncompleted = chapter.levels.where(
            (lvl) => !progress.isLevelCompleted(chapter.id, lvl.levelNumber),
          );
          if (uncompleted.isNotEmpty) {
            targetChapter = chapter;
            targetLevel = uncompleted.first;
            break;
          }
        }
      }
    }

    if (targetChapter == null || targetLevel == null) {
      final firstChapter = await LevelRepository.loadChapter(
        LevelRepository.catalog.first.jsonFile,
      );
      targetChapter = firstChapter;
      targetLevel = firstChapter.levels.isNotEmpty ? firstChapter.levels.first : null;
    }

    if (mounted) {
      setState(() {
        _coins = progress.coins;
        _hints = progress.hints;
        _clearedLevels = cleared;
        _totalStars = stars;
        _nextLevelOverall = targetLevel?.levelNumber ?? 1;
        _isDailyCompleted = isDailyDone;
        _nextChapter = targetChapter;
        _nextLevel = targetLevel;
      });
    }
  }

  void _continueGame() async {
    SoundManager.instance.playButtonClick();
    if (widget.onPlayTap != null) {
      widget.onPlayTap!();
      return;
    }

    if (_nextChapter != null && _nextLevel != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GameplayScreen(chapter: _nextChapter!, level: _nextLevel!),
        ),
      );
      _loadProgress();
    }
  }

  void _openDailyPuzzle() async {
    SoundManager.instance.playButtonClick();
    final dailyLevel = await DailyPuzzleService.getDailyPuzzle();
    final dailyChapter = DailyPuzzleService.getDailyChapter();

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GameplayScreen(chapter: dailyChapter, level: dailyLevel),
        ),
      );
      _loadProgress();
    }
  }

  void _openLevelsMap() async {
    SoundManager.instance.playButtonClick();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LevelsMapScreen()),
    );
    _loadProgress();
  }

  void _openAchievements() async {
    SoundManager.instance.playButtonClick();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AchievementsScreen()),
    );
    _loadProgress();
  }

  void _openSettings() async {
    SoundManager.instance.playButtonClick();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    _loadProgress();
  }

  void _openShop() async {
    SoundManager.instance.playButtonClick();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShopScreen()),
    );
    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    const Color strokeDark = Color(0xFF2A1810);
    const int totalLevels = 3600;
    const int totalPossibleStars = 3600 * 3;
    final progressFraction = (_clearedLevels / totalLevels).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: Stack(
        children: [
          // ==================== LAYER 1: ENCHANTED FOREST BACKDROP ====================
          _buildForestBackground(),

          // ==================== LAYER 2: AMBIENT FIREFLIES PARTICLES ====================
          const AmbientParticlesOverlay(
            maxParticles: 14,
            type: ParticleType.fireflies,
          ),

          // ==================== LAYER 3: FOREGROUND PROPS & SCENERY ====================
          _buildForegroundScenery(),

          // ==================== LAYER 4: MAIN INTERACTIVE UI ====================
          SafeArea(
            child: Column(
              children: [
                // Top Currency & Settings Header Bar
                _buildTopBar(strokeDark),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),

                        // Game Title Banner with 2D Cartoon Styling
                        _buildGameTitle(strokeDark),

                        const SizedBox(height: 24),

                        // Primary Play / Continue Button
                        OrganicWoodButton(
                          width: double.infinity,
                          height: 64,
                          variant: WoodButtonVariant.primary,
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF2A1810),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Color(0xFFFFB300),
                              size: 26,
                            ),
                          ),
                          onPressed: _continueGame,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'PLAY LEVEL ${_nextLevel?.levelNumber ?? _nextLevelOverall}',
                                style: const TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  color: strokeDark,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (_nextChapter != null)
                                Text(
                                  '${_nextChapter!.title.toUpperCase()} WORLD',
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: strokeDark.withAlpha(190),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Secondary Navigation: World Map & Achievements
                        Row(
                          children: [
                            Expanded(
                              child: OrganicWoodButton(
                                height: 50,
                                variant: WoodButtonVariant.forest,
                                fontSize: 14,
                                icon: Icons.map_rounded,
                                text: 'WORLD MAP',
                                onPressed: _openLevelsMap,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OrganicWoodButton(
                                height: 50,
                                variant: WoodButtonVariant.secondary,
                                fontSize: 14,
                                icon: Icons.emoji_events_rounded,
                                text: 'ACHIEVEMENTS',
                                onPressed: _openAchievements,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Daily Challenge Card
                        _buildDailyCard(strokeDark),

                        const SizedBox(height: 16),

                        // Overall Journey Progress Parchment Card
                        _buildProgressCard(
                          strokeDark,
                          totalLevels,
                          totalPossibleStars,
                          progressFraction,
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Bottom Ad Banner
                const BannerAdWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SCENERY & ENVIRONMENT BUILDERS
  // ---------------------------------------------------------------------------

  Widget _buildForestBackground() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.45, 0.75, 1.0],
            colors: [
              Color(0xFFBAE6FD), // Sunny Sky Blue
              Color(0xFFE0F2FE), // Soft Morning Horizon
              Color(0xFFDCFCE7), // Distant Spring Meadows
              Color(0xFFFEF9C3), // Warm Ground Sunlit Glow
            ],
          ),
        ),
        child: Stack(
          children: [
            // Drifting Clouds Layer
            AnimatedBuilder(
              animation: _cloudController,
              builder: (context, _) {
                final double screenWidth = MediaQuery.of(context).size.width;
                final double cloudOffset1 = (_cloudController.value * (screenWidth + 200)) - 100;
                final double cloudOffset2 = (((_cloudController.value + 0.5) % 1.0) * (screenWidth + 200)) - 100;

                return Stack(
                  children: [
                    Positioned(
                      top: 40,
                      left: cloudOffset1,
                      child: Image.asset(
                        'assets/game_art/shared/forest/forest_cloud1.png',
                        width: 140,
                        opacity: const AlwaysStoppedAnimation(0.85),
                        errorBuilder: (context, error, stackTrace) => const SizedBox(),
                      ),
                    ),
                    Positioned(
                      top: 85,
                      left: cloudOffset2,
                      child: Image.asset(
                        'assets/game_art/shared/forest/forest_cloud2.png',
                        width: 155,
                        opacity: const AlwaysStoppedAnimation(0.75),
                        errorBuilder: (context, error, stackTrace) => const SizedBox(),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Lush Green Pine & Foliage Canopy Layers (Colorized with rich forest green tints)
            Positioned(
              bottom: 110,
              left: -30,
              child: Image.asset(
                'assets/game_art/shared/forest/forest_tree_pine.png',
                width: 220,
                height: 320,
                color: const Color(0xFF166534).withAlpha(160),
                colorBlendMode: BlendMode.srcIn,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
            Positioned(
              bottom: 100,
              right: -40,
              child: Image.asset(
                'assets/game_art/shared/forest/forest_tree_oak.png',
                width: 250,
                height: 340,
                color: const Color(0xFF15803D).withAlpha(175),
                colorBlendMode: BlendMode.srcIn,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),

            // Distant Soft Spring Meadow Hill
            Positioned(
              bottom: 30,
              left: -50,
              right: -50,
              height: 120,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.elliptical(360, 110),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF86EFAC).withAlpha(190), // Soft Mint Spring Meadow
                      const Color(0xFF4ADE80).withAlpha(220), // Lush Green Meadow
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForegroundScenery() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: SizedBox(
          height: 120,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Lush Foreground Green Meadow Mound
              Positioned(
                bottom: -15,
                left: -30,
                right: -30,
                height: 65,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.elliptical(280, 60),
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF4ADE80), // Vibrant Spring Green
                        Color(0xFF16A34A), // Deep Meadow Green
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF14532D).withAlpha(60),
                        blurRadius: 8,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                ),
              ),

              // Left Shrub & Red Toadstool
              Positioned(
                bottom: 12,
                left: 12,
                child: Image.asset(
                  'assets/game_art/shared/forest/forest_bush.png',
                  width: 68,
                  height: 68,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 60,
                child: Image.asset(
                  'assets/game_art/shared/forest/forest_mushroom_red.png',
                  width: 48,
                  height: 48,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),

              // Friendly Forest Bear Mascot Greeting Player
              Positioned(
                bottom: 14,
                right: 18,
                child: Image.asset(
                  'assets/game_art/shared/animals/animal_bear.png',
                  width: 72,
                  height: 66,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 80,
                child: Image.asset(
                  'assets/game_art/shared/forest/forest_mushroom_brown.png',
                  width: 44,
                  height: 44,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INTERACTIVE UI COMPONENTS
  // ---------------------------------------------------------------------------

  Widget _buildTopBar(Color strokeDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
      child: Row(
        children: [
          // Coins Badge (Tap to open Shop)
          GestureDetector(
            onTap: _openShop,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: strokeDark, width: 2.2),
                boxShadow: [
                  BoxShadow(
                    color: strokeDark.withAlpha(40),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.monetization_on_rounded,
                    color: Color(0xFFFFB300),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_coins',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A1810),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 12),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Hints Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: strokeDark, width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: strokeDark.withAlpha(40),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFFFFB300),
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  '$_hints',
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A1810),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Settings Button (Wooden Carved Style)
          GestureDetector(
            onTap: _openSettings,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFB45309), Color(0xFF78350F)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: strokeDark, width: 2.2),
                boxShadow: [
                  BoxShadow(
                    color: strokeDark.withAlpha(60),
                    blurRadius: 4,
                    offset: const Offset(0, 2.5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.settings_rounded,
                color: Color(0xFFFFFBEB),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameTitle(Color strokeDark) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Dark Stroke Shadow Layer
            Text(
              'WORD SEARCH',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 38,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6.5
                  ..color = strokeDark,
              ),
            ),
            // Top Golden Gradient Fill Layer
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF176), Color(0xFFFFB300), Color(0xFFEA580C)],
              ).createShader(bounds),
              child: const Text(
                'WORD SEARCH',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Subtitle Wood Ribbon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF15803D),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: strokeDark, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: strokeDark.withAlpha(40),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text(
            'ENCHANTED WORLDS',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Color(0xFFFFFBEB),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyCard(Color strokeDark) {
    final formattedDate = DailyPuzzleService.getFormattedDate();

    return ParchmentCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: _openDailyPuzzle,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isDailyCompleted ? const Color(0xFF16A34A) : const Color(0xFFE11D48),
              shape: BoxShape.circle,
              border: Border.all(color: strokeDark, width: 1.5),
            ),
            child: Icon(
              _isDailyCompleted ? Icons.check_circle_rounded : Icons.calendar_month_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Daily Puzzle',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A1810),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _isDailyCompleted ? const Color(0xFF16A34A) : const Color(0xFFFFB300),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: strokeDark, width: 1.0),
                      ),
                      child: Text(
                        _isDailyCompleted ? 'SOLVED' : '+50 COINS',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A1810),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _isDailyCompleted ? 'Completed today • Great job!' : formattedDate,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 12,
                    color: Color(0xFF6B584E),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Color(0xFF6B584E),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    Color strokeDark,
    int totalLevels,
    int totalPossibleStars,
    double progressFraction,
  ) {
    return ParchmentCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Levels Cleared Metric
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF16A34A),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$_clearedLevels / $totalLevels',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2A1810),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Levels Cleared',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 11,
                        color: Color(0xFF6B584E),
                      ),
                    ),
                  ],
                ),
              ),

              // Vertical Divider
              Container(
                width: 1.5,
                height: 32,
                color: strokeDark.withAlpha(40),
              ),

              // Stars Collected Metric
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/game_art/shared/ui/ui_star_gold.png',
                          width: 18,
                          height: 18,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFB300),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$_totalStars / $totalPossibleStars',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2A1810),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Stars Collected',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 11,
                        color: Color(0xFF6B584E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressFraction,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF16A34A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
