import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import '../screens/shop_screen.dart';
import '../services/ad_manager.dart';
import '../services/sound_manager.dart';
import '../theme/app_theme.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget>
    with LevelPlayBannerAdViewListener {
  final GlobalKey<LevelPlayBannerAdViewState> _bannerKey =
      GlobalKey<LevelPlayBannerAdViewState>();
  bool _isAdLoaded = false;

  bool get _isMobilePlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void dispose() {
    if (_isMobilePlatform) {
      try {
        _bannerKey.currentState?.destroy();
      } catch (_) {}
    }
    super.dispose();
  }

  void _openShopForRemoveAds(BuildContext context) {
    SoundManager.instance.playButtonClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ShopScreen(highlightRemoveAds: true),
      ),
    );
  }

  // ==================== LevelPlayBannerAdViewListener ====================

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    if (mounted) {
      setState(() {
        _isAdLoaded = true;
      });
    }
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    debugPrint('LevelPlay Banner failed: $error');
    if (mounted) {
      setState(() {
        _isAdLoaded = false;
      });
    }
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {}

  @override
  void onAdDisplayFailed(LevelPlayAdInfo adInfo, LevelPlayAdError error) {
    if (mounted) {
      setState(() {
        _isAdLoaded = false;
      });
    }
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {}

  @override
  void onAdExpanded(LevelPlayAdInfo adInfo) {}

  @override
  void onAdCollapsed(LevelPlayAdInfo adInfo) {}

  @override
  void onAdLeftApplication(LevelPlayAdInfo adInfo) {}

  // ==================== UI BUILD ====================

  Widget _buildPlaceholder() {
    return Container(
      height: 50,
      alignment: Alignment.center,
      child: const Text(
        'AD SPACE RESERVED',
        style: TextStyle(
          fontFamily: 'Fredoka',
          color: Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (AdManager.instance.isAdsRemoved) {
      return const SizedBox.shrink();
    }

    final isDark = AppTheme.isDark(context);

    Widget adContent;
    if (!_isMobilePlatform) {
      // Graceful fallback for non-mobile (Desktop/Web/Test environment)
      adContent = _buildPlaceholder();
    } else {
      adContent = SizedBox(
        width: LevelPlayAdSize.BANNER.width.toDouble(),
        height: LevelPlayAdSize.BANNER.height.toDouble(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!_isAdLoaded) _buildPlaceholder(),
            LevelPlayBannerAdView(
              key: _bannerKey,
              adUnitId: AdManager.instance.bannerAdUnitId,
              adSize: LevelPlayAdSize.BANNER,
              listener: this,
              placementName: 'WordSearch_Banner_Main',
              onPlatformViewCreated: () {
                _bannerKey.currentState?.loadAd();
              },
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262D3D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3F4A63) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: adContent,
            ),

            // Top Right Small Close 'X' Button
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0),
                shape: const CircleBorder(),
                elevation: 2,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _openShopForRemoveAds(context),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
