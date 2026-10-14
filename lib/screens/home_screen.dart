import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/puzzle_level.dart';
import '../models/user_progress.dart';
import '../services/daily_puzzle_service.dart';
import '../services/level_repository.dart';
import '../services/sound_manager.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_widget.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  int _coins = 50;
  int _hints = 3;
  int _clearedLevels = 0;
  int _totalStars = 0;
  int _nextLevelOverall = 1;
  bool _isDailyCompleted = false;
  Chapter? _nextChapter;
  PuzzleLevel? _nextLevel;

  @override
  void initState() {
    super.initState();
    _loadProgress();
    SoundManager.instance.startContinuousBgm();
  }

  Future<void> _loadProgress() async {
    final progress = await UserProgress.load();
    final cleared = progress.completedLevels.length;
    final stars = progress.getTotalStars();
    final nextOverall = cleared + 1;
    final todayKey = DailyPuzzleService.getTodayKey();
    final isDailyDone = progress.isDailyPuzzleCompleted(todayKey);

    // Resolve which chapter and level corresponds to next uncompleted level
    Chapter? targetChapter;
    PuzzleLevel? targetLevel;

    for (final meta in LevelRepository.catalog) {
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

    if (targetChapter == null || targetLevel == null) {
      final firstChapter = await LevelRepository.loadChapter(
        LevelRepository.catalog.first.jsonFile,
      );
      targetChapter = firstChapter;
      targetLevel = firstChapter.levels.isNotEmpty
          ? firstChapter.levels.first
          : null;
    }

    if (mounted) {
      setState(() {
        _coins = progress.coins;
        _hints = progress.hints;
        _clearedLevels = cleared;
        _totalStars = stars;
        _nextLevelOverall = nextOverall;
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
          builder: (_) =>
              GameplayScreen(chapter: _nextChapter!, level: _nextLevel!),
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
          builder: (_) =>
              GameplayScreen(chapter: dailyChapter, level: dailyLevel),
        ),
      );
      _loadProgress();
    }
  }

  void _openShopDialog() async {
    SoundManager.instance.playButtonClick();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShopScreen()),
    );
    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final textPrimary = AppTheme.getTextPrimaryColor(context);
    final textSecondary = AppTheme.getTextSecondaryColor(context);

    return Scaffold(
      body: Stack(
        children: [
          // Full Screen Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                color: isDark
                    ? const Color(0xFF081226)
                    : const Color(0xFFF8FAFC),
              ),
            ),
          ),
          // Subtle Tint Overlay for Card Readability
          Positioned.fill(
            child: Container(
              color: isDark
                  ? Colors.black.withAlpha(80)
                  : Colors.white.withAlpha(30),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(isDark, textPrimary),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          children: [
                            // App Logo Icon
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                color: isDark
                                    ? const Color(0xFF132347)
                                    : Colors.white,
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF1E3A6D)
                                      : const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(
                                      isDark ? 60 : 20,
                                    ),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/images/word_search_icon.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => const Icon(
                                    Icons.grid_on_rounded,
                                    size: 50,
                                    color: Color(0xFF29B6F6),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // App Title
                            Text(
                              'Word Search',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                                letterSpacing: 0.8,
                              ),
                            ),

                            const SizedBox(height: 3),

                            // Subtitle
                            Text(
                              '1050 Hand-Crafted Puzzle Levels',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 13,
                                color: textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ==================== 3. PROGRESS CARD ====================
                            _buildProgressCard(
                              isDark,
                              textPrimary,
                              textSecondary,
                            ),

                            const SizedBox(height: 14),

                            // ==================== 4. DAILY PUZZLE MINI CARD ====================
                            _buildDailyPuzzleCard(
                              isDark,
                              textPrimary,
                              textSecondary,
                            ),

                            const SizedBox(height: 14),

                            // ==================== 5. ACTION BUTTONS ====================
                            // Continue Level Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  shadowColor: const Color(
                                    0xFF2563EB,
                                  ).withAlpha(120),
                                ),
                                onPressed: _continueGame,
                                child: Text(
                                  'Continue – Level $_nextLevelOverall',
                                  style: const TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // All Levels Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? const Color(0xFF132347)
                                      : Colors.white,
                                  foregroundColor: textPrimary,
                                  side: BorderSide(
                                    color: isDark
                                        ? const Color(0xFF1E3A6D)
                                        : const Color(0xFFCBD5E1),
                                    width: 1.5,
                                  ),
                                  elevation: isDark ? 0 : 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () async {
                                  SoundManager.instance.playButtonClick();
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LevelsMapScreen(),
                                    ),
                                  );
                                  _loadProgress();
                                },
                                icon: Icon(
                                  Icons.grid_view_rounded,
                                  size: 20,
                                  color: isDark
                                      ? const Color(0xFF42A5F5)
                                      : const Color(0xFF2563EB),
                                ),
                                label: Text(
                                  'All Levels',
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
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

                // ==================== 6. BANNER AD ====================
                const BannerAdWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isDark, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          // Coins Pill
          GestureDetector(
            onTap: _openShopDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF132347) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFFFFD700)
                      : const Color(0xFFFFB300),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.monetization_on_rounded,
                    color: Color(0xFFFFD700),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_coins',
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
          ),

          const SizedBox(width: 8),

          // Hints Pill
          GestureDetector(
            onTap: _openShopDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF132347) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFFFFD54F)
                      : const Color(0xFFFFB300),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_rounded,
                    color: Color(0xFFFFB300),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_hints',
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
          ),

          const Spacer(),

          // Shop Button
          GestureDetector(
            onTap: _openShopDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB300), Color(0xFFFF9100)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9100).withAlpha(120),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Shop',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Settings Button
          Material(
            color: isDark ? const Color(0xFF1E3A6D) : Colors.white,
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () async {
                SoundManager.instance.playButtonClick();
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
                _loadProgress();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.settings_rounded,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    const totalLevels = 1050;
    const totalPossibleStars = 3150;
    final progressFraction = totalLevels > 0
        ? (_clearedLevels / totalLevels).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262D3D) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF3F4A63) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                          color: Color(0xFF00E676),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$_clearedLevels / $totalLevels',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Levels Cleared',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 11,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Vertical Divider
              Container(
                width: 1,
                height: 32,
                color: isDark
                    ? const Color(0xFF1E3A6D)
                    : const Color(0xFFE2E8F0),
              ),

              // Stars Collected Metric
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFD700),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_totalStars / $totalPossibleStars',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Stars Collected',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 11,
                        color: textSecondary,
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
              minHeight: 6,
              backgroundColor: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyPuzzleCard(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    final formattedDate = DailyPuzzleService.getFormattedDate();

    return GestureDetector(
      onTap: _openDailyPuzzle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isDailyCompleted
                ? (isDark
                      ? [
                          const Color(0xFF0F5132).withAlpha(150),
                          const Color(0xFF198754).withAlpha(150),
                        ]
                      : [const Color(0xFFD1E7DD), const Color(0xFFC3E6CB)])
                : (isDark
                      ? [
                          const Color(0xFF6B21A8).withAlpha(200),
                          const Color(0xFF4C1D95).withAlpha(200),
                        ]
                      : [const Color(0xFFF3E8FF), const Color(0xFFE9D5FF)]),
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isDailyCompleted
                ? const Color(0xFF00E676)
                : const Color(0xFFA855F7),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  (_isDailyCompleted
                          ? const Color(0xFF00E676)
                          : const Color(0xFFA855F7))
                      .withAlpha(isDark ? 60 : 30),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isDailyCompleted
                    ? const Color(0xFF00E676)
                    : const Color(0xFFA855F7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isDailyCompleted
                    ? Icons.check_circle_rounded
                    : Icons.calendar_month_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Daily Puzzle',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _isDailyCompleted
                              ? const Color(0xFF00E676)
                              : const Color(0xFFFFB300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _isDailyCompleted ? 'SOLVED' : '+50 COINS',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isDailyCompleted
                        ? 'Completed today • Great job!'
                        : formattedDate,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
