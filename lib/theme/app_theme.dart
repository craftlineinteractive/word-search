import 'package:flutter/material.dart';

class AppTheme {
  static const String fontName = 'Fredoka';

  // Light Palette Colors (Warm Enchanted Forest & Tactile Cartoon Theme)
  static const Color lightBackground = Color(0xFFFBF8F1);
  static const Color lightSurface = Color(0xFFFFFDF8);
  static const Color lightCard = Color(0xFFF3ECE0);
  static const Color lightTextPrimary = Color(0xFF2A1810);
  static const Color lightTextSecondary = Color(0xFF6B584E);

  // Fallback compatibility tokens
  static const Color darkBackground = lightBackground;
  static const Color darkSurface = lightSurface;
  static const Color darkCard = lightCard;
  static const Color darkTextPrimary = lightTextPrimary;
  static const Color darkTextSecondary = lightTextSecondary;

  // Vibrant Game Accents
  static const Color accentGolden = Color(0xFFFFB300);
  static const Color accentGreen = Color(0xFF16A34A);
  static const Color accentPink = Color(0xFFF43F5E);
  static const Color accentCyan = Color(0xFF0284C7);
  static const Color accentOrange = Color(0xFFEA580C);
  static const Color accentWood = Color(0xFF8B5A2B);

  // Helper getters - Single Light Mode Enforced
  static bool isDark(BuildContext context) {
    return false;
  }

  static Color getBackgroundColor(BuildContext context) {
    return lightBackground;
  }

  static Color getSurfaceColor(BuildContext context) {
    return lightSurface;
  }

  static Color getCardColor(BuildContext context) {
    return lightCard;
  }

  static Color getTextPrimaryColor(BuildContext context) {
    return lightTextPrimary;
  }

  static Color getTextSecondaryColor(BuildContext context) {
    return lightTextSecondary;
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontName,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: accentGolden,
        secondary: accentGreen,
        surface: darkSurface,
        error: accentPink,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: fontName, fontWeight: FontWeight.bold, color: darkTextPrimary),
        displayMedium: TextStyle(fontFamily: fontName, fontWeight: FontWeight.bold, color: darkTextPrimary),
        displaySmall: TextStyle(fontFamily: fontName, fontWeight: FontWeight.bold, color: darkTextPrimary),
        headlineLarge: TextStyle(fontFamily: fontName, fontWeight: FontWeight.bold, color: darkTextPrimary),
        headlineMedium: TextStyle(fontFamily: fontName, fontWeight: FontWeight.bold, color: darkTextPrimary),
        headlineSmall: TextStyle(fontFamily: fontName, fontWeight: FontWeight.bold, color: darkTextPrimary),
        titleLarge: TextStyle(fontFamily: fontName, fontWeight: FontWeight.w600, color: darkTextPrimary),
        titleMedium: TextStyle(fontFamily: fontName, fontWeight: FontWeight.w600, color: darkTextPrimary),
        titleSmall: TextStyle(fontFamily: fontName, fontWeight: FontWeight.w500, color: darkTextPrimary),
        bodyLarge: TextStyle(fontFamily: fontName, fontWeight: FontWeight.normal, color: darkTextPrimary),
        bodyMedium: TextStyle(fontFamily: fontName, fontWeight: FontWeight.normal, color: darkTextSecondary),
        bodySmall: TextStyle(fontFamily: fontName, fontWeight: FontWeight.normal, color: darkTextSecondary),
        labelLarge: TextStyle(fontFamily: fontName, fontWeight: FontWeight.bold, color: darkTextPrimary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontName,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        iconTheme: IconThemeData(color: darkTextPrimary),
      ),
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontName,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1E88E5),
        secondary: Color(0xFF00C853),
        surface: lightSurface,
        error: accentPink,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: fontName, fontWeight: FontWeight.bold, color: lightTextPrimary),
        displayMedium: TextStyle(fontFamily: fontName, fontWeight: FontWeight.bold, color: lightTextPrimary),
        displaySmall: TextStyle(fontFamily: fontName, fontWeight: FontWeight.bold, color: lightTextPrimary),
        headlineLarge: TextStyle(fontFamily: fontName, fontWeight: FontWeight.bold, color: lightTextPrimary),
        headlineMedium: TextStyle(fontFamily: fontName, fontWeight: FontWeight.bold, color: lightTextPrimary),
        headlineSmall: TextStyle(fontFamily: fontName, fontWeight: FontWeight.bold, color: lightTextPrimary),
        titleLarge: TextStyle(fontFamily: fontName, fontWeight: FontWeight.w600, color: lightTextPrimary),
        titleMedium: TextStyle(fontFamily: fontName, fontWeight: FontWeight.w600, color: lightTextPrimary),
        titleSmall: TextStyle(fontFamily: fontName, fontWeight: FontWeight.w500, color: lightTextPrimary),
        bodyLarge: TextStyle(fontFamily: fontName, fontWeight: FontWeight.normal, color: lightTextPrimary),
        bodyMedium: TextStyle(fontFamily: fontName, fontWeight: FontWeight.normal, color: lightTextSecondary),
        bodySmall: TextStyle(fontFamily: fontName, fontWeight: FontWeight.normal, color: lightTextSecondary),
        labelLarge: TextStyle(fontFamily: fontName, fontWeight: FontWeight.bold, color: lightTextPrimary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontName,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: lightTextPrimary,
        ),
        iconTheme: IconThemeData(color: lightTextPrimary),
      ),
    );
  }

  // Backwards compatibility getter
  static ThemeData get gameTheme => darkTheme;
}
