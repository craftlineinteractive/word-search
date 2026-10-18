import 'package:flutter/material.dart';

/// Defines visual and stylistic attributes for each of the 30 unique Worlds.
/// Preserves the warm 2D cartoon storybook art style while offering rich,
/// immersive environmental flavor per world.
class WorldTheme {
  final int worldId;
  final String title;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color boardBackgroundColor;
  final Color cellBackgroundColor;
  final Color cellSelectedColor;
  final Color letterColor;
  final Color gridBorderColor;
  final Color chipBackgroundColor;
  final Color chipTextColor;
  final Color chipFoundBackgroundColor;
  final Color chipFoundTextColor;
  final List<Color> backgroundGradient;
  final String ambientParticleType; // 'fireflies', 'crumbs', 'leaves', 'bubbles', 'sparkles', 'pollen'
  final List<String> decorativeProps;
  final String flavorQuote;

  const WorldTheme({
    required this.worldId,
    required this.title,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.boardBackgroundColor,
    required this.cellBackgroundColor,
    required this.cellSelectedColor,
    required this.letterColor,
    required this.gridBorderColor,
    required this.chipBackgroundColor,
    required this.chipTextColor,
    required this.chipFoundBackgroundColor,
    required this.chipFoundTextColor,
    required this.backgroundGradient,
    required this.ambientParticleType,
    this.decorativeProps = const [],
    this.flavorQuote = '',
  });

  /// Default Forest Theme for global screens (Home, World Map, Settings)
  static const WorldTheme forest = WorldTheme(
    worldId: 0,
    title: 'Enchanted Forest',
    primaryColor: Color(0xFF2E7D32),
    secondaryColor: Color(0xFF4CAF50),
    accentColor: Color(0xFFFFD54F),
    boardBackgroundColor: Color(0xFFFFFDF5),
    cellBackgroundColor: Color(0xFFF3ECE0),
    cellSelectedColor: Color(0xFFA5D6A7),
    letterColor: Color(0xFF2A1810),
    gridBorderColor: Color(0xFF5D4037),
    chipBackgroundColor: Color(0xFFE8F5E9),
    chipTextColor: Color(0xFF1B5E20),
    chipFoundBackgroundColor: Color(0xFF4CAF50),
    chipFoundTextColor: Colors.white,
    backgroundGradient: [
      Color(0xFFE8F5E9),
      Color(0xFFC8E6C9),
      Color(0xFFA5D6A7),
    ],
    ambientParticleType: 'fireflies',
    decorativeProps: [
      'assets/game_art/shared/forest/forest_bush.png',
      'assets/game_art/shared/forest/forest_mushroom_red.png',
      'assets/game_art/shared/forest/forest_mushroom_brown.png',
    ],
    flavorQuote: 'Step into the tranquil Whispering Woods where ancient letters flourish.',
  );

  /// Retrieves the customized [WorldTheme] for any given World ID (1 through 30).
  static WorldTheme getTheme(int worldId) {
    switch (worldId) {
      // 1. Food: Warm Bakery & Orchard Feast
      case 1:
        return const WorldTheme(
          worldId: 1,
          title: 'Food',
          primaryColor: Color(0xFFE65100),
          secondaryColor: Color(0xFFFFA726),
          accentColor: Color(0xFFFFB300),
          boardBackgroundColor: Color(0xFFFFF9E6),
          cellBackgroundColor: Color(0xFFFEEBC8),
          cellSelectedColor: Color(0xFFFFCC80),
          letterColor: Color(0xFF3E2723),
          gridBorderColor: Color(0xFF8D4E24),
          chipBackgroundColor: Color(0xFFFFF3E0),
          chipTextColor: Color(0xFFBF360C),
          chipFoundBackgroundColor: Color(0xFFFF9800),
          chipFoundTextColor: Colors.white,
          backgroundGradient: [
            Color(0xFFFFF3E0),
            Color(0xFFFFE0B2),
            Color(0xFFFFCC80),
          ],
          ambientParticleType: 'crumbs',
          decorativeProps: [
            'assets/game_art/worlds/w01_food/food_apple.png',
            'assets/game_art/worlds/w01_food/food_bread.png',
            'assets/game_art/worlds/w01_food/food_soup.png',
          ],
          flavorQuote: 'A delectable feast of flavors, fresh bread, and crisp apples!',
        );

      // 2. Holiday: Festive Celebration & Warm Lights
      case 2:
        return const WorldTheme(
          worldId: 2,
          title: 'Holiday',
          primaryColor: Color(0xFFC62828),
          secondaryColor: Color(0xFF00897B),
          accentColor: Color(0xFFFFD54F),
          boardBackgroundColor: Color(0xFFFFFDF7),
          cellBackgroundColor: Color(0xFFFFEBEE),
          cellSelectedColor: Color(0xFFB2DFDB),
          letterColor: Color(0xFF212121),
          gridBorderColor: Color(0xFF7B1FA2),
          chipBackgroundColor: Color(0xFFE0F2F1),
          chipTextColor: Color(0xFF004D40),
          chipFoundBackgroundColor: Color(0xFF00897B),
          chipFoundTextColor: Colors.white,
          backgroundGradient: [
            Color(0xFFE0F2F1),
            Color(0xFFFFEBEE),
            Color(0xFFFFCDD2),
          ],
          ambientParticleType: 'sparkles',
          decorativeProps: [
            'assets/game_art/shared/effects/fx_sparkle.png',
            'assets/game_art/shared/forest/forest_mushroom_red.png',
          ],
          flavorQuote: 'Twinkling lights and festive cheer fill the joyous air.',
        );

      // 3. Jobs: Industrious Workshop & Busy Craft
      case 3:
        return const WorldTheme(
          worldId: 3,
          title: 'Jobs',
          primaryColor: Color(0xFF283593),
          secondaryColor: Color(0xFF5C6BC0),
          accentColor: Color(0xFFFFC107),
          boardBackgroundColor: Color(0xFFF9FAFB),
          cellBackgroundColor: Color(0xFFE8EAF6),
          cellSelectedColor: Color(0xFFC5CAE9),
          letterColor: Color(0xFF1A237E),
          gridBorderColor: Color(0xFF3949AB),
          chipBackgroundColor: Color(0xFFE8EAF6),
          chipTextColor: Color(0xFF1A237E),
          chipFoundBackgroundColor: Color(0xFF3949AB),
          chipFoundTextColor: Colors.white,
          backgroundGradient: [
            Color(0xFFE8EAF6),
            Color(0xFFC5CAE9),
            Color(0xFF9FA8DA),
          ],
          ambientParticleType: 'spores',
          decorativeProps: [
            'assets/game_art/shared/ui/ui_panel_brown.png',
          ],
          flavorQuote: 'Tools clatter and blueprints unfold in the busy artisan workshop.',
        );

      // 4. Electronics: Circuit Grid & Neon Glow
      case 4:
        return const WorldTheme(
          worldId: 4,
          title: 'Electronics',
          primaryColor: Color(0xFF00838F),
          secondaryColor: Color(0xFF00ACC1),
          accentColor: Color(0xFF00E5FF),
          boardBackgroundColor: Color(0xFFF0FDF4),
          cellBackgroundColor: Color(0xFFE0F7FA),
          cellSelectedColor: Color(0xFF80DEEA),
          letterColor: Color(0xFF004D40),
          gridBorderColor: Color(0xFF006064),
          chipBackgroundColor: Color(0xFFE0F7FA),
          chipTextColor: Color(0xFF006064),
          chipFoundBackgroundColor: Color(0xFF00ACC1),
          chipFoundTextColor: Colors.white,
          backgroundGradient: [
            Color(0xFFE0F7FA),
            Color(0xFFB2EBF2),
            Color(0xFF80DEEA),
          ],
          ambientParticleType: 'sparkles',
          decorativeProps: [
            'assets/game_art/shared/effects/fx_sparkle.png',
          ],
          flavorQuote: 'Current pulses through glowing microchips and shining relays.',
        );

      // 5. Books: Grand Ancient Library & Parchment
      case 5:
        return const WorldTheme(
          worldId: 5,
          title: 'Books',
          primaryColor: Color(0xFF5D4037),
          secondaryColor: Color(0xFF8D6E63),
          accentColor: Color(0xFFFFB300),
          boardBackgroundColor: Color(0xFFFFFDF5),
          cellBackgroundColor: Color(0xFFEFEBE9),
          cellSelectedColor: Color(0xFFD7CCC8),
          letterColor: Color(0xFF3E2723),
          gridBorderColor: Color(0xFF4E342E),
          chipBackgroundColor: Color(0xFFEFEBE9),
          chipTextColor: Color(0xFF3E2723),
          chipFoundBackgroundColor: Color(0xFF8D6E63),
          chipFoundTextColor: Colors.white,
          backgroundGradient: [
            Color(0xFFEFEBE9),
            Color(0xFFD7CCC8),
            Color(0xFFBCAAA4),
          ],
          ambientParticleType: 'spores',
          decorativeProps: [
            'assets/game_art/shared/ui/ui_panel_beige.png',
          ],
          flavorQuote: 'Endless towering bookshelves brimming with forgotten lore.',
        );

      // 6. Games: Playful Arcade & Vibrant Blocks
      case 6:
        return const WorldTheme(
          worldId: 6,
          title: 'Games',
          primaryColor: Color(0xFF6A1B9A),
          secondaryColor: Color(0xFFAB47BC),
          accentColor: Color(0xFFFFEB3B),
          boardBackgroundColor: Color(0xFFFAF5FF),
          cellBackgroundColor: Color(0xFFF3E5F5),
          cellSelectedColor: Color(0xFFE1BEE7),
          letterColor: Color(0xFF4A148C),
          gridBorderColor: Color(0xFF7B1FA2),
          chipBackgroundColor: Color(0xFFF3E5F5),
          chipTextColor: Color(0xFF4A148C),
          chipFoundBackgroundColor: Color(0xFFAB47BC),
          chipFoundTextColor: Colors.white,
          backgroundGradient: [
            Color(0xFFF3E5F5),
            Color(0xFFE1BEE7),
            Color(0xFFCE93D8),
          ],
          ambientParticleType: 'sparkles',
          decorativeProps: [
            'assets/game_art/shared/ui/ui_star_gold.png',
          ],
          flavorQuote: 'Roll the dice, press start, and jump into the colorful arena!',
        );

      // 7. Plants: Botanical Gardens & Lush Vines
      case 7:
        return const WorldTheme(
          worldId: 7,
          title: 'Plants',
          primaryColor: Color(0xFF2E7D32),
          secondaryColor: Color(0xFF66BB6A),
          accentColor: Color(0xFFFFEE58),
          boardBackgroundColor: Color(0xFFF1F8E9),
          cellBackgroundColor: Color(0xFFDCEDC8),
          cellSelectedColor: Color(0xFFC5E1A5),
          letterColor: Color(0xFF1B5E20),
          gridBorderColor: Color(0xFF33691E),
          chipBackgroundColor: Color(0xFFDCEDC8),
          chipTextColor: Color(0xFF1B5E20),
          chipFoundBackgroundColor: Color(0xFF4CAF50),
          chipFoundTextColor: Colors.white,
          backgroundGradient: [
            Color(0xFFDCEDC8),
            Color(0xFFC5E1A5),
            Color(0xFFAED581),
          ],
          ambientParticleType: 'leaves',
          decorativeProps: [
            'assets/game_art/shared/forest/forest_bush.png',
            'assets/game_art/shared/forest/forest_mushroom_brown.png',
          ],
          flavorQuote: 'Verdant leaves unfold in the sunlit botanical sanctuary.',
        );

      // 8. Painting: Artist Studio & Palette Splatters
      case 8:
        return const WorldTheme(
          worldId: 8,
          title: 'Painting',
          primaryColor: Color(0xFFE65100),
          secondaryColor: Color(0xFFFF9800),
          accentColor: Color(0xFF00E676),
          boardBackgroundColor: Color(0xFFFFFBF0),
          cellBackgroundColor: Color(0xFFFFF3E0),
          cellSelectedColor: Color(0xFFFFE0B2),
          letterColor: Color(0xFFBF360C),
          gridBorderColor: Color(0xFFE65100),
          chipBackgroundColor: Color(0xFFFFF3E0),
          chipTextColor: Color(0xFFBF360C),
          chipFoundBackgroundColor: Color(0xFFFF9800),
          chipFoundTextColor: Colors.white,
          backgroundGradient: [
            Color(0xFFFFF3E0),
            Color(0xFFFFE0B2),
            Color(0xFFFFCC80),
          ],
          ambientParticleType: 'sparkles',
          decorativeProps: [
            'assets/game_art/shared/ui/ui_panel_beige.png',
          ],
          flavorQuote: 'Vibrant oils and watercolors dance across the canvas.',
        );

      // 14. Nature: Forest Wilds & Mountain Streams
      case 14:
        return const WorldTheme(
          worldId: 14,
          title: 'Nature',
          primaryColor: Color(0xFF1B5E20),
          secondaryColor: Color(0xFF43A047),
          accentColor: Color(0xFFFFD54F),
          boardBackgroundColor: Color(0xFFF1F8E9),
          cellBackgroundColor: Color(0xFFDCEDC8),
          cellSelectedColor: Color(0xFFA5D6A7),
          letterColor: Color(0xFF1B5E20),
          gridBorderColor: Color(0xFF2E7D32),
          chipBackgroundColor: Color(0xFFE8F5E9),
          chipTextColor: Color(0xFF1B5E20),
          chipFoundBackgroundColor: Color(0xFF43A047),
          chipFoundTextColor: Colors.white,
          backgroundGradient: [
            Color(0xFFE8F5E9),
            Color(0xFFC8E6C9),
            Color(0xFFA5D6A7),
          ],
          ambientParticleType: 'leaves',
          decorativeProps: [
            'assets/game_art/shared/forest/forest_tree_pine.png',
            'assets/game_art/shared/forest/forest_bush.png',
          ],
          flavorQuote: 'Breathe the crisp alpine breeze under the grand pine canopies.',
        );

      // 18. Birds: Aviary Heights & Feathered Skies
      case 18:
        return const WorldTheme(
          worldId: 18,
          title: 'Birds',
          primaryColor: Color(0xFF0277BD),
          secondaryColor: Color(0xFF29B6F6),
          accentColor: Color(0xFFFFEE58),
          boardBackgroundColor: Color(0xFFF0F9FF),
          cellBackgroundColor: Color(0xFFE1F5FE),
          cellSelectedColor: Color(0xFFB3E5FC),
          letterColor: Color(0xFF01579B),
          gridBorderColor: Color(0xFF0288D1),
          chipBackgroundColor: Color(0xFFE1F5FE),
          chipTextColor: Color(0xFF01579B),
          chipFoundBackgroundColor: Color(0xFF0288D1),
          chipFoundTextColor: Colors.white,
          backgroundGradient: [
            Color(0xFFE1F5FE),
            Color(0xFFB3E5FC),
            Color(0xFF81D4FA),
          ],
          ambientParticleType: 'pollen',
          decorativeProps: [
            'assets/game_art/shared/animals/animal_chick.png',
            'assets/game_art/shared/forest/forest_cloud1.png',
          ],
          flavorQuote: 'Soar high above the treetops alongside joyful singing birds.',
        );

      // 19. Weather: Sky Breeze & Drifting Clouds
      case 19:
        return const WorldTheme(
          worldId: 19,
          title: 'Weather',
          primaryColor: Color(0xFF00838F),
          secondaryColor: Color(0xFF26C6DA),
          accentColor: Color(0xFFFFD54F),
          boardBackgroundColor: Color(0xFFF0FDFA),
          cellBackgroundColor: Color(0xFFE0F7FA),
          cellSelectedColor: Color(0xFFB2EBF2),
          letterColor: Color(0xFF006064),
          gridBorderColor: Color(0xFF00838F),
          chipBackgroundColor: Color(0xFFE0F7FA),
          chipTextColor: Color(0xFF006064),
          chipFoundBackgroundColor: Color(0xFF00ACC1),
          chipFoundTextColor: Colors.white,
          backgroundGradient: [
            Color(0xFFE0F7FA),
            Color(0xFFB2EBF2),
            Color(0xFF80DEEA),
          ],
          ambientParticleType: 'sparkles',
          decorativeProps: [
            'assets/game_art/shared/forest/forest_cloud1.png',
            'assets/game_art/shared/forest/forest_cloud2.png',
          ],
          flavorQuote: 'Gentle raindrops, billowing clouds, and dazzling rainbows.',
        );

      // 20. Ocean: Coral Reef & Sunlit Shallows
      case 20:
        return const WorldTheme(
          worldId: 20,
          title: 'Ocean',
          primaryColor: Color(0xFF01579B),
          secondaryColor: Color(0xFF0288D1),
          accentColor: Color(0xFF00E5FF),
          boardBackgroundColor: Color(0xFFF0F9FF),
          cellBackgroundColor: Color(0xFFE0F7FA),
          cellSelectedColor: Color(0xFF80DEEA),
          letterColor: Color(0xFF004D40),
          gridBorderColor: Color(0xFF006064),
          chipBackgroundColor: Color(0xFFE0F7FA),
          chipTextColor: Color(0xFF006064),
          chipFoundBackgroundColor: Color(0xFF0097A7),
          chipFoundTextColor: Colors.white,
          backgroundGradient: [
            Color(0xFFE0F7FA),
            Color(0xFFB2EBF2),
            Color(0xFF4DD0E1),
          ],
          ambientParticleType: 'bubbles',
          decorativeProps: [
            'assets/game_art/shared/animals/animal_duck.png',
          ],
          flavorQuote: 'Dive into shimmering azure waves and discover coral secrets.',
        );

      // 22. Pets: Cozy Home & Playful Companions
      case 22:
        return const WorldTheme(
          worldId: 22,
          title: 'Pets',
          primaryColor: Color(0xFFE65100),
          secondaryColor: Color(0xFFFFA726),
          accentColor: Color(0xFFFFD54F),
          boardBackgroundColor: Color(0xFFFFFBEA),
          cellBackgroundColor: Color(0xFFFFF3E0),
          cellSelectedColor: Color(0xFFFFCC80),
          letterColor: Color(0xFF4E342E),
          gridBorderColor: Color(0xFF8D4E24),
          chipBackgroundColor: Color(0xFFFFF3E0),
          chipTextColor: Color(0xFFBF360C),
          chipFoundBackgroundColor: Color(0xFFFFA726),
          chipFoundTextColor: Colors.white,
          backgroundGradient: [
            Color(0xFFFFF3E0),
            Color(0xFFFFE0B2),
            Color(0xFFFFCC80),
          ],
          ambientParticleType: 'pollen',
          decorativeProps: [
            'assets/game_art/shared/animals/animal_chick.png',
          ],
          flavorQuote: 'Gentle purrs and happy wagging tails warm the hearth.',
        );

      // 26. Wild Animals: Safari Plains & Forest Kin
      case 26:
        return const WorldTheme(
          worldId: 26,
          title: 'Wild Animals',
          primaryColor: Color(0xFFBF360C),
          secondaryColor: Color(0xFFFF7043),
          accentColor: Color(0xFFFFD54F),
          boardBackgroundColor: Color(0xFFFFF8F0),
          cellBackgroundColor: Color(0xFFFBE9E7),
          cellSelectedColor: Color(0xFFFFCCBC),
          letterColor: Color(0xFF3E2723),
          gridBorderColor: Color(0xFF8D4E24),
          chipBackgroundColor: Color(0xFFFBE9E7),
          chipTextColor: Color(0xFFBF360C),
          chipFoundBackgroundColor: Color(0xFFFF7043),
          chipFoundTextColor: Colors.white,
          backgroundGradient: [
            Color(0xFFFBE9E7),
            Color(0xFFFFCCBC),
            Color(0xFFFFAB91),
          ],
          ambientParticleType: 'leaves',
          decorativeProps: [
            'assets/game_art/shared/animals/animal_bear.png',
          ],
          flavorQuote: 'Mighty beasts roam free across the sun-drenched savannah.',
        );

      // 30. Fantasy: Celestial Summit & Starlight Magic
      case 30:
        return const WorldTheme(
          worldId: 30,
          title: 'Fantasy',
          primaryColor: Color(0xFF4A148C),
          secondaryColor: Color(0xFF8E24AA),
          accentColor: Color(0xFFFFD700),
          boardBackgroundColor: Color(0xFFFBF5FF),
          cellBackgroundColor: Color(0xFFF3E5F5),
          cellSelectedColor: Color(0xFFE1BEE7),
          letterColor: Color(0xFF311B92),
          gridBorderColor: Color(0xFF6A1B9A),
          chipBackgroundColor: Color(0xFFF3E5F5),
          chipTextColor: Color(0xFF4A148C),
          chipFoundBackgroundColor: Color(0xFF8E24AA),
          chipFoundTextColor: Colors.white,
          backgroundGradient: [
            Color(0xFFF3E5F5),
            Color(0xFFE1BEE7),
            Color(0xFFCE93D8),
          ],
          ambientParticleType: 'sparkles',
          decorativeProps: [
            'assets/game_art/shared/effects/fx_sparkle.png',
            'assets/game_art/shared/ui/ui_star_gold.png',
          ],
          flavorQuote: 'The grand summit where ancient stars whisper the secrets of creation.',
        );

      // Default fallback for any other world (9-13, 15-17, 21, 23-25, 27-29)
      default:
        final bool isWarm = worldId % 2 == 1;
        return WorldTheme(
          worldId: worldId,
          title: 'World $worldId',
          primaryColor: isWarm ? const Color(0xFFE65100) : const Color(0xFF1976D2),
          secondaryColor: isWarm ? const Color(0xFFFFA726) : const Color(0xFF42A5F5),
          accentColor: const Color(0xFFFFD54F),
          boardBackgroundColor: const Color(0xFFFFFDF5),
          cellBackgroundColor: isWarm ? const Color(0xFFFFF3E0) : const Color(0xFFE3F2FD),
          cellSelectedColor: isWarm ? const Color(0xFFFFCC80) : const Color(0xFF90CAF9),
          letterColor: const Color(0xFF2A1810),
          gridBorderColor: const Color(0xFF5D4037),
          chipBackgroundColor: isWarm ? const Color(0xFFFFF3E0) : const Color(0xFFE3F2FD),
          chipTextColor: isWarm ? const Color(0xFFBF360C) : const Color(0xFF0D47A1),
          chipFoundBackgroundColor: isWarm ? const Color(0xFFFFA726) : const Color(0xFF42A5F5),
          chipFoundTextColor: Colors.white,
          backgroundGradient: isWarm
              ? const [Color(0xFFFFF3E0), Color(0xFFFFE0B2), Color(0xFFFFCC80)]
              : const [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFF90CAF9)],
          ambientParticleType: isWarm ? 'fireflies' : 'sparkles',
          decorativeProps: const [
            'assets/game_art/shared/forest/forest_bush.png',
          ],
          flavorQuote: 'Uncover hidden mysteries in World $worldId.',
        );
    }
  }
}
