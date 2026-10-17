import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'sound_manager.dart';

class AdManager {
  static final AdManager instance = AdManager._internal();

  factory AdManager() => instance;

  AdManager._internal();

  // ==================== AD UNIT IDS ====================
  // Production AdMob IDs provided by user:
  static const String prodAppId = 'ca-app-pub-9274756665778143~5857930867';
  static const String prodBannerAdUnitId = 'ca-app-pub-9274756665778143/7578206649';
  static const String prodInterstitialAdUnitId = 'ca-app-pub-9274756665778143/4952043301';
  static const String prodRewardedAdUnitId = 'ca-app-pub-9274756665778143/7902385139';

  // Google Test Ad Unit IDs (used as safe fallback during development/testing)
  static const String testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  String get bannerAdUnitId => kDebugMode ? testBannerAdUnitId : prodBannerAdUnitId;
  String get interstitialAdUnitId => kDebugMode ? testInterstitialAdUnitId : prodInterstitialAdUnitId;
  String get rewardedAdUnitId => kDebugMode ? testRewardedAdUnitId : prodRewardedAdUnitId;

  bool _isInitialized = false;
  bool _isAdsRemoved = false;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  int _completedLevelsSinceLastAd = 0;
  static const int interstitialFrequency = 3; // Show interstitial every 3 completed levels

  bool get isAdsRemoved => _isAdsRemoved;
  bool get isInitialized => _isInitialized;
  bool get isRewardedAdReady => _rewardedAd != null;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      preloadInterstitial();
      preloadRewarded();
    } catch (e) {
      debugPrint('AdManager init error: $e');
    }
  }

  void setAdsRemoved(bool removed) {
    _isAdsRemoved = removed;
  }

  // ==================== BANNER AD ====================

  BannerAd createBannerAd({
    required Function() onAdLoaded,
    required Function(LoadAdError error) onAdFailedToLoad,
  }) {
    return _buildBannerAd(
      unitId: bannerAdUnitId,
      onAdLoaded: onAdLoaded,
      onAdFailedToLoad: (error) {
        // Fallback to test banner if production banner fails before app store review/live fill
        if (bannerAdUnitId != testBannerAdUnitId) {
          debugPrint('Production Banner failed with code ${error.code}. Trying test banner ID.');
          final fallbackAd = _buildBannerAd(
            unitId: testBannerAdUnitId,
            onAdLoaded: onAdLoaded,
            onAdFailedToLoad: onAdFailedToLoad,
          );
          fallbackAd.load();
        } else {
          onAdFailedToLoad(error);
        }
      },
    );
  }

  BannerAd _buildBannerAd({
    required String unitId,
    required Function() onAdLoaded,
    required Function(LoadAdError error) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: unitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onAdFailedToLoad(error);
        },
      ),
    );
  }

  // ==================== INTERSTITIAL AD ====================

  void preloadInterstitial({String? overrideUnitId}) {
    if (_isAdsRemoved || _interstitialAd != null || _isInterstitialLoading) return;

    final targetUnitId = overrideUnitId ?? interstitialAdUnitId;
    _isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: targetUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          _setupInterstitialCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
          debugPrint('Interstitial failed with code ${error.code} ($targetUnitId)');
          // Fallback to test unit if production fails before Play Store approval
          if (targetUnitId != testInterstitialAdUnitId) {
            preloadInterstitial(overrideUnitId: testInterstitialAdUnitId);
          }
        },
      ),
    );
  }

  void _setupInterstitialCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        SoundManager.instance.setAdShowing(true);
      },
      onAdDismissedFullScreenContent: (ad) {
        SoundManager.instance.setAdShowing(false);
        ad.dispose();
        _interstitialAd = null;
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        SoundManager.instance.setAdShowing(false);
        ad.dispose();
        _interstitialAd = null;
        preloadInterstitial();
      },
    );
  }

  /// Called after a level is completed. Shows an interstitial ad every 3 completed levels.
  void showInterstitialIfEligible({Function()? onAdClosed}) {
    if (_isAdsRemoved) {
      onAdClosed?.call();
      return;
    }

    _completedLevelsSinceLastAd++;
    if (_completedLevelsSinceLastAd >= interstitialFrequency) {
      if (_interstitialAd != null) {
        _completedLevelsSinceLastAd = 0;
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (ad) {
            SoundManager.instance.setAdShowing(true);
          },
          onAdDismissedFullScreenContent: (ad) {
            SoundManager.instance.setAdShowing(false);
            ad.dispose();
            _interstitialAd = null;
            preloadInterstitial();
            onAdClosed?.call();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            SoundManager.instance.setAdShowing(false);
            ad.dispose();
            _interstitialAd = null;
            preloadInterstitial();
            onAdClosed?.call();
          },
        );
        _interstitialAd!.show();
        return;
      }
    }
    onAdClosed?.call();
  }

  // ==================== REWARDED AD ====================

  void preloadRewarded({String? overrideUnitId}) {
    if (_rewardedAd != null || _isRewardedLoading) return;

    final targetUnitId = overrideUnitId ?? rewardedAdUnitId;
    _isRewardedLoading = true;
    RewardedAd.load(
      adUnitId: targetUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedLoading = false;
          debugPrint('Rewarded ad failed with code ${error.code} ($targetUnitId)');
          // Fallback to test unit if production fails before Play Store approval
          if (targetUnitId != testRewardedAdUnitId) {
            preloadRewarded(overrideUnitId: testRewardedAdUnitId);
          }
        },
      ),
    );
  }

  /// Shows a rewarded ad. Invokes [onUserEarnedReward] if user watched the ad.
  void showRewardedAd({
    required Function(RewardItem reward) onUserEarnedReward,
    Function()? onAdDismissed,
    Function()? onAdFailedToLoad,
  }) {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          SoundManager.instance.setAdShowing(true);
        },
        onAdDismissedFullScreenContent: (ad) {
          SoundManager.instance.setAdShowing(false);
          ad.dispose();
          _rewardedAd = null;
          preloadRewarded();
          onAdDismissed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          SoundManager.instance.setAdShowing(false);
          ad.dispose();
          _rewardedAd = null;
          preloadRewarded();
          onAdFailedToLoad?.call();
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (adWithoutView, reward) {
          onUserEarnedReward(reward);
        },
      );
    } else {
      preloadRewarded();
      onAdFailedToLoad?.call();
    }
  }
}
