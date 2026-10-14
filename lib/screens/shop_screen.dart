import 'package:flutter/material.dart';
import '../models/user_progress.dart';
import '../services/iap_manager.dart';
import '../services/sound_manager.dart';
import '../theme/app_theme.dart';
import '../widgets/reward_ad_dialog.dart';

class ShopScreen extends StatefulWidget {
  final bool highlightRemoveAds;

  const ShopScreen({
    super.key,
    this.highlightRemoveAds = false,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _coins = 0;
  int _hints = 0;
  bool _adsRemoved = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    IapManager.instance.onPurchaseEvent = (message, isSuccess) {
      if (mounted) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: isSuccess ? const Color(0xFF00E676) : const Color(0xFFD32F2F),
            duration: const Duration(seconds: 4),
            content: Text(
              message,
              style: const TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    };
  }

  @override
  void dispose() {
    IapManager.instance.onPurchaseEvent = null;
    super.dispose();
  }

  Future<void> _loadData() async {
    final progress = await UserProgress.load();
    if (mounted) {
      setState(() {
        _coins = progress.coins;
        _hints = progress.hints;
        _adsRemoved = progress.adsRemoved;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleBuyProduct(ShopProductInfo product) async {
    SoundManager.instance.playButtonClick();
    await IapManager.instance.buyProduct(product);
  }

  String _getProductDisplayPrice(ShopProductInfo product) {
    final live = IapManager.instance.products[product.id];
    if (live != null && live.price.isNotEmpty) {
      return live.price; // Dynamic localized price automatically served by Google Play (e.g. ₹29.00, ₹79.00, $0.99)
    }
    return product.isRemoveAds ? 'UNLOCK' : 'BUY';
  }

  Future<void> _handleRestorePurchases() async {
    SoundManager.instance.playButtonClick();
    await IapManager.instance.restorePurchases();
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF1E88E5),
          content: Text(
            'Purchases restored successfully!',
            style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final textPrimary = AppTheme.getTextPrimaryColor(context);
    final textSecondary = AppTheme.getTextSecondaryColor(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [
                      Color(0xFF081226),
                      Color(0xFF0D1B3E),
                      Color(0xFF102A54),
                    ]
                  : const [
                      Color(0xFFF8FAFC),
                      Color(0xFFF1F5F9),
                      Color(0xFFE2E8F0),
                    ],
            ),
          ),
          child: Column(
            children: [
              // 1. Top Header Bar
              _buildTopHeader(isDark, textPrimary),

              // 2. Main Scrollable Products List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFB300)))
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Current Balance Bar
                            _buildBalanceCard(isDark, textPrimary, textSecondary),

                            const SizedBox(height: 18),

                            // ==================== REMOVE ADS SPECIAL VIP CARD ====================
                            _buildRemoveAdsCard(isDark, textPrimary, textSecondary),

                            const SizedBox(height: 20),

                            // Section Title
                            Text(
                              'COIN & HINT PACKS',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                                letterSpacing: 0.8,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Coin Packs List
                            for (var product in IapManager.catalog.where((p) => !p.isRemoveAds))
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14.0),
                                child: _buildProductCard(product, isDark, textPrimary, textSecondary),
                              ),

                            const SizedBox(height: 10),

                            // Free Rewards Card
                            _buildFreeRewardsCard(isDark, textPrimary, textSecondary),

                            const SizedBox(height: 20),

                            // Restore Purchases & Disclaimer Footer
                            _buildFooter(isDark, textSecondary),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(bool isDark, Color textPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B192C).withAlpha(230) : Colors.white.withAlpha(230),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 80 : 15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: isDark ? const Color(0xFF1E3A6D) : Colors.white,
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                SoundManager.instance.playButtonClick();
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
              ),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFB300), size: 22),
              const SizedBox(width: 6),
              Text(
                'Coin Shop',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(bool isDark, Color textPrimary, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132347) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E3A6D) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Coins
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_coins',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        'Coins Available',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(height: 32, width: 1, color: isDark ? Colors.white24 : Colors.black12),
              // Hints
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF9100),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_hints',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        'Hints Remaining',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0C1838) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCoinUseBadge('⏩ Skip Level', '50 Coins', isDark),
                _buildCoinUseBadge('🏆 Level Win', '+10 Coins', isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoveAdsCard(bool isDark, Color textPrimary, Color textSecondary) {
    final removeAdsProduct = IapManager.catalog.firstWhere((p) => p.isRemoveAds);
    final isHighlighted = widget.highlightRemoveAds;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8E24AA), Color(0xFF5E35B1)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isHighlighted ? const Color(0xFFFFD700) : Colors.transparent,
          width: isHighlighted ? 3.0 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? const Color(0xFFFFD700).withAlpha(160)
                : const Color(0xFF5E35B1).withAlpha(120),
            blurRadius: isHighlighted ? 20 : 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.block_flipped, color: Colors.white, size: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'REMOVE ALL ADS',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _adsRemoved
                            ? '✓ Ads already removed on this device'
                            : 'Permanent removal of Banner & Interstitial ads',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 12,
                          color: Colors.white.withAlpha(220),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!_adsRemoved)
                        SizedBox(
                          height: 38,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700),
                              foregroundColor: const Color(0xFF3E2723),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => _handleBuyProduct(removeAdsProduct),
                            child: Text(
                              _getProductDisplayPrice(removeAdsProduct),
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Best Deal Badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'BEST DEAL',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    ShopProductInfo product,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    IconData icon;
    Color iconColor;

    if (product.hints > 0 && product.coins == 0) {
      icon = Icons.lightbulb_rounded;
      iconColor = const Color(0xFFFF9100);
    } else if (product.coins >= 5000) {
      icon = Icons.account_balance_rounded;
      iconColor = const Color(0xFFFFD700);
    } else if (product.coins >= 1500) {
      icon = Icons.all_inbox_rounded;
      iconColor = const Color(0xFFFF9100);
    } else {
      icon = Icons.monetization_on_rounded;
      iconColor = const Color(0xFFFFB300);
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132347) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E3A6D) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Product Icon Container
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(isDark ? 50 : 30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),

                const SizedBox(width: 14),

                // Title & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (product.coins > 0) ...[
                            const Icon(Icons.monetization_on_rounded, size: 14, color: Color(0xFFFFD700)),
                            const SizedBox(width: 3),
                            Text(
                              '+${product.coins} Coins',
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFD700),
                              ),
                            ),
                          ],
                          if (product.hints > 0) ...[
                            if (product.coins > 0) const SizedBox(width: 8),
                            const Icon(Icons.lightbulb_rounded, size: 14, color: Color(0xFFFF9100)),
                            const SizedBox(width: 3),
                            Text(
                              '+${product.hints} Hints',
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF9100),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Buy Button
                SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _handleBuyProduct(product),
                    child: Text(
                      _getProductDisplayPrice(product),
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bonus Tag
          if (product.bonusTag != null)
            Positioned(
              top: 0,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: const BoxDecoration(
                  color: Color(0xFF00E676),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
                ),
                child: Text(
                  product.bonusTag!,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFreeRewardsCard(bool isDark, Color textPrimary, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132347) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00E676),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withAlpha(isDark ? 40 : 20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_circle_filled_rounded, color: Color(0xFF00E676), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free Video Reward',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Watch a quick video for +50 coins or +1 hint',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                RewardAdDialog.show(
                  context,
                  type: RewardType.coins,
                  onRewardClaimed: (type) => _loadData(),
                );
              },
              child: const Text(
                'CLAIM',
                style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinUseBadge(String label, String cost, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : const Color(0xFF334155),
          ),
        ),
        Text(
          cost,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFD700),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isDark, Color textSecondary) {
    return Column(
      children: [
        TextButton.icon(
          onPressed: _handleRestorePurchases,
          icon: Icon(Icons.restore_rounded, size: 18, color: textSecondary),
          label: Text(
            'Restore Purchases',
            style: TextStyle(
              fontFamily: 'Fredoka',
              color: textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Purchases are linked with your Google Play Account and can be restored anytime.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: textSecondary.withAlpha(180),
          ),
        ),
      ],
    );
  }
}
