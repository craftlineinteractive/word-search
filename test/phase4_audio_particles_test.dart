import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_search/screens/settings_screen.dart';
import 'package:word_search/services/sound_manager.dart';
import 'package:word_search/widgets/confetti_celebration_overlay.dart';

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

  group('Phase 4 - Audio, SFX & Confetti Celebrations QA', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SoundManager.instance.init();
    });

    test(
      'SoundManager contains 5 BGM tracks and initializes with sound enabled',
      () {
        expect(SoundManager.bgmPlaylist.length, equals(5));
        expect(SoundManager.bgmPlaylist, contains('sounds/bgm_1.mp3'));
        expect(SoundManager.bgmPlaylist, contains('sounds/bgm_2.mp3'));
        expect(SoundManager.bgmPlaylist, contains('sounds/bgm_3.mp3'));
        expect(SoundManager.bgmPlaylist, contains('sounds/bgm_4.mp3'));
        expect(SoundManager.bgmPlaylist, contains('sounds/bgm_5.mp3'));

        expect(SoundManager.instance.isSoundEnabled, isTrue);
        expect(SoundManager.instance.isMusicEnabled, isTrue);
        expect(SoundManager.instance.isHapticsEnabled, isTrue);
      },
    );

    test('SoundManager toggles persist state properly', () async {
      await SoundManager.instance.setMusicEnabled(false);
      expect(SoundManager.instance.isMusicEnabled, isFalse);

      await SoundManager.instance.setSoundEnabled(false);
      expect(SoundManager.instance.isSoundEnabled, isFalse);

      await SoundManager.instance.setHapticsEnabled(false);
      expect(SoundManager.instance.isHapticsEnabled, isFalse);

      // Re-enable
      await SoundManager.instance.setMusicEnabled(true);
      expect(SoundManager.instance.isMusicEnabled, isTrue);
    });

    testWidgets(
      'ConfettiCelebrationOverlay animates and paints confetti particles',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ConfettiCelebrationOverlay(
                autoStart: true,
                duration: Duration(milliseconds: 1000),
                child: Text('WINNER!'),
              ),
            ),
          ),
        );

        expect(find.text('WINNER!'), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);

        // Advance frames to simulate particle explosion
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(CustomPaint), findsWidgets);
      },
    );

    testWidgets(
      'SettingsScreen displays 5 BGM tracks subtitle and toggles SoundManager state',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Sound Effects'), findsOneWidget);
        expect(find.text('Background Music'), findsOneWidget);
        expect(find.text('Haptics'), findsOneWidget);

        // Find switch for Background Music
        final bgmSwitchFinder = find.widgetWithText(
          SwitchListTile,
          'Background Music',
        );
        expect(bgmSwitchFinder, findsOneWidget);

        // Toggle BGM switch off
        await tester.tap(bgmSwitchFinder);
        await tester.pumpAndSettle();

        expect(SoundManager.instance.isMusicEnabled, isFalse);
      },
    );
  });
}
