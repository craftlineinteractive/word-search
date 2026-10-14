import 'dart:math';
import 'package:flutter/material.dart';
import '../engine/word_grid_engine.dart';
import '../models/chapter.dart';
import '../models/grid_coordinate.dart';
import '../models/placed_word.dart';
import '../models/puzzle_level.dart';
import '../models/user_progress.dart';
import '../models/word_item.dart';
import '../services/ad_manager.dart';
import '../services/daily_puzzle_service.dart';
import '../services/level_repository.dart';
import '../services/sound_manager.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/confetti_celebration_overlay.dart';
import '../services/in_app_review_service.dart';
import '../widgets/reward_ad_dialog.dart';
import '../widgets/word_bank_chips.dart';
import '../widgets/word_meaning_dialog.dart';
import '../widgets/word_search_grid.dart';
import 'shop_screen.dart';

class GameplayScreen extends StatefulWidget {
  final Chapter chapter;
  final PuzzleLevel level;

  const GameplayScreen({
    super.key,
    required this.chapter,
    required this.level,
  });

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late Chapter _currentChapter;
  late PuzzleLevel _currentLevel;
  late GridGenerationResult _gridResult;
  final List<PlacedWord> _foundWords = [];
  GridCoordinate? _hintCoordinate;

  int _coins = 150;
  int _hints = 3;
  bool _isLevelComplete = false;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapter;
    _currentLevel = widget.level;
    _generatePuzzle();
    _loadProgress();
    // Ensure continuous BGM is playing smoothly
    SoundManager.instance.startContinuousBgm();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final progress = await UserProgress.load();
    final bool isDaily = _currentChapter.id == 9999;
    final todayKey = DailyPuzzleService.getTodayKey();

    if (mounted) {
      setState(() {
        _coins = progress.coins;
        _hints = progress.hints;
      });

      final bool isAlreadyCompleted = isDaily
          ? progress.isDailyPuzzleCompleted(todayKey)
          : progress.isLevelCompleted(_currentChapter.id, _currentLevel.levelNumber);

      if (isAlreadyCompleted) {
        // If already completed, restore all placed words
        setState(() {
          _foundWords.clear();
          _foundWords.addAll(_gridResult.placedWords);
          _isLevelComplete = true;
        });
      } else {
        // Restore previously discovered words
        final savedWords = isDaily
            ? progress.getDailyPuzzleFoundWords(todayKey)
            : progress.getLevelFoundWords(_currentChapter.id, _currentLevel.levelNumber);

        if (savedWords.isNotEmpty) {
          final savedSet = savedWords.map((w) => w.toUpperCase()).toSet();
          final restored = <PlacedWord>[];
          for (var placed in _gridResult.placedWords) {
            if (savedSet.contains(placed.word.toUpperCase())) {
              restored.add(placed);
            }
          }
          if (restored.isNotEmpty) {
            setState(() {
              _foundWords.clear();
              _foundWords.addAll(restored);
            });
          }
        }
      }
    }
  }

  void _generatePuzzle() {
    final wordsToPlace = _currentLevel.words.map((w) => w.word).toList();

    // Determine grid bounds
    final int rows = _currentLevel.gridRows;
    final int cols = _currentLevel.gridCols;

    // Deterministic random seed per chapter & level so grid layout never randomly rearranges
    final levelSeed = _currentChapter.id * 100000 + _currentLevel.levelNumber * 7919;
    _gridResult = WordGridEngine.generateGrid(
      rows: rows,
      cols: cols,
      words: wordsToPlace,
      allowBackwards: true,
      allowDiagonals: true,
      random: Random(levelSeed),
    );

    _foundWords.clear();
    _hintCoordinate = null;
    _isLevelComplete = false;
  }

  void _onWordFound(PlacedWord placedWord, WordItem wordItem) {
    if (_isLevelComplete) return;

    setState(() {
      _foundWords.add(placedWord);
      _hintCoordinate = null;
    });

    final bool isDaily = _currentChapter.id == 9999;
    final todayKey = DailyPuzzleService.getTodayKey();

    // Save discovered words immediately to UserProgress
    UserProgress.load().then((progress) {
      final currentList = _foundWords.map((w) => w.word.toUpperCase()).toList();
      if (isDaily) {
        progress.saveDailyPuzzleFoundWords(todayKey, currentList);
      } else {
        progress.saveLevelFoundWords(_currentChapter.id, _currentLevel.levelNumber, currentList);
      }
      progress.save();
    });

    // Check if level is completed
    if (_foundWords.length >= _currentLevel.words.length) {
      _handleLevelComplete();
    }
  }

  Future<void> _handleLevelComplete({bool isSkipped = false}) async {
    setState(() {
      _isLevelComplete = true;
    });

    SoundManager.instance.playLevelWin();

    final bool isDaily = _currentChapter.id == 9999;
    final todayKey = DailyPuzzleService.getTodayKey();

    // Update user progress
    final progress = await UserProgress.load();
    if (isSkipped) {
      // Skipped level: DO NOT award 10 coins!
      progress.completeLevel(_currentChapter.id, _currentLevel.levelNumber);
      progress.coins = _coins; // Ensure deducted coins are preserved
    } else if (isDaily) {
      progress.addCoins(50); // Daily bonus reward
      progress.completeDailyPuzzle(todayKey);
    } else {
      progress.addCoins(10);
      progress.completeLevel(_currentChapter.id, _currentLevel.levelNumber);
    }
    await progress.save();

    if (mounted) {
      setState(() {
        _coins = progress.coins;
      });
      _showLevelCompleteDialog(isSkipped: isSkipped);
      if (!isSkipped) {
        InAppReviewService.instance.requestReviewRandomly(
          completedLevel: _currentLevel.levelNumber,
          probability: 0.25,
        );
      }
    }
  }

  void _useHint() {
    if (_foundWords.length >= _currentLevel.words.length) return;

    if (_hints > 0) {
      setState(() {
        _hints--;
      });
      UserProgress.load().then((p) {
        p.hints = _hints;
        p.save();
      });
      _triggerHintEffect();
    } else {
      RewardAdDialog.show(
        context,
        type: RewardType.hint,
        onRewardClaimed: (type) => _loadProgress(),
      );
    }
  }

  Future<void> _useSkipLevelBooster() async {
    if (_isLevelComplete) return;

    final progress = await UserProgress.load();
    if (progress.coins < 50) {
      if (mounted) _showNotEnoughCoinsDialog(50);
      return;
    }

    // Deduct exactly 50 coins and save immediately
    progress.coins -= 50;
    await progress.save();

    if (!mounted) return;
    setState(() {
      _coins = progress.coins;
      _foundWords.clear();
      _foundWords.addAll(_gridResult.placedWords);
    });

    await _handleLevelComplete(isSkipped: true);
  }

  void _showNotEnoughCoinsDialog(int requiredCoins) {
    final isDark = AppTheme.isDark(context);
    final textPrimary = AppTheme.getTextPrimaryColor(context);
    final textSecondary = AppTheme.getTextSecondaryColor(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0C1938) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.monetization_on_rounded, size: 40, color: Color(0xFFFFD700)),
            ),
            const SizedBox(height: 12),
            Text(
              'Not Enough Coins!',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You need $requiredCoins Coins to use this booster. Get coins in the Shop or watch a video ad for free coins!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ShopScreen()),
                  );
                  _loadProgress();
                },
                icon: const Icon(Icons.shopping_bag_rounded, size: 20),
                label: const Text(
                  'OPEN COIN SHOP',
                  style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  RewardAdDialog.show(
                    context,
                    type: RewardType.coins,
                    onRewardClaimed: (type) => _loadProgress(),
                  );
                },
                icon: const Icon(Icons.play_circle_outline_rounded, size: 20, color: Color(0xFF00E676)),
                label: const Text(
                  'Watch Video Ad (+25 Coins)',
                  style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  void _triggerHintEffect() {
    final foundWordTexts = _foundWords.map((w) => w.word.toUpperCase()).toSet();

    // Find the first placed word that is not found yet
    PlacedWord? targetPlacedWord;
    for (var placed in _gridResult.placedWords) {
      if (!foundWordTexts.contains(placed.word.toUpperCase())) {
        targetPlacedWord = placed;
        break;
      }
    }

    if (targetPlacedWord != null && targetPlacedWord.coordinates.isNotEmpty) {
      SoundManager.instance.playHint();

      setState(() {
        _hintCoordinate = targetPlacedWord!.coordinates.first;
      });

      // Clear hint highlight after 4 seconds
      Future.delayed(const Duration(milliseconds: 4000), () {
        if (mounted && _hintCoordinate != null) {
          setState(() {
            _hintCoordinate = null;
          });
        }
      });
    }
  }

  void _openWordDefinition(WordItem wordItem) {
    WordMeaningDialog.show(context, wordItem, _currentChapter.title);
  }

  void _openAllWordsSheet() {
    final isDark = AppTheme.isDark(context);
    final textPrimary = AppTheme.getTextPrimaryColor(context);
    final textSecondary = AppTheme.getTextSecondaryColor(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0C1938) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vocabulary Words & Meanings',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    '${_foundWords.length}/${_currentLevel.words.length} Found',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00E676),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _currentLevel.words.length,
                  separatorBuilder: (_, _) => Divider(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    height: 1,
                  ),
                  itemBuilder: (context, idx) {
                    final item = _currentLevel.words[idx];
                    final isFound = _foundWords.any(
                      (w) => w.word.toUpperCase() == item.word.toUpperCase(),
                    );

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      leading: Icon(
                        isFound ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: isFound ? const Color(0xFF00E676) : (isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
                      ),
                      title: Text(
                        item.word,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isFound
                              ? textPrimary
                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          decoration: isFound ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text(
                        item.meaning,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                      trailing: const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF29B6F6)),
                      onTap: () {
                        Navigator.pop(ctx);
                        _openWordDefinition(item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _loadNextLevel() async {
    final nextLevelNum = _currentLevel.levelNumber + 1;
    final nextLevel = _currentChapter.levels.firstWhere(
      (l) => l.levelNumber == nextLevelNum,
      orElse: () => _currentLevel,
    );

    if (nextLevel.levelNumber != _currentLevel.levelNumber) {
      setState(() {
        _currentLevel = nextLevel;
        _generatePuzzle();
      });
    } else {
      // Completed all levels in chapter - check if next chapter exists
      final nextChapterId = _currentChapter.id + 1;
      final nextMeta = LevelRepository.catalog.firstWhere(
        (c) => c.id == nextChapterId,
        orElse: () => LevelRepository.catalog.first,
      );

      if (nextMeta.id != _currentChapter.id) {
        final loadedChapter = await LevelRepository.loadChapter(nextMeta.jsonFile);
        if (mounted) {
          setState(() {
            _currentChapter = loadedChapter;
            _currentLevel = loadedChapter.levels.first;
            _generatePuzzle();
          });
        }
      } else {
        if (mounted) Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final textPrimary = AppTheme.getTextPrimaryColor(context);

    return Scaffold(
      body: Stack(
        children: [
          // Full Screen Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/level_bg.jpg',
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
                // 1. Top Navigation & Stats Bar
                _buildTopBar(isDark, textPrimary),

                const SizedBox(height: 4),

                // 2. Interactive Word Search Grid
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: WordSearchGrid(
                      grid: _gridResult.grid,
                      levelWords: _currentLevel.words,
                      foundWords: _foundWords,
                      hintCoordinate: _hintCoordinate,
                      onWordFound: _onWordFound,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // 3. Word Bank Chips (Target Words with definitions)
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: WordBankChips(
                        levelWords: _currentLevel.words,
                        foundWords: _foundWords,
                        onWordTap: _openWordDefinition,
                      ),
                    ),
                  ),
                ),

                // 4. Action & Hint Buttons at Bottom (No Overflow)
                _buildBottomControls(),

                // 5. Banner Ad at Bottom
                const BannerAdWidget(),
              ],
            ),
          ),

          // 5. Confetti Celebration Fireworks Overlay on Level Win
          if (_isLevelComplete)
            const Positioned.fill(
              child: ConfettiCelebrationOverlay(),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isDark, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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

          // Chapter & Level Title Center (Responsive with no overflow)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentChapter.id == 9999
                        ? 'Daily Puzzle'
                        : '${_currentChapter.title} • Level ${_currentLevel.levelNumber}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _currentChapter.id == 9999
                        ? '${DailyPuzzleService.getFormattedDate()} • ${_foundWords.length}/${_currentLevel.words.length} Words'
                        : '${_foundWords.length} of ${_currentLevel.words.length} Words',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF00E676) : const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Coins Counter (Tap for Free Rewards)
          GestureDetector(
            onTap: () {
              SoundManager.instance.playButtonClick();
              RewardAdDialog.show(
                context,
                type: RewardType.coins,
                onRewardClaimed: (type) => _loadProgress(),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                    '$_coins',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      color: textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.add_circle_rounded, color: Color(0xFF00E676), size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    final isDark = AppTheme.isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Row(
        children: [
          // 1. VOCABULARY BUTTON
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF1E3A6D) : const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                onPressed: () {
                  SoundManager.instance.playButtonClick();
                  _openAllWordsSheet();
                },
                icon: const Icon(Icons.menu_book_rounded, size: 18),
                label: const Text(
                  'VOCABULARY',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 2. HINT BUTTON
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB300),
                  foregroundColor: const Color(0xFF3E2723),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                onPressed: () {
                  SoundManager.instance.playButtonClick();
                  _useHint();
                },
                icon: const Icon(Icons.lightbulb_rounded, size: 18),
                label: Text(
                  _hints > 0 ? 'HINT ($_hints)' : 'HINT',
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 3. NEXT BUTTON
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                onPressed: () {
                  SoundManager.instance.playButtonClick();
                  _useSkipLevelBooster();
                },
                icon: const Icon(Icons.skip_next_rounded, size: 20),
                label: const Text(
                  'NEXT',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 12,
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

  void _showLevelCompleteDialog({bool isSkipped = false}) {
    final isDark = AppTheme.isDark(context);
    final textPrimary = AppTheme.getTextPrimaryColor(context);
    final textSecondary = AppTheme.getTextSecondaryColor(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
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
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSkipped ? const Color(0xFF29B6F6) : const Color(0xFFFFD700),
                  boxShadow: [
                    BoxShadow(
                      color: (isSkipped ? const Color(0xFF29B6F6) : const Color(0xFFFFD700)).withAlpha(120),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isSkipped ? Icons.skip_next_rounded : Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isSkipped ? 'LEVEL SKIPPED!' : 'LEVEL COMPLETE!',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isSkipped
                    ? 'You skipped ${_currentChapter.title} Level ${_currentLevel.levelNumber}.'
                    : 'Magnificent job! You found all words in ${_currentChapter.title} Level ${_currentLevel.levelNumber}.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 14,
                  color: textSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E3A6D) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSkipped ? Icons.remove_circle_outline_rounded : Icons.monetization_on_rounded,
                      color: isSkipped ? const Color(0xFFEF5350) : const Color(0xFFFFD700),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isSkipped ? '-50 COINS USED' : '+10 COINS EARNED',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isSkipped ? const Color(0xFFEF5350) : textPrimary,
                      ),
                    ),
                  ],
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
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    AdManager.instance.showInterstitialIfEligible(
                      onAdClosed: () => _loadNextLevel(),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'NEXT LEVEL',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
