import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../models/user_progress.dart';
import 'ad_manager.dart';

class ShopProductInfo {
  final String id;
  final String title;
  final String description;
  final int coins;
  final int hints;
  final bool isRemoveAds;
  final String? bonusTag;

  const ShopProductInfo({
    required this.id,
    required this.title,
    required this.description,
    this.coins = 0,
    this.hints = 0,
    this.isRemoveAds = false,
    this.bonusTag,
  });
}

class IapManager {
  IapManager._internal();
  static final IapManager instance = IapManager._internal();

  InAppPurchase? _iapInstance;
  InAppPurchase? get _iap {
    try {
      _iapInstance ??= InAppPurchase.instance;
    } catch (_) {
      _iapInstance = null;
    }
    return _iapInstance;
  }

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Product ID constants (must match Google Play Console In-App Products exactly)
  static const String idRemoveAds = 'word_search_remove_ads';
  static const String idCoins500 = 'word_search_coins_500';
  static const String idCoins1500 = 'word_search_coins_1500';
  static const String idCoins5000 = 'word_search_coins_5000';
  static const String idHints60 = 'word_search_hints_60';
  static const String idHints120 = 'word_search_hints_120';

  static const List<ShopProductInfo> catalog = [
    ShopProductInfo(
      id: idRemoveAds,
      title: 'Remove All Ads',
      description: 'Permanent removal of all Banner and Interstitial Ads',
      isRemoveAds: true,
      bonusTag: 'BEST DEAL',
    ),
    ShopProductInfo(
      id: idHints60,
      title: '60 Hints Pack',
      description: 'Get 60 instant puzzle hints to reveal letters anytime',
      hints: 60,
      bonusTag: 'POPULAR HINT',
    ),
    ShopProductInfo(
      id: idHints120,
      title: '120 Hints Mega Pack',
      description: 'Get 120 instant puzzle hints for massive word solving',
      hints: 120,
      bonusTag: 'BEST VALUE HINT',
    ),
    ShopProductInfo(
      id: idCoins500,
      title: 'Handful of Coins',
      description: '500 Gold Coins for hints and puzzle boosts',
      coins: 500,
      hints: 0,
    ),
    ShopProductInfo(
      id: idCoins1500,
      title: 'Chest of Coins',
      description: '1,500 Gold Coins + 5 Free Bonus Hints',
      coins: 1500,
      hints: 5,
      bonusTag: '+20% BONUS',
    ),
    ShopProductInfo(
      id: idCoins5000,
      title: 'Vault of Coins',
      description: '5,000 Gold Coins + 20 Free Bonus Hints',
      coins: 5000,
      hints: 20,
      bonusTag: '+50% VALUE',
    ),
  ];

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  final Map<String, ProductDetails> _products = {};
  Map<String, ProductDetails> get products => _products;

  final ValueNotifier<bool> purchasePendingNotifier = ValueNotifier<bool>(false);

  // Callback to notify UI when a purchase finishes or fails
  Function(String message, bool isSuccess)? onPurchaseEvent;

  Future<void> init() async {
    try {
      final iap = _iap;
      if (iap != null) {
        _isAvailable = await iap.isAvailable();
        if (_isAvailable) {
          final Stream<List<PurchaseDetails>> purchaseUpdated = iap.purchaseStream;
          _subscription = purchaseUpdated.listen(
            _onPurchaseUpdated,
            onDone: () => _subscription?.cancel(),
            onError: (error) {
              debugPrint('[IAP] Purchase stream error: $error');
            },
          );

          await queryProducts();
        }
      }
    } catch (e) {
      debugPrint('[IAP] Initialization error: $e');
    }
  }

  Future<void> queryProducts() async {
    final iap = _iap;
    if (!_isAvailable || iap == null) return;
    try {
      final Set<String> ids = catalog.map((p) => p.id).toSet();
      final ProductDetailsResponse response = await iap.queryProductDetails(ids);
      if (response.error == null) {
        _products.clear();
        for (var p in response.productDetails) {
          _products[p.id] = p;
        }
      } else {
        debugPrint('[IAP] Query products response error: ${response.error?.message}');
      }
    } catch (e) {
      debugPrint('[IAP] Query products error: $e');
    }
  }

  Future<bool> buyProduct(ShopProductInfo productInfo) async {
    final liveProduct = _products[productInfo.id];
    final iap = _iap;

    if (!_isAvailable || iap == null) {
      onPurchaseEvent?.call(
        'Google Play Store billing is not available on this device.',
        false,
      );
      return false;
    }

    if (liveProduct == null) {
      onPurchaseEvent?.call(
        'Product "${productInfo.id}" is not active in Google Play Console yet. Please create and activate this In-App product.',
        false,
      );
      return false;
    }

    purchasePendingNotifier.value = true;
    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: liveProduct);
      if (productInfo.isRemoveAds) {
        return await iap.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        return await iap.buyConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      purchasePendingNotifier.value = false;
      onPurchaseEvent?.call('Purchase failed: $e', false);
      return false;
    }
  }

  Future<void> restorePurchases() async {
    final iap = _iap;
    if (!_isAvailable || iap == null) {
      onPurchaseEvent?.call('Google Play Store billing is not available.', false);
      return;
    }

    purchasePendingNotifier.value = true;
    try {
      await iap.restorePurchases();
    } catch (e) {
      debugPrint('[IAP] Restore purchases error: $e');
      onPurchaseEvent?.call('Failed to restore purchases: $e', false);
    } finally {
      purchasePendingNotifier.value = false;
    }
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    final iap = _iap;
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.pending) {
        purchasePendingNotifier.value = true;
      } else {
        purchasePendingNotifier.value = false;

        if (purchase.status == PurchaseStatus.error) {
          debugPrint('[IAP] Purchase error: ${purchase.error?.message}');
          onPurchaseEvent?.call(
            purchase.error?.message ?? 'Purchase was cancelled or failed.',
            false,
          );
        } else if (purchase.status == PurchaseStatus.purchased ||
                   purchase.status == PurchaseStatus.restored) {
          await deliverProduct(purchase.productID);
          onPurchaseEvent?.call('Purchase completed successfully!', true);
        }

        if (purchase.pendingCompletePurchase && iap != null) {
          await iap.completePurchase(purchase);
        }
      }
    }
  }

  Future<void> deliverProduct(String productId) async {
    final progress = await UserProgress.load();

    if (productId == idRemoveAds) {
      progress.adsRemoved = true;
      AdManager.instance.setAdsRemoved(true);
      await progress.save();
    } else if (productId == idHints60) {
      progress.hints += 60;
      await progress.save();
    } else if (productId == idHints120) {
      progress.hints += 120;
      await progress.save();
    } else if (productId == idCoins500) {
      progress.addCoins(500);
      await progress.save();
    } else if (productId == idCoins1500) {
      progress.addCoins(1500);
      progress.hints += 5;
      await progress.save();
    } else if (productId == idCoins5000) {
      progress.addCoins(5000);
      progress.hints += 20;
      await progress.save();
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
