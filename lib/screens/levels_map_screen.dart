import 'dart:math';
import 'package:flutter/material.dart';
import '../models/user_progress.dart';
import '../services/daily_puzzle_service.dart';
import '../services/level_repository.dart';
import '../services/sound_manager.dart';
import '../theme/app_theme.dart';
import '../widgets/chapter_node_widget.dart';
import '../widgets/journey_path_painter.dart';
import 'chapter_levels_screen.dart';
import 'gameplay_screen.dart';
import 'settings_screen.dart';

class LevelsMapScreen extends StatefulWidget {
  const LevelsMapScreen({super.key});

  @override
  State<LevelsMapScreen> createState() => _LevelsMapScreenState();
}

class _LevelsMapScreenState extends State<LevelsMapScreen> {
  int _selectedTab = 0; // 0 = Level Map, 1 = Daily
  late UserProgress _userProgress;
  final ScrollController _scrollController = ScrollController();

  static const double _nodeVerticalSpacing = 145.0;
  static const double _bottomPadding = 140.0;
  static const double _topPadding = 100.0;

  @override
  void initState() {
    super.initState();
    _userProgress = UserProgress(
      coins: 300,
      hints: 5,
      activeChapterId: 1,
      unlockedChapters: {1},
    );
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await UserProgress.load();
    if (mounted) {
      setState(() {
        _userProgress = progress;
      });

      // Auto-scroll to active chapter after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActiveChapter();
      });
    }
  }

  void _scrollToActiveChapter() {
    if (!_scrollController.hasClients) return;

    final catalog = LevelRepository.catalog;
    final int activeIndex = catalog.indexWhere((c) => c.id == _userProgress.activeChapterId);
    if (activeIndex != -1) {
      final double targetOffset = _scrollController.position.maxScrollExtent - (activeIndex * _nodeVerticalSpacing);
      final double clampedOffset = targetOffset.clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );

      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _getCompletedLevelsForChapter(int chapterId) {
    int count = 0;
    for (int lvl = 1; lvl <= 35; lvl++) {
      if (_userProgress.isLevelCompleted(chapterId, lvl)) {
        count++;
      }
    }
    return count;
  }

  int _getTotalStars() {
    return _userProgress.getTotalStars();
  }

  ChapterStatus _getChapterStatus(int chapterId, int index) {
    final completedCount = _getCompletedLevelsForChapter(chapterId);
    if (completedCount >= 35) {
      return ChapterStatus.completed;
    }
    if (_userProgress.isChapterUnlocked(chapterId)) {
      return ChapterStatus.active;
    }
    return ChapterStatus.locked;
  }

  void _onChapterTapped(ChapterMeta chapterMeta) async {
    final isUnlocked = _userProgress.isChapterUnlocked(chapterMeta.id);
    if (!isUnlocked) {
      SoundManager.instance.playError();
      _showLockedChapterDialog(chapterMeta);
      return;
    }

    SoundManager.instance.playButtonClick();
    final chapter = await LevelRepository.loadChapter(chapterMeta.jsonFile);

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChapterLevelsScreen(chapter: chapter),
        ),
      );
      _loadProgress();
    }
  }

  void _showLockedChapterDialog(ChapterMeta chapterMeta) {
    final isDark = AppTheme.isDark(context);
    final textPrimary = AppTheme.getTextPrimaryColor(context);
    final textSecondary = AppTheme.getTextSecondaryColor(context);
    final requiredStars = _userProgress.getRequiredStarsForChapter(chapterMeta.id);
    final totalStars = _userProgress.getTotalStars();
    final needed = _userProgress.getStarsNeededForChapter(chapterMeta.id);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0C1938) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark ? const Color(0xFF1E3A6D) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE53935).withAlpha(120),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.lock_rounded, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 14),
            Text(
              'Chapter ${chapterMeta.id} Locked!',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF132347) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E3A6D) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '$totalStars / $requiredStars Stars',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'You need $needed more stars to unlock Chapter ${chapterMeta.id}: ${chapterMeta.title}.\n\nEarn stars by finding all words in previous chapters!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 14,
                color: textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'GO EARN STARS',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

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
                // 1. Top Header
                _buildTopHeader(isDark),

                // 2. Main Body (Roadmap Journey or Daily Challenge)
                Expanded(
                  child: _selectedTab == 0 ? _buildWindingJourneyMap(isDark) : _buildDailyTab(isDark),
                ),

                // 3. Bottom Navigation
                _buildBottomNav(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(bool isDark) {
    final textPrimary = AppTheme.getTextPrimaryColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B192C).withAlpha(230) : Colors.white.withAlpha(230),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 80 : 15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
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

          // Stars Collected Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3A6D) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 4),
                Text(
                  '${_getTotalStars()}',
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

          // Chapter Progress Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3A6D) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF00E676) : const Color(0xFF10B981),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.flag_rounded,
                  color: isDark ? const Color(0xFF00E676) : const Color(0xFF10B981),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'CH ${_userProgress.activeChapterId} / 30',
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
                child: Icon(Icons.settings_rounded, color: textPrimary, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWindingJourneyMap(bool isDark) {
    final catalog = LevelRepository.catalog;
    final int count = catalog.length;
    final double totalHeight = (count - 1) * _nodeVerticalSpacing + _bottomPadding + _topPadding;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double centerX = screenWidth / 2.0;
        final double amplitude = (screenWidth - 140) / 2.0;

        // Calculate (x, y) coordinates for all 30 chapter nodes from bottom (Chapter 1) to top (Chapter 30)
        final List<Offset> nodePositions = [];
        for (int i = 0; i < count; i++) {
          final double swayX = centerX + sin(i * 0.95) * amplitude;
          final double posY = totalHeight - _bottomPadding - (i * _nodeVerticalSpacing);
          nodePositions.add(Offset(swayX, posY));
        }

        final int activeIndex = catalog.indexWhere((c) => c.id == _userProgress.activeChapterId);

        return SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: screenWidth,
            height: totalHeight,
            child: Stack(
              children: [
                // 1. Smooth Bezier Winding Road Painter
                Positioned.fill(
                  child: CustomPaint(
                    painter: JourneyPathPainter(
                      nodePositions: nodePositions,
                      activeChapterIndex: activeIndex != -1 ? activeIndex : 0,
                      isDark: isDark,
                    ),
                  ),
                ),

                // 2. Start Flag at Bottom (Positioned comfortably below Chapter 1 without overlap)
                Positioned(
                  left: nodePositions.first.dx - 55,
                  top: nodePositions.first.dy + 72,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withAlpha(120),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'START JOURNEY',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Summit Trophy at Top
                Positioned(
                  left: nodePositions.last.dx - 40,
                  top: nodePositions.last.dy - 60,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF9100)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9100).withAlpha(140),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'SUMMIT MASTER',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. Render all 30 Chapter Nodes
                for (int i = 0; i < count; i++)
                  Positioned(
                    left: nodePositions[i].dx - 54,
                    top: nodePositions[i].dy - 48,
                    child: SizedBox(
                      width: 108,
                      child: ChapterNodeWidget(
                        chapter: catalog[i],
                        status: _getChapterStatus(catalog[i].id, i),
                        completedLevelsCount: _getCompletedLevelsForChapter(catalog[i].id),
                        totalLevelsCount: 35,
                        requiredStars: _userProgress.getRequiredStarsForChapter(catalog[i].id),
                        onTap: () => _onChapterTapped(catalog[i]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyTab(bool isDark) {
    final textPrimary = AppTheme.getTextPrimaryColor(context);
    final textSecondary = AppTheme.getTextSecondaryColor(context);
    final todayKey = DailyPuzzleService.getTodayKey();
    final bool isDone = _userProgress.isDailyPuzzleCompleted(todayKey);
    final formattedDate = DailyPuzzleService.getFormattedDate();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF132347) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? const Color(0xFF00E676) : const Color(0xFFFFD700),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDone ? const Color(0xFF00E676) : const Color(0xFFFFD700))
                        .withAlpha(isDark ? 80 : 40),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isDone ? Icons.check_circle_rounded : Icons.calendar_month_rounded,
                size: 54,
                color: isDone ? const Color(0xFF00E676) : const Color(0xFFFFD700),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Daily Puzzle Challenge',
              style: TextStyle(
                fontFamily: 'Fredoka',
                color: textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formattedDate,
              style: TextStyle(
                fontFamily: 'Fredoka',
                color: const Color(0xFFFFB300),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isDone
                  ? 'You have already solved today\'s puzzle and earned +50 Coins! Come back tomorrow for a new challenge.'
                  : 'A fresh unique handcrafted word puzzle every single day! Solve today\'s puzzle to earn +50 Bonus Coins.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Fredoka',
                color: textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDone ? const Color(0xFF00E676) : const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () async {
                SoundManager.instance.playButtonClick();
                final dailyLevel = await DailyPuzzleService.getDailyPuzzle();
                final dailyChapter = DailyPuzzleService.getDailyChapter();
                if (mounted) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GameplayScreen(
                        chapter: dailyChapter,
                        level: dailyLevel,
                      ),
                    ),
                  );
                  _loadProgress();
                }
              },
              child: Text(
                isDone ? "VIEW TODAY'S PUZZLE" : "PLAY TODAY'S PUZZLE (+50 COINS)",
                style: const TextStyle(fontFamily: 'Fredoka', fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B192C) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                SoundManager.instance.playButtonClick();
                setState(() => _selectedTab = 0);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.map_rounded,
                      color: _selectedTab == 0
                          ? (isDark ? const Color(0xFF00E676) : const Color(0xFF10B981))
                          : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Journey Map',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        color: _selectedTab == 0
                            ? (isDark ? const Color(0xFF00E676) : const Color(0xFF10B981))
                            : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                SoundManager.instance.playButtonClick();
                setState(() => _selectedTab = 1);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rate_rounded,
                      color: _selectedTab == 1
                          ? const Color(0xFFFFB300)
                          : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Daily Challenge',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        color: _selectedTab == 1
                            ? const Color(0xFFFFB300)
                            : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
