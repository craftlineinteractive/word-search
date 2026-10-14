import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/ad_manager.dart';
import 'services/iap_manager.dart';
import 'services/sound_manager.dart';
import 'services/theme_manager.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SoundManager.instance.init();
  await ThemeManager.instance.init();
  await AdManager.instance.init();
  await IapManager.instance.init();
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
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
