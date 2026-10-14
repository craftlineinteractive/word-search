import 'package:flutter/material.dart';
import '../models/placed_word.dart';
import '../models/word_item.dart';
import '../theme/app_theme.dart';

class WordBankChips extends StatelessWidget {
  final List<WordItem> levelWords;
  final List<PlacedWord> foundWords;
  final Function(WordItem wordItem) onWordTap;

  const WordBankChips({
    super.key,
    required this.levelWords,
    required this.foundWords,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

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
            isDark: isDark,
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
    required bool isDark,
    Color? foundColor,
  }) {
    Color chipBg;
    Color chipBorder;
    Color chipText;
    Color iconColor;

    if (isFound) {
      // Solid, rich "hard" color matching the word on the grid
      final solidColor = foundColor ?? const Color(0xFF2563EB);
      chipBg = solidColor;
      chipBorder = solidColor;
      chipText = Colors.white;
      iconColor = Colors.white70;
    } else {
      chipBg = isDark ? const Color(0xFF262D3D).withAlpha(180) : Colors.white;
      chipBorder = isDark ? const Color(0xFF3F4A63) : const Color(0xFFCBD5E1);
      chipText = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A);
      iconColor = isDark ? Colors.white30 : const Color(0xFF94A3B8);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onWordTap(wordItem),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: chipBorder,
              width: 1.5,
            ),
            boxShadow: [
              if (isFound)
                BoxShadow(
                  color: (foundColor ?? const Color(0xFF2563EB)).withAlpha(isDark ? 90 : 60),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              else if (!isDark)
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isFound)
                const Padding(
                  padding: EdgeInsets.only(right: 6.0),
                  child: Icon(
                    Icons.check_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              Text(
                wordItem.word,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: chipText,
                  decoration: isFound ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.white,
                  decorationThickness: 2.0,
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
