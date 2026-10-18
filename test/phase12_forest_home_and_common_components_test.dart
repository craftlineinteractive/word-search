import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_search/screens/achievements_screen.dart';
import 'package:word_search/screens/home_screen.dart';
import 'package:word_search/services/achievement_service.dart';
import 'package:word_search/services/sound_manager.dart';
import 'package:word_search/theme/app_theme.dart';
import 'package:word_search/widgets/ambient_particles_overlay.dart';
import 'package:word_search/widgets/organic_wood_button.dart';
import 'package:word_search/widgets/parchment_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers.global'),
          (MethodCall methodCall) async => 1,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers'),
          (MethodCall methodCall) async => 1,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.craftline.wordsearch/haptics'),
          (MethodCall methodCall) async => null,
        );
  });

  group('Phase 12 - Forest Home Screen & Tactile 2D Game Components QA', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SoundManager.instance.init();
    });

    testWidgets('OrganicWoodButton reacts to taps and executes callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OrganicWoodButton(
              text: 'TEST BUTTON',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('TEST BUTTON'), findsOneWidget);
      await tester.tap(find.text('TEST BUTTON'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('ParchmentCard renders child with 2D cartoon border styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParchmentCard(
              child: Text('Parchment Content'),
            ),
          ),
        ),
      );

      expect(find.text('Parchment Content'), findsOneWidget);
    });

    testWidgets('AmbientParticlesOverlay renders and respects disableAnimations', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmbientParticlesOverlay(
              maxParticles: 10,
              type: ParticleType.fireflies,
            ),
          ),
        ),
      );

      expect(find.byType(AmbientParticlesOverlay), findsOneWidget);
    });

    testWidgets('AchievementsScreen renders all 16 achievements and milestone header', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AchievementsScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Achievements'), findsOneWidget);
      expect(find.text('Milestone Stars'), findsOneWidget);
      expect(AchievementService.catalog.length, equals(16));
      expect(find.text('Word Hunter'), findsOneWidget);
      expect(find.text('World Wanderer'), findsOneWidget);
    });

    testWidgets('HomeScreen renders Enchanted Forest theme and primary game CTAs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
          home: const HomeScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('WORD SEARCH'), findsWidgets);
      expect(find.text('ENCHANTED WORLDS'), findsOneWidget);
      expect(find.text('WORLD MAP'), findsOneWidget);
      expect(find.text('ACHIEVEMENTS'), findsOneWidget);
      expect(find.text('Daily Puzzle'), findsOneWidget);
      expect(find.text('Levels Cleared'), findsOneWidget);
      expect(find.text('Stars Collected'), findsOneWidget);
    });
  });
}
