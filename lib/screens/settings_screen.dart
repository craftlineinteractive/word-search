import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/sound_manager.dart';
import '../services/in_app_review_service.dart';
import '../widgets/ambient_particles_overlay.dart';
import '../widgets/organic_wood_button.dart';
import '../widgets/parchment_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _soundEnabled;
  late bool _musicEnabled;
  late bool _vibrationEnabled;

  @override
  void initState() {
    super.initState();
    _soundEnabled = SoundManager.instance.isSoundEnabled;
    _musicEnabled = SoundManager.instance.isMusicEnabled;
    _vibrationEnabled = SoundManager.instance.isHapticsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F1),
      body: Stack(
        children: [
          // 1. Forest Canopy Storybook Gradient
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

          // 3. Foreground Content
          SafeArea(
            child: Column(
              children: [
                // Top Header Bar
                _buildTopHeader(),

                // Scrollable Settings List
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    children: [
                      // ==================== AUDIO & HAPTICS ====================
                      _buildSectionHeader('AUDIO & HAPTICS'),
                      ParchmentCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            _buildToggleRow(
                              icon: Icons.volume_up_rounded,
                              title: 'Sound Effects',
                              subtitle: 'Word selection blips, hints & win fanfare',
                              value: _soundEnabled,
                              onChanged: (v) {
                                setState(() => _soundEnabled = v);
                                SoundManager.instance.setSoundEnabled(v);
                                if (v) SoundManager.instance.playButtonClick();
                              },
                            ),
                            const Divider(color: Color(0xFFD7CCC8), height: 16),
                            _buildToggleRow(
                              icon: Icons.music_note_rounded,
                              title: 'Background Music',
                              subtitle: 'Continuous background music from 5 relaxing tracks',
                              value: _musicEnabled,
                              onChanged: (v) {
                                setState(() => _musicEnabled = v);
                                SoundManager.instance.setMusicEnabled(v);
                              },
                            ),
                            const Divider(color: Color(0xFFD7CCC8), height: 16),
                            _buildToggleRow(
                              icon: Icons.vibration_rounded,
                              title: 'Haptics',
                              subtitle: 'Tactile vibrations on letter tap and clears',
                              value: _vibrationEnabled,
                              onChanged: (v) {
                                setState(() => _vibrationEnabled = v);
                                SoundManager.instance.setHapticsEnabled(v);
                                if (v) SoundManager.instance.playButtonClick();
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ==================== GAME PROGRESS & GUIDANCE ====================
                      _buildSectionHeader('GAME PROGRESS & HELP'),
                      ParchmentCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            _buildActionRow(
                              icon: Icons.restore_rounded,
                              title: 'Restore Purchases',
                              subtitle: 'Recover previous In-App Purchases',
                              onTap: () {
                                SoundManager.instance.playButtonClick();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Purchases restored successfully.', style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold)),
                                    backgroundColor: Color(0xFF2E7D32),
                                  ),
                                );
                              },
                            ),
                            const Divider(color: Color(0xFFD7CCC8), height: 16),
                            _buildActionRow(
                              icon: Icons.help_outline_rounded,
                              title: 'How to Play & Word Meanings',
                              subtitle: 'Swipe letters horizontally, vertically, or diagonally',
                              onTap: () {
                                SoundManager.instance.playButtonClick();
                                _showHowToPlayDialog();
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ==================== ABOUT & COMMUNITY ====================
                      _buildSectionHeader('ABOUT & COMMUNITY'),
                      ParchmentCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            _buildActionRow(
                              icon: Icons.share_rounded,
                              title: 'Share Word Search',
                              subtitle: 'Invite friends to explore the 30 magical worlds',
                              onTap: () {
                                SoundManager.instance.playButtonClick();
                                Share.share(
                                  'Explore Word Search - Offline Word Puzzle Game with 3,600 levels and 30 worlds: https://play.google.com/store/apps/details?id=com.craftlineinteractive.wordsearch',
                                );
                              },
                            ),
                            const Divider(color: Color(0xFFD7CCC8), height: 16),
                            _buildActionRow(
                              icon: Icons.star_rate_rounded,
                              title: 'Rate Word Search',
                              subtitle: 'Support us with 5 stars on Play Store',
                              onTap: () {
                                SoundManager.instance.playButtonClick();
                                InAppReviewService.instance.openStoreListing();
                              },
                            ),
                            const Divider(color: Color(0xFFD7CCC8), height: 16),
                            _buildActionRow(
                              icon: Icons.description_outlined,
                              title: 'Terms of Use',
                              subtitle: 'Review terms and license agreements',
                              onTap: () => _launchUrl('https://dazzling-torta-9fb.notion.site/Terms-of-Use-Word-Search-3cff0fe5130280598bbcc8a0e4f0c266'),
                            ),
                            const Divider(color: Color(0xFFD7CCC8), height: 16),
                            _buildActionRow(
                              icon: Icons.privacy_tip_outlined,
                              title: 'Privacy Policy',
                              subtitle: 'Learn how your data is handled',
                              onTap: () => _launchUrl('https://dazzling-torta-9fb.notion.site/Privacy-Policy-Word-Search-3cff0fe51302809ab578c14bf97d38a4'),
                            ),
                            const Divider(color: Color(0xFFD7CCC8), height: 16),
                            _buildActionRow(
                              icon: Icons.info_outline_rounded,
                              title: 'App Version',
                              subtitle: 'Version 1.1.0',
                              onTap: null,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Center(
                        child: Text(
                          'Craftline Interactive • Word Search Odyssey',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 12,
                            color: Color(0xFF5D4037),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
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
                Icon(Icons.settings_rounded, color: Color(0xFF2E7D32), size: 24),
                SizedBox(width: 8),
                Text(
                  'Settings',
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Fredoka',
          color: Color(0xFF2E7D32),
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withAlpha(35),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF2E7D32), width: 1.5),
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            color: Color(0xFF2A1810),
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            color: Color(0xFF5D4037),
            fontSize: 12,
          ),
        ),
        value: value,
        activeTrackColor: const Color(0xFF2E7D32),
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFFFD54F);
          }
          return const Color(0xFF8D6E63);
        }),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE65100).withAlpha(35),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE65100), width: 1.5),
              ),
              child: Icon(icon, color: const Color(0xFFE65100), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      color: Color(0xFF2A1810),
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      color: Color(0xFF5D4037),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF8D6E63)),
          ],
        ),
      ),
    );
  }

  void _showHowToPlayDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ParchmentCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 12),
              const Text(
                'How to Play',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2A1810),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '• Swipe over adjacent letters in a straight line: forward, backward, vertically, or diagonally.\n\n'
                '• Complete words to fill the word bank and earn stars.\n\n'
                '• Tap any word in the word bank to explore its dictionary definition and usage.\n\n'
                '• Complete 3,600 levels across 30 worlds to become the Ultimate Grandmaster!',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 13,
                  color: Color(0xFF5D4037),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              OrganicWoodButton(
                text: 'GOT IT!',
                variant: WoodButtonVariant.forest,
                height: 46,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
