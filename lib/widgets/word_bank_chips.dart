import 'package:flutter/material.dart';
import '../models/placed_word.dart';
import '../models/word_item.dart';
import '../theme/world_theme.dart';

class WordBankChips extends StatelessWidget {
  final List<WordItem> levelWords;
  final List<PlacedWord> foundWords;
  final Function(WordItem wordItem) onWordTap;
  final WorldTheme? worldTheme;

  const WordBankChips({
    super.key,
    required this.levelWords,
    required this.foundWords,
    required this.onWordTap,
    this.worldTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        alignment: WrapAlignment.center,
        children: levelWords.map((wordItem) {
          final cleanTarget = wordItem.word.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
          final foundWord = foundWords.cast<PlacedWord?>().firstWhere(
                (w) => w?.word.toUpperCase() == cleanTarget,
                orElse: () => null,
              );
          final bool isFound = foundWord != null;

          return _buildChip(
            context: context,
            wordItem: wordItem,
            isFound: isFound,
            foundColor: isFound ? Color(foundWord.colorValue) : null,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required WordItem wordItem,
    required bool isFound,
    Color? foundColor,
  }) {
    Color chipBg;
    Color chipBorder;
    Color chipText;
    Color iconColor;

    if (isFound) {
      final solidColor = foundColor ?? const Color(0xFF2E7D32);
      chipBg = solidColor;
      chipBorder = const Color(0xFF2A1810);
      chipText = Colors.white;
      iconColor = Colors.white70;
    } else {
      chipBg = const Color(0xFFFFF9E6);
      chipBorder = worldTheme != null
          ? worldTheme!.gridBorderColor.withAlpha(140)
          : const Color(0xFF8D6E63);
      chipText = const Color(0xFF2A1810);
      iconColor = const Color(0xFF8D6E63);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onWordTap(wordItem),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: chipBorder,
              width: 1.8,
            ),
            boxShadow: [
              if (isFound)
                BoxShadow(
                  color: (foundColor ?? const Color(0xFF2E7D32)).withAlpha(80),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              else
                BoxShadow(
                  color: const Color(0xFF2A1810).withAlpha(20),
                  blurRadius: 3,
                  offset: const Offset(0, 1.5),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isFound)
                const Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              Text(
                wordItem.word,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: chipText,
                  decoration: isFound ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.white,
                  decorationThickness: 2.2,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.help_outline_rounded,
                size: 13,
                color: iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
