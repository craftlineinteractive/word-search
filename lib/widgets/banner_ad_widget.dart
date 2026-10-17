import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../screens/shop_screen.dart';
import '../services/ad_manager.dart';
import '../services/sound_manager.dart';
import '../theme/app_theme.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd({String? overrideUnitId}) {
    if (AdManager.instance.isAdsRemoved) return;

    final unitId = overrideUnitId ?? AdManager.instance.bannerAdUnitId;

    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: unitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('BannerAd failed ($unitId): ${error.message} (code ${error.code})');
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
          }
          // Fallback to test banner unit if production fails before Play Store approval
          if (unitId != AdManager.testBannerAdUnitId) {
            _loadBannerAd(overrideUnitId: AdManager.testBannerAdUnitId);
          }
        },
      ),
    )..load();
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

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AdManager.instance.isAdsRemoved) {
      return const SizedBox.shrink();
    }

    final isDark = AppTheme.isDark(context);

    Widget adContent;
    if (!_isAdLoaded || _bannerAd == null) {
      adContent = Container(
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
    } else {
      adContent = SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
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
