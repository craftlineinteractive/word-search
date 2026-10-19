import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/theme_manager.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WordPuzzleApp());
}

class WordPuzzleApp extends StatelessWidget {
  const WordPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.instance.themeModeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Word Search',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}
