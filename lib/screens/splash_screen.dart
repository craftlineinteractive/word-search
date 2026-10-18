import 'dart:async';
import 'package:flutter/material.dart';
import '../services/ad_manager.dart';
import '../services/iap_manager.dart';
import '../services/sound_manager.dart';
import '../services/theme_manager.dart';
import '../widgets/ambient_particles_overlay.dart';
import '../widgets/craftline_branding.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _iconScaleAnim;
  late final Animation<double> _iconFadeAnim;
  late final Animation<double> _logoZoomAnim;
  late final Animation<double> _logoFadeAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _iconScaleAnim = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.70, curve: Curves.easeOutBack),
      ),
    );

    _iconFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    // Bottom Craftline Logo: Small to zoom-in animation
    _logoZoomAnim = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.20, 0.90, curve: Curves.easeOutBack),
      ),
    );

    _logoFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.15, 0.60, curve: Curves.easeIn),
      ),
    );

    _animController.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    final startTime = DateTime.now();

    // Fast, concurrent non-blocking initialization of all core services
    try {
      await Future.wait([
        SoundManager.instance.init(),
        ThemeManager.instance.init(),
        AdManager.instance.init(),
        IapManager.instance.init(),
      ]);
    } catch (_) {}

    // Ensure splash display lasts around 3.5 seconds (3 to 4 sec per user request)
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    if (elapsed < 3500) {
      await Future.delayed(Duration(milliseconds: 3500 - elapsed));
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const HomeScreen(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Creative Light Storybook Gradient Backdrop
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.50, 1.0],
                  colors: [
                    Color(0xFFE0F2FE), // Soft Morning Sky
                    Color(0xFFFEFCE8), // Warm Sunlight Cream
                    Color(0xFFFFFBEB), // Light Storybook Parchment
                  ],
                ),
              ),
            ),
          ),

          // 2. Ambient Floating Sunlight Fireflies Particles
          const Positioned.fill(
            child: AmbientParticlesOverlay(
              maxParticles: 10,
              type: ParticleType.fireflies,
            ),
          ),

          // 3. Main Center Content: Game Icon & Title
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Spacer(flex: 3),

                  // App Icon with smooth scale & gentle shadow
                  FadeTransition(
                    opacity: _iconFadeAnim,
                    child: ScaleTransition(
                      scale: _iconScaleAnim,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2A1810).withAlpha(45),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.asset(
                            'assets/images/word_search_icon.png',
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              color: const Color(0xFFFFB300),
                              child: const Icon(
                                Icons.grid_view_rounded,
                                size: 54,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Game Title
                  FadeTransition(
                    opacity: _iconFadeAnim,
                    child: Column(
                      children: [
                        Text(
                          'WORD SEARCH',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: const Color(0xFF2A1810),
                            shadows: [
                              Shadow(
                                color: const Color(0xFF2A1810).withAlpha(30),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B5E20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'ENCHANTED WORLDS',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 4),

                  // 4. Bottom Small Animated Craftline Interactive Company Logo
                  FadeTransition(
                    opacity: _logoFadeAnim,
                    child: ScaleTransition(
                      scale: _logoZoomAnim,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: const CraftlineLogo(
                          width: 156,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
