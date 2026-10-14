import 'package:flutter/material.dart';

class AppTheme {
  static const String fontName = 'Fredoka';

  // Soft Lightweight Dark Palette Colors (No harsh pitch black or heavy navy)
  static const Color darkBackground = Color(0xFF1E2430);
  static const Color darkSurface = Color(0xFF262D3D);
  static const Color darkCard = Color(0xFF2D3547);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Light Palette Colors
  static const Color lightBackground = Color(0xFFF0F4F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Vibrant Game Accents
  static const Color accentGolden = Color(0xFFFFD700);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentPink = Color(0xFFFF4081);
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentOrange = Color(0xFFFF9100);

  // Helper getters
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color getBackgroundColor(BuildContext context) {
    return isDark(context) ? darkBackground : lightBackground;
  }

  static Color getSurfaceColor(BuildContext context) {
    return isDark(context) ? darkSurface : lightSurface;
  }

  static Color getCardColor(BuildContext context) {
    return isDark(context) ? darkCard : lightCard;
  }

  static Color getTextPrimaryColor(BuildContext context) {
    return isDark(context) ? darkTextPrimary : lightTextPrimary;
  }

  static Color getTextSecondaryColor(BuildContext context) {
    return isDark(context) ? darkTextSecondary : lightTextSecondary;
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
