import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_search/screens/settings_screen.dart';
import 'package:word_search/services/sound_manager.dart';
import 'package:word_search/services/theme_manager.dart';
import 'package:word_search/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers.global'),
          (MethodCall methodCall) async {
            return 1;
          },
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers'),
          (MethodCall methodCall) async {
            return 1;
          },
        );
  });

  group('Phase 7 - Light, Dark & System Theme Modes QA', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SoundManager.instance.init();
      await ThemeManager.instance.init();
    });

    test(
      'ThemeManager defaults to Dark and toggles between Light, Dark, System',
      () async {
        final manager = ThemeManager.instance;
        await manager.init();
        expect(manager.currentThemeMode, equals(ThemeMode.dark));

        await manager.setThemeMode(ThemeMode.light);
        expect(manager.currentThemeMode, equals(ThemeMode.light));

        await manager.setThemeMode(ThemeMode.system);
        expect(manager.currentThemeMode, equals(ThemeMode.system));

        await manager.setThemeMode(ThemeMode.dark);
        expect(manager.currentThemeMode, equals(ThemeMode.dark));
      },
    );

    test('AppTheme provides valid lightTheme and darkTheme ThemeData', () {
      final light = AppTheme.lightTheme;
      final dark = AppTheme.darkTheme;

      expect(light.brightness, equals(Brightness.light));
      expect(dark.brightness, equals(Brightness.dark));

      expect(light.scaffoldBackgroundColor, equals(AppTheme.lightBackground));
      expect(dark.scaffoldBackgroundColor, equals(AppTheme.darkBackground));
    });

    testWidgets(
      'SettingsScreen displays System, Light, and Dark theme cards and switches theme on tap',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: const SettingsScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('THEME & APPEARANCE'), findsOneWidget);
        expect(find.text('System'), findsOneWidget);
        expect(find.text('Light'), findsOneWidget);
        expect(find.text('Dark'), findsOneWidget);

        // Tap Light Mode Card
        final lightCard = find.widgetWithText(InkWell, 'Light');
        expect(lightCard, findsOneWidget);
        await tester.tap(lightCard);
        await tester.pumpAndSettle();

        expect(ThemeManager.instance.currentThemeMode, equals(ThemeMode.light));

        // Tap Dark Mode Card
        final darkCard = find.widgetWithText(InkWell, 'Dark');
        expect(darkCard, findsOneWidget);
        await tester.tap(darkCard);
        await tester.pumpAndSettle();

        expect(ThemeManager.instance.currentThemeMode, equals(ThemeMode.dark));
      },
    );
  });
}
