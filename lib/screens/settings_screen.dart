import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/sound_manager.dart';
import '../services/theme_manager.dart';
import '../theme/app_theme.dart';
import '../services/in_app_review_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _soundEnabled;
  late bool _musicEnabled;
  late bool _vibrationEnabled;
  late ThemeMode _currentThemeMode;

  @override
  void initState() {
    super.initState();
    _soundEnabled = SoundManager.instance.isSoundEnabled;
    _musicEnabled = SoundManager.instance.isMusicEnabled;
    _vibrationEnabled = SoundManager.instance.isHapticsEnabled;
    _currentThemeMode = ThemeManager.instance.currentThemeMode;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final bgColor = AppTheme.getBackgroundColor(context);
    final textPrimary = AppTheme.getTextPrimaryColor(context);
    final textSecondary = AppTheme.getTextSecondaryColor(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: bgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
          onPressed: () {
            SoundManager.instance.playButtonClick();
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // ==================== THEME & APPEARANCE ====================
          _buildSectionHeader('THEME & APPEARANCE', isDark),
          _buildThemeSelector(isDark),

          const SizedBox(height: 24),

          // ==================== AUDIO & HAPTICS ====================
          _buildSectionHeader('AUDIO & HAPTICS', isDark),
          _buildToggleTile(
            icon: Icons.volume_up_rounded,
            title: 'Sound Effects',
            subtitle: 'Word selection blips, hints & win fanfare',
            value: _soundEnabled,
            isDark: isDark,
            onChanged: (v) {
              setState(() => _soundEnabled = v);
              SoundManager.instance.setSoundEnabled(v);
              if (v) SoundManager.instance.playButtonClick();
            },
          ),
          _buildToggleTile(
            icon: Icons.music_note_rounded,
            title: 'Background Music',
            subtitle: 'Continuous background music from 5 relaxing tracks',
            value: _musicEnabled,
            isDark: isDark,
            onChanged: (v) {
              setState(() => _musicEnabled = v);
              SoundManager.instance.setMusicEnabled(v);
            },
          ),
          _buildToggleTile(
            icon: Icons.vibration_rounded,
            title: 'Haptics',
            subtitle: 'Tactile tile feedback on word find and taps',
            value: _vibrationEnabled,
            isDark: isDark,
            onChanged: (v) {
              setState(() => _vibrationEnabled = v);
              SoundManager.instance.setHapticsEnabled(v);
              if (v) SoundManager.instance.playButtonClick();
            },
          ),

          const SizedBox(height: 24),

          // ==================== GAME PROGRESS & PURCHASES ====================
          _buildSectionHeader('GAME PROGRESS & PURCHASES', isDark),
          _buildActionTile(
            icon: Icons.restore_rounded,
            title: 'Restore Purchases',
            subtitle: 'Recover previous In-App Purchases',
            isDark: isDark,
            onTap: () {
              SoundManager.instance.playButtonClick();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Purchases restored successfully.'),
                  backgroundColor: isDark ? const Color(0xFF1E3A8A) : const Color(0xFF0F172A),
                ),
              );
            },
          ),
          _buildActionTile(
            icon: Icons.help_outline_rounded,
            title: 'How to Play & Word Meanings',
            subtitle: 'Swipe horizontally, vertically, or diagonally',
            isDark: isDark,
            onTap: () {
              SoundManager.instance.playButtonClick();
              _showHowToPlayDialog();
            },
          ),

          const SizedBox(height: 24),

          // ==================== ABOUT & LEGAL ====================
          _buildSectionHeader('ABOUT & LEGAL', isDark),
          _buildActionTile(
            icon: Icons.share_rounded,
            title: 'Share Word Search App',
            subtitle: 'Share with friends on Play Store',
            isDark: isDark,
            onTap: () {
              SoundManager.instance.playButtonClick();
              Share.share(
                'Check out Word Search - Offline Word Puzzle Game on Google Play Store: https://play.google.com/store/apps/details?id=com.craftlineinteractive.wordsearch',
              );
            },
          ),
          _buildActionTile(
            icon: Icons.star_rate_rounded,
            title: 'Rate Word Search',
            subtitle: 'Support us with 5 stars on Play Store',
            isDark: isDark,
            onTap: () {
              SoundManager.instance.playButtonClick();
              InAppReviewService.instance.requestReviewOrStore();
            },
          ),
          _buildActionTile(
            icon: Icons.description_outlined,
            title: 'Terms of Use',
            subtitle: 'Review terms and license agreements',
            isDark: isDark,
            onTap: () => _launchUrl('https://dazzling-torta-9fb.notion.site/Terms-of-Use-Word-Search-3cff0fe5130280598bbcc8a0e4f0c266'),
          ),
          _buildActionTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Learn how your data is handled',
            isDark: isDark,
            onTap: () => _launchUrl('https://dazzling-torta-9fb.notion.site/Privacy-Policy-Word-Search-3cff0fe51302809ab578c14bf97d38a4'),
          ),
          _buildActionTile(
            icon: Icons.info_outline_rounded,
            title: 'App Version',
            subtitle: 'Version 1.0.1',
            isDark: isDark,
            onTap: null,
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              'Craftline Interactive • Word Search Odyssey',
              style: TextStyle(
                fontSize: 12,
                color: textSecondary.withAlpha(160),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? const Color(0xFFFFD700) : const Color(0xFF1E88E5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132347) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildThemeOptionCard(
              mode: ThemeMode.system,
              title: 'System',
              icon: Icons.brightness_auto_rounded,
              isSelected: _currentThemeMode == ThemeMode.system,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildThemeOptionCard(
              mode: ThemeMode.light,
              title: 'Light',
              icon: Icons.light_mode_rounded,
              isSelected: _currentThemeMode == ThemeMode.light,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildThemeOptionCard(
              mode: ThemeMode.dark,
              title: 'Dark',
              icon: Icons.dark_mode_rounded,
              isSelected: _currentThemeMode == ThemeMode.dark,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOptionCard({
    required ThemeMode mode,
    required String title,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
  }) {
    final activeColor = isDark ? const Color(0xFFFFD700) : const Color(0xFF1E88E5);
    final selectedBg = isDark ? const Color(0xFF1E3A8A).withAlpha(120) : const Color(0xFFE3F2FD);
    final unselectedBg = isDark ? const Color(0xFF0C1838) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

    return Material(
      color: isSelected ? selectedBg : unselectedBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          SoundManager.instance.playButtonClick();
          setState(() => _currentThemeMode = mode);
          ThemeManager.instance.setThemeMode(mode);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? activeColor : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? activeColor : textPrimary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF90A4AE) : const Color(0xFF64748B);
    final iconColor = isDark ? const Color(0xFF00E5FF) : const Color(0xFF1E88E5);
    final activeColor = isDark ? const Color(0xFFFFD700) : const Color(0xFF1E88E5);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132347) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(title, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
          subtitle: Text(subtitle, style: TextStyle(color: textSecondary, fontSize: 12)),
          value: value,
          activeTrackColor: activeColor.withAlpha(150),
          thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return activeColor;
            }
            return isDark ? Colors.white60 : const Color(0xFF94A3B8);
          }),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback? onTap,
  }) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF90A4AE) : const Color(0xFF64748B);
    final iconColor = isDark ? const Color(0xFFFF9100) : const Color(0xFF0288D1);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132347) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(title, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
          subtitle: Text(subtitle, style: TextStyle(color: textSecondary, fontSize: 12)),
          trailing: onTap != null
              ? Icon(Icons.arrow_forward_ios_rounded, color: textSecondary.withAlpha(150), size: 16)
              : null,
          onTap: onTap,
        ),
      ),
    );
  }

  void _showHowToPlayDialog() {
    final isDark = AppTheme.isDark(context);
    final textPrimary = AppTheme.getTextPrimaryColor(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0C1938) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark ? Colors.white.withAlpha(30) : Colors.black.withAlpha(20),
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.lightbulb_rounded, color: isDark ? const Color(0xFFFFD700) : const Color(0xFF1E88E5)),
            const SizedBox(width: 8),
            Text('How to Play', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHowToStep('1', 'Swipe letters horizontally, vertically, or diagonally in all directions.', isDark),
            _buildHowToStep('2', 'Find all target words listed below the grid to clear the level.', isDark),
            _buildHowToStep('3', 'Tap any found word chip to view its definition and example sentence!', isDark),
            _buildHowToStep('4', 'Use Hints (Target, Reveal, Solar Flare) if you get stuck.', isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'GOT IT',
              style: TextStyle(
                color: isDark ? const Color(0xFFFFD700) : const Color(0xFF1E88E5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToStep(String num, String text, bool isDark) {
    final activeColor = isDark ? const Color(0xFFFFD700) : const Color(0xFF1E88E5);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: activeColor.withAlpha(40),
            child: Text(
              num,
              style: TextStyle(fontSize: 11, color: activeColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: textPrimary.withAlpha(220), fontSize: 13, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    SoundManager.instance.playButtonClick();
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $urlString'),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    }
  }
}
