import 'package:flutter/material.dart';
import '../models/word_item.dart';
import 'organic_wood_button.dart';
import 'parchment_card.dart';

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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: ParchmentCard(
        padding: const EdgeInsets.all(22),
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
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF5D4037), width: 1.5),
                  ),
                  child: Text(
                    categoryTitle.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFE65100),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF5D4037)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Word Title
            Text(
              wordItem.word.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2A1810),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            // Meaning Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD7CCC8), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.menu_book_rounded, size: 16, color: Color(0xFFFF9800)),
                      SizedBox(width: 6),
                      Text(
                        'MEANING',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    wordItem.meaning,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 14,
                      color: Color(0xFF3E2723),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            if (wordItem.example != null && wordItem.example!.isNotEmpty) ...[
              const SizedBox(height: 10),
              // Example Sentence Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD7CCC8), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, size: 16, color: Color(0xFF2E7D32)),
                        SizedBox(width: 6),
                        Text(
                          'EXAMPLE SENTENCE',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '"${wordItem.example}"',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF5D4037),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 18),

            // Dismiss Button
            OrganicWoodButton(
              text: 'GOT IT!',
              variant: WoodButtonVariant.forest,
              height: 46,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
