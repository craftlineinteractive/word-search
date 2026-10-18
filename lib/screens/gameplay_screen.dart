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
import '../theme/world_theme.dart';
import '../widgets/ambient_particles_overlay.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/confetti_celebration_overlay.dart';
import '../services/in_app_review_service.dart';
import '../widgets/organic_wood_button.dart';
import '../widgets/parchment_card.dart';
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
        Future.delayed(const Duration(milliseconds: 600), () {
          InAppReviewService.instance.requestReviewRandomly(
            completedLevel: _currentLevel.levelNumber,
            probability: 0.5,
          );
        });
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
    SoundManager.instance.playError();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ParchmentCard(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD54F),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF5D4037), width: 2),
                  ),
                  child: const Icon(Icons.monetization_on_rounded, size: 36, color: Color(0xFF2A1810)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Not Enough Coins!',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2A1810),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You need $requiredCoins Coins to use this booster. Get coins in the Shop or watch a video ad for free coins!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 13,
                    color: Color(0xFF5D4037),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 18),
                OrganicWoodButton(
                  text: 'OPEN COIN SHOP',
                  icon: Icons.shopping_bag_rounded,
                  variant: WoodButtonVariant.primary,
                  height: 48,
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ShopScreen()),
                    );
                    _loadProgress();
                  },
                ),
                const SizedBox(height: 10),
                OrganicWoodButton(
                  text: 'WATCH AD (+25 COINS)',
                  icon: Icons.play_circle_outline_rounded,
                  variant: WoodButtonVariant.forest,
                  height: 44,
                  onPressed: () {
                    Navigator.pop(ctx);
                    RewardAdDialog.show(
                      context,
                      type: RewardType.coins,
                      onRewardClaimed: (type) => _loadProgress(),
                    );
                  },
                ),
              ],
            ),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: ParchmentCard(
              padding: const EdgeInsets.all(18),
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
                        color: const Color(0xFF5D4037).withAlpha(120),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Vocabulary & Meanings',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2A1810),
                        ),
                      ),
                      Text(
                        '${_foundWords.length}/${_currentLevel.words.length} Found',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _currentLevel.words.length,
                      separatorBuilder: (_, _) => const Divider(
                        color: Color(0xFFD7CCC8),
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
                            color: isFound ? const Color(0xFF2E7D32) : const Color(0xFF8D6E63),
                          ),
                          title: Text(
                            item.word,
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isFound
                                  ? const Color(0xFF2A1810)
                                  : const Color(0xFF5D4037),
                              decoration: isFound ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Text(
                            item.meaning,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6D4C41),
                            ),
                          ),
                          trailing: const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFFE65100)),
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
            ),
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
    final worldTheme = WorldTheme.getTheme(_currentChapter.id);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F1),
      body: Stack(
        children: [
          // 1. Storybook Per-World Gradient
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

          // 2. Thematic Decorative Props
          if (worldTheme.decorativeProps.isNotEmpty) ...[
            Positioned(
              left: -10,
              top: 120,
              child: Opacity(
                opacity: 0.22,
                child: Image.asset(
                  worldTheme.decorativeProps.first,
                  width: 80,
                  height: 80,
                  errorBuilder: (ctx, err, stack) => const SizedBox(),
                ),
              ),
            ),
            if (worldTheme.decorativeProps.length > 1)
              Positioned(
                right: -10,
                bottom: 120,
                child: Opacity(
                  opacity: 0.22,
                  child: Image.asset(
                    worldTheme.decorativeProps[1],
                    width: 75,
                    height: 75,
                    errorBuilder: (ctx, err, stack) => const SizedBox(),
                  ),
                ),
              ),
          ],

          // 3. Ambient Particles
          Positioned.fill(
            child: AmbientParticlesOverlay(
              particleCount: 10,
              particleColor: worldTheme.accentColor,
            ),
          ),

          // 4. Main Foreground UI
          SafeArea(
            child: Column(
              children: [
                // Top Header Bar
                _buildTopBar(worldTheme),

                const SizedBox(height: 4),

                // Interactive Word Search Grid
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
                      worldTheme: worldTheme,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Word Bank Chips (Target Words with definitions)
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
                        worldTheme: worldTheme,
                      ),
                    ),
                  ),
                ),

                // Tactile Wooden Booster Buttons
                _buildBottomControls(),

                // Banner Ad at Bottom
                const BannerAdWidget(),
              ],
            ),
          ),

          // Confetti Celebration Fireworks Overlay on Level Win
          if (_isLevelComplete)
            const Positioned.fill(
              child: ConfettiCelebrationOverlay(),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar(WorldTheme worldTheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      child: ParchmentCard(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button
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

            // World & Level Title Center
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
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2A1810),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _currentChapter.id == 9999
                          ? '${DailyPuzzleService.getFormattedDate()} • ${_foundWords.length}/${_currentLevel.words.length} Words'
                          : '${_foundWords.length} of ${_currentLevel.words.length} Words Found',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: worldTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Coins Counter Pill
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
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF5D4037), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFB300), size: 17),
                    const SizedBox(width: 4),
                    Text(
                      '$_coins',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        color: Color(0xFF2A1810),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.add_circle_rounded, color: Color(0xFF2E7D32), size: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      child: Row(
        children: [
          // 1. VOCABULARY BUTTON
          Expanded(
            child: OrganicWoodButton(
              text: 'VOCABULARY',
              icon: Icons.menu_book_rounded,
              variant: WoodButtonVariant.secondary,
              height: 46,
              onPressed: () {
                SoundManager.instance.playButtonClick();
                _openAllWordsSheet();
              },
            ),
          ),
          const SizedBox(width: 8),

          // 2. HINT BUTTON
          Expanded(
            child: OrganicWoodButton(
              text: _hints > 0 ? 'HINT ($_hints)' : 'HINT',
              icon: Icons.lightbulb_rounded,
              variant: WoodButtonVariant.primary,
              height: 46,
              onPressed: () {
                SoundManager.instance.playButtonClick();
                _useHint();
              },
            ),
          ),
          const SizedBox(width: 8),

          // 3. NEXT BUTTON (Skip Booster)
          Expanded(
            child: OrganicWoodButton(
              text: 'NEXT',
              icon: Icons.skip_next_rounded,
              variant: WoodButtonVariant.forest,
              height: 46,
              onPressed: () {
                SoundManager.instance.playButtonClick();
                _useSkipLevelBooster();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLevelCompleteDialog({bool isSkipped = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: ParchmentCard(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration Icon
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isSkipped
                          ? const [Color(0xFF29B6F6), Color(0xFF0288D1)]
                          : const [Color(0xFFFFD54F), Color(0xFFFF9800)],
                    ),
                    border: Border.all(color: const Color(0xFF5D4037), width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2A1810).withAlpha(100),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isSkipped ? Icons.skip_next_rounded : Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  isSkipped ? 'LEVEL SKIPPED!' : 'LEVEL COMPLETE!',
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2A1810),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  isSkipped
                      ? 'You skipped ${_currentChapter.title} Level ${_currentLevel.levelNumber}.'
                      : 'Magnificent job! You found all words in ${_currentChapter.title} Level ${_currentLevel.levelNumber}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 14,
                    color: Color(0xFF5D4037),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),

                // Coins Reward Plaque
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDF5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF5D4037), width: 1.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSkipped ? Icons.remove_circle_outline_rounded : Icons.monetization_on_rounded,
                        color: isSkipped ? const Color(0xFFEF5350) : const Color(0xFFFFB300),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isSkipped ? '-50 COINS USED' : '+10 COINS EARNED',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isSkipped ? const Color(0xFFEF5350) : const Color(0xFF2A1810),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                OrganicWoodButton(
                  text: 'NEXT LEVEL',
                  icon: Icons.arrow_forward_rounded,
                  variant: WoodButtonVariant.forest,
                  height: 50,
                  onPressed: () {
                    Navigator.pop(ctx);
                    AdManager.instance.showInterstitialIfEligible(
                      onAdClosed: () => _loadNextLevel(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
