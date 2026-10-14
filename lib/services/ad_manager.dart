import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import 'sound_manager.dart';

class AdManager with LevelPlayInitListener {
  static final AdManager instance = AdManager._internal();

  factory AdManager() => instance;

  AdManager._internal();

  // ==================== CREDENTIALS ====================
  static const String prodAppKey = '28024314d';
  static const String prodBannerAdUnitId = '7n3t4ahi0tyf7rbh';
  static const String prodInterstitialAdUnitId = 'bktm1o6v90p3nn67';
  static const String prodRewardedAdUnitId = 'wu6ot3k21l8yqukp';

  String get appKey => prodAppKey;
  String get bannerAdUnitId => prodBannerAdUnitId;
  String get interstitialAdUnitId => prodInterstitialAdUnitId;
  String get rewardedAdUnitId => prodRewardedAdUnitId;

  bool _isInitialized = false;
  bool _isAdsRemoved = false;

  LevelPlayInterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;
  Function()? _interstitialClosedCallback;

  LevelPlayRewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;
  bool _isRewardedReady = false;
  Function(LevelPlayReward? reward)? _onUserEarnedReward;
  Function()? _onRewardedDismissed;
  Function()? _onRewardedFailedToLoad;

  int _completedLevelsSinceLastAd = 0;
  static const int interstitialFrequency = 3; // Show interstitial every 3 completed levels

  bool get isAdsRemoved => _isAdsRemoved;
  bool get isInitialized => _isInitialized;
  bool get isRewardedAdReady => _isRewardedReady;

  LevelPlayInterstitialAd get _interstitial {
    if (_interstitialAd == null) {
      _interstitialAd = LevelPlayInterstitialAd(adUnitId: interstitialAdUnitId);
      _interstitialAd!.setListener(_AdManagerInterstitialListener(this));
    }
    return _interstitialAd!;
  }

  LevelPlayRewardedAd get _rewarded {
    if (_rewardedAd == null) {
      _rewardedAd = LevelPlayRewardedAd(adUnitId: rewardedAdUnitId);
      _rewardedAd!.setListener(_AdManagerRewardedListener(this));
    }
    return _rewardedAd!;
  }

  /// Initializes the Unity LevelPlay (ironSource) SDK.
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Pre-instantiate ad instances and assign listeners
      _interstitial;
      _rewarded;

      // Unique user ID persistence
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('levelplay_user_id') ?? '';
      if (userId.isEmpty) {
        userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString('levelplay_user_id', userId);
      }

      if (kDebugMode) {
        await LevelPlay.setAdaptersDebug(true);
        LevelPlay.validateIntegration();
      }

      final initRequest = LevelPlayInitRequest.builder(appKey)
          .withUserId(userId)
          .build();

      await LevelPlay.init(initRequest: initRequest, initListener: this);
    } catch (e) {
      debugPrint('AdManager init error: $e');
    }
  }

  void setAdsRemoved(bool removed) {
    _isAdsRemoved = removed;
  }

  // ==================== LevelPlayInitListener ====================

  @override
  void onInitSuccess(LevelPlayConfiguration configuration) {
    debugPrint('LevelPlay init succeeded: $configuration');
    _isInitialized = true;
    preloadInterstitial();
    preloadRewarded();
  }

  @override
  void onInitFailed(LevelPlayInitError error) {
    debugPrint('LevelPlay init failed: $error');
  }

  // ==================== INTERSTITIAL AD ====================

  void preloadInterstitial() {
    if (_isAdsRemoved || _isInterstitialLoading) return;
    _isInterstitialLoading = true;
    try {
      _interstitial.loadAd();
    } catch (e) {
      _isInterstitialLoading = false;
      debugPrint('LevelPlay loadInterstitial error: $e');
    }
  }

  /// Called after a level is completed. Shows an interstitial ad every 3 completed levels.
  Future<void> showInterstitialIfEligible({Function()? onAdClosed}) async {
    if (_isAdsRemoved) {
      onAdClosed?.call();
      return;
    }

    _completedLevelsSinceLastAd++;
    if (_completedLevelsSinceLastAd >= interstitialFrequency) {
      bool ready = false;
      try {
        ready = await _interstitial.isAdReady();
      } catch (_) {}

      if (ready) {
        _completedLevelsSinceLastAd = 0;
        _interstitialClosedCallback = onAdClosed;
        try {
          _interstitial.showAd(placementName: 'WordSearch_Interstitial');
          return;
        } catch (e) {
          debugPrint('LevelPlay showInterstitial error: $e');
          _interstitialClosedCallback = null;
        }
      }
    }
    onAdClosed?.call();
  }

  // ==================== REWARDED AD ====================

  void preloadRewarded() {
    if (_isRewardedLoading) return;
    _isRewardedLoading = true;
    try {
      _rewarded.loadAd();
    } catch (e) {
      _isRewardedLoading = false;
      debugPrint('LevelPlay loadRewarded error: $e');
    }
  }

  /// Shows a rewarded ad. Invokes [onUserEarnedReward] if user completed watching the ad.
  Future<void> showRewardedAd({
    required Function(LevelPlayReward? reward) onUserEarnedReward,
    Function()? onAdDismissed,
    Function()? onAdFailedToLoad,
  }) async {
    bool ready = false;
    try {
      ready = await _rewarded.isAdReady();
    } catch (_) {}

    if (ready) {
      _onUserEarnedReward = onUserEarnedReward;
      _onRewardedDismissed = onAdDismissed;
      _onRewardedFailedToLoad = onAdFailedToLoad;

      try {
        _rewarded.showAd(placementName: 'WordSearch_Rewarded');
      } catch (e) {
        debugPrint('LevelPlay showRewarded error: $e');
        onAdFailedToLoad?.call();
        preloadRewarded();
      }
    } else {
      preloadRewarded();
      onAdFailedToLoad?.call();
    }
  }
}

class _AdManagerInterstitialListener with LevelPlayInterstitialAdListener {
  final AdManager _manager;
  _AdManagerInterstitialListener(this._manager);

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    _manager._isInterstitialLoading = false;
    debugPrint('LevelPlay Interstitial Loaded: $adInfo');
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    _manager._isInterstitialLoading = false;
    debugPrint('LevelPlay Interstitial Load Failed: $error');
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {
    SoundManager.instance.setAdShowing(true);
    debugPrint('LevelPlay Interstitial Displayed');
  }

  @override
  void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {
    SoundManager.instance.setAdShowing(false);
    debugPrint('LevelPlay Interstitial Display Failed: $error');
    final cb = _manager._interstitialClosedCallback;
    _manager._interstitialClosedCallback = null;
    cb?.call();
    _manager.preloadInterstitial();
  }

  @override
  void onAdClosed(LevelPlayAdInfo adInfo) {
    SoundManager.instance.setAdShowing(false);
    debugPrint('LevelPlay Interstitial Closed');
    final cb = _manager._interstitialClosedCallback;
    _manager._interstitialClosedCallback = null;
    cb?.call();
    _manager.preloadInterstitial();
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    debugPrint('LevelPlay Interstitial Clicked');
  }

  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {}
}

class _AdManagerRewardedListener with LevelPlayRewardedAdListener {
  final AdManager _manager;
  _AdManagerRewardedListener(this._manager);

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    _manager._isRewardedLoading = false;
    _manager._isRewardedReady = true;
    debugPrint('LevelPlay Rewarded Loaded: $adInfo');
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    _manager._isRewardedLoading = false;
    _manager._isRewardedReady = false;
    debugPrint('LevelPlay Rewarded Load Failed: $error');
    final cb = _manager._onRewardedFailedToLoad;
    _manager._onRewardedFailedToLoad = null;
    cb?.call();
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {
    SoundManager.instance.setAdShowing(true);
    debugPrint('LevelPlay Rewarded Displayed');
  }

  @override
  void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {
    SoundManager.instance.setAdShowing(false);
    debugPrint('LevelPlay Rewarded Display Failed: $error');
    _manager._isRewardedReady = false;
    final cb = _manager._onRewardedFailedToLoad;
    _manager._onRewardedFailedToLoad = null;
    cb?.call();
    _manager.preloadRewarded();
  }

  @override
  void onAdClosed(LevelPlayAdInfo adInfo) {
    SoundManager.instance.setAdShowing(false);
    _manager._isRewardedReady = false;
    debugPrint('LevelPlay Rewarded Closed');
    final cb = _manager._onRewardedDismissed;
    _manager._onRewardedDismissed = null;
    cb?.call();
    _manager.preloadRewarded();
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    debugPrint('LevelPlay Rewarded Clicked');
  }

  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {}

  @override
  void onAdRewarded(LevelPlayReward reward, LevelPlayAdInfo adInfo) {
    debugPrint('LevelPlay Rewarded Earned: $reward');
    final cb = _manager._onUserEarnedReward;
    cb?.call(reward);
  }
}
