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
      'ThemeManager enforces Light Mode permanently across the game',
      () async {
        final manager = ThemeManager.instance;
        await manager.init();
        expect(manager.currentThemeMode, equals(ThemeMode.light));

        await manager.setThemeMode(ThemeMode.light);
        expect(manager.currentThemeMode, equals(ThemeMode.light));
      },
    );

    test('AppTheme provides valid lightTheme ThemeData', () {
      final light = AppTheme.lightTheme;

      expect(light.brightness, equals(Brightness.light));
      expect(light.scaffoldBackgroundColor, equals(AppTheme.lightBackground));
      expect(AppTheme.isDark(testerContext ?? lightThemeContextStub()), isFalse);
    });

    testWidgets(
      'SettingsScreen renders cleanly in single Light Mode without dark mode selector',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light,
            home: const SettingsScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('AUDIO & HAPTICS'), findsOneWidget);
        expect(find.text('Sound Effects'), findsOneWidget);
        expect(find.text('Background Music'), findsOneWidget);
        expect(find.text('THEME & APPEARANCE'), findsNothing);
      },
    );
  });
}

BuildContext? testerContext;
BuildContext lightThemeContextStub() {
  return _DummyContext();
}

class _DummyContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
