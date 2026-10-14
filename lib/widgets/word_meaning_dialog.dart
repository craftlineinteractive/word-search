import 'package:flutter/material.dart';
import '../models/word_item.dart';
import '../theme/app_theme.dart';
import 'game_3d_button.dart';

class WordMeaningDialog extends StatelessWidget {
  final WordItem wordItem;
  final String categoryTitle;

  const WordMeaningDialog({
    super.key,
    required this.wordItem,
    required this.categoryTitle,
  });

  static void show(BuildContext context, WordItem wordItem, String categoryTitle) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(150),
      builder: (_) => WordMeaningDialog(
        wordItem: wordItem,
        categoryTitle: categoryTitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final textPrimary = AppTheme.getTextPrimaryColor(context);
    final textSecondary = AppTheme.getTextSecondaryColor(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0C1938) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 80 : 25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Badge & Close Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E3A6D) : const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    categoryTitle.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: textSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Word Title
            Text(
              wordItem.word.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: textPrimary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            // Definition Section
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF132347) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E3A6D) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book_rounded, size: 16, color: const Color(0xFFFFB300)),
                      const SizedBox(width: 6),
                      Text(
                        'MEANING',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFB300),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    wordItem.meaning,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            if (wordItem.example != null && wordItem.example!.isNotEmpty) ...[
              const SizedBox(height: 12),
              // Example Sentence Section
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF132347) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E3A6D) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.lightbulb_outline_rounded, size: 16, color: Color(0xFF00E676)),
                        SizedBox(width: 6),
                        Text(
                          'EXAMPLE SENTENCE',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF00E676),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '"${wordItem.example}"',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // 3D Dismiss Button
            Game3dButton(
              color: Game3dButtonColor.blue,
              height: 48,
              text: 'GOT IT!',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
