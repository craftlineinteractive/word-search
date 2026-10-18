import 'package:flutter/material.dart';
import '../models/user_progress.dart';
import '../services/iap_manager.dart';
import '../services/sound_manager.dart';
import '../widgets/ambient_particles_overlay.dart';
import '../widgets/organic_wood_button.dart';
import '../widgets/parchment_card.dart';
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
            backgroundColor: isSuccess ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
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
      return live.price;
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
          backgroundColor: Color(0xFF2E7D32),
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
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F1),
      body: Stack(
        children: [
          // 1. Forest Meadow Storybook Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE8F5E9),
                    Color(0xFFC8E6C9),
                    Color(0xFFA5D6A7),
                  ],
                ),
              ),
            ),
          ),

          // 2. Ambient Drifting Fireflies
          const Positioned.fill(
            child: AmbientParticlesOverlay(
              particleCount: 12,
              particleColor: Color(0xFFFFD54F),
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: Column(
              children: [
                // Top Header Bar
                _buildTopHeader(),

                // Scrollable Products Catalog
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Current Balance Card
                              _buildBalanceCard(),

                              const SizedBox(height: 14),

                              // Remove Ads VIP Card
                              _buildRemoveAdsCard(),

                              const SizedBox(height: 16),

                              // Section Header
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  'COIN & HINT PACKS',
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF2A1810),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Coin Packs List
                              for (var product in IapManager.catalog.where((p) => !p.isRemoveAds))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: _buildProductCard(product),
                                ),

                              const SizedBox(height: 6),

                              // Free Rewards Card
                              _buildFreeRewardsCard(),

                              const SizedBox(height: 16),

                              // Restore Purchases & Disclaimer Footer
                              _buildFooter(),

                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: ParchmentCard(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Material(
              color: const Color(0xFF8D6E63),
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  SoundManager.instance.playButtonClick();
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.all(7.0),
                  child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
            const Row(
              children: [
                Icon(Icons.storefront_rounded, color: Color(0xFFE65100), size: 24),
                SizedBox(width: 8),
                Text(
                  'Coin Shop',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2A1810),
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return ParchmentCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Coins Balance
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD54F),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF5D4037), width: 1.8),
                    ),
                    child: const Icon(Icons.monetization_on_rounded, color: Color(0xFF2A1810), size: 20),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_coins',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2A1810),
                        ),
                      ),
                      const Text(
                        'Coins Available',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 11,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(height: 28, width: 1.5, color: const Color(0xFFD7CCC8)),
              // Hints Balance
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF5D4037), width: 1.8),
                    ),
                    child: const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_hints',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2A1810),
                        ),
                      ),
                      const Text(
                        'Hints Remaining',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 11,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD7CCC8), width: 1),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fast_forward_rounded, size: 15, color: Color(0xFFE65100)),
                    SizedBox(width: 4),
                    Text(
                      'Skip Level: 50 Coins',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events_rounded, size: 15, color: Color(0xFF2E7D32)),
                    SizedBox(width: 4),
                    Text(
                      'Win: +10 Coins',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoveAdsCard() {
    final removeAdsProduct = IapManager.catalog.firstWhere((p) => p.isRemoveAds);
    final isHighlighted = widget.highlightRemoveAds;

    return ParchmentCard(
      padding: const EdgeInsets.all(16),
      borderColor: isHighlighted ? const Color(0xFFE65100) : const Color(0xFF5D4037),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8E24AA), Color(0xFF5E35B1)],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF5D4037), width: 2),
            ),
            child: const Center(
              child: Icon(Icons.block_flipped, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'REMOVE ALL ADS',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2A1810),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _adsRemoved
                      ? '✓ Banner & Interstitial ads disabled permanently'
                      : 'Play peacefully without Banner or Interstitial ads',
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 11,
                    color: Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 8),
                if (!_adsRemoved)
                  SizedBox(
                    width: 130,
                    child: OrganicWoodButton(
                      text: _getProductDisplayPrice(removeAdsProduct),
                      variant: WoodButtonVariant.primary,
                      height: 38,
                      onPressed: () => _handleBuyProduct(removeAdsProduct),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ShopProductInfo product) {
    IconData icon;
    Color iconColor;

    if (product.hints > 0 && product.coins == 0) {
      icon = Icons.lightbulb_rounded;
      iconColor = const Color(0xFFFF9800);
    } else if (product.coins >= 5000) {
      icon = Icons.account_balance_rounded;
      iconColor = const Color(0xFFFFB300);
    } else if (product.coins >= 1500) {
      icon = Icons.all_inbox_rounded;
      iconColor = const Color(0xFFFFA000);
    } else {
      icon = Icons.monetization_on_rounded;
      iconColor = const Color(0xFFFFB300);
    }

    return ParchmentCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(45),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF5D4037), width: 1.5),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2A1810),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (product.coins > 0) ...[
                      const Icon(Icons.monetization_on_rounded, size: 14, color: Color(0xFFFFB300)),
                      const SizedBox(width: 3),
                      Text(
                        '+${product.coins} Coins',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ],
                    if (product.hints > 0) ...[
                      if (product.coins > 0) const SizedBox(width: 8),
                      const Icon(Icons.lightbulb_rounded, size: 14, color: Color(0xFFFF9800)),
                      const SizedBox(width: 3),
                      Text(
                        '+${product.hints} Hints',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFA000),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 85,
            child: OrganicWoodButton(
              text: _getProductDisplayPrice(product),
              variant: WoodButtonVariant.forest,
              height: 38,
              onPressed: () => _handleBuyProduct(product),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeRewardsCard() {
    return ParchmentCard(
      padding: const EdgeInsets.all(14),
      borderColor: const Color(0xFF2E7D32),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withAlpha(35),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1B5E20), width: 1.5),
            ),
            child: const Icon(Icons.play_circle_filled_rounded, color: Color(0xFF2E7D32), size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free Video Reward',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2A1810),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Watch a quick video for +50 coins or +1 hint',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 11,
                    color: Color(0xFF5D4037),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 85,
            child: OrganicWoodButton(
              text: 'CLAIM',
              variant: WoodButtonVariant.forest,
              height: 38,
              onPressed: () {
                RewardAdDialog.show(
                  context,
                  type: RewardType.coins,
                  onRewardClaimed: (type) => _loadData(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        TextButton.icon(
          onPressed: _handleRestorePurchases,
          icon: const Icon(Icons.restore_rounded, size: 18, color: Color(0xFF5D4037)),
          label: const Text(
            'Restore Purchases',
            style: TextStyle(
              fontFamily: 'Fredoka',
              color: Color(0xFF5D4037),
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Purchases are linked with your Google Play Account and can be restored anytime.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 11,
            color: Color(0xFF8D6E63),
          ),
        ),
      ],
    );
  }
}
