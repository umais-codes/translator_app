import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/view/settings/help_feedback_screen.dart';
import 'package:translator_app/view/settings/offline_settings_screen.dart';
import 'package:translator_app/view/settings/privacy_policy_screen.dart';
import 'package:translator_app/view/settings/theme_settings_screen.dart';
import 'package:translator_app/view/settings/tts_settings_screen.dart';
import 'package:translator_app/view/settings/voice_settings_screen.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final horizontalPadding = screenWidth * 0.045;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Settings',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: screenHeight * 0.02,
          ),
          children: [
            // App Information Card
            Container(
              padding: EdgeInsets.all(screenWidth * 0.045),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: screenWidth * 0.14,
                    height: screenWidth * 0.14,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Translator App',
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.046,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Version 1.0.0 • AI-Powered Translation',
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.034,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Section: Audio & Speech
            _buildSectionHeader('Speech & Audio', screenWidth),
            SizedBox(height: screenHeight * 0.01),
            _buildSettingsTile(
              icon: Icons.volume_up_rounded,
              title: 'Text-to-Speech Speed',
              subtitle: 'Configure speech rate, pitch & voice output',
              screenWidth: screenWidth,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TtsSettingsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.mic_rounded,
              title: 'Voice Recognition',
              subtitle: 'Microphone preferences & offline speech',
              screenWidth: screenWidth,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VoiceSettingsScreen(),
                  ),
                );
              },
            ),

            SizedBox(height: screenHeight * 0.03),

            // Section: Preferences
            _buildSectionHeader('Appearance & Language', screenWidth),
            SizedBox(height: screenHeight * 0.01),
            _buildSettingsTile(
              icon: Icons.palette_outlined,
              title: 'App Theme',
              subtitle: 'Choose accent color palette & light mode',
              screenWidth: screenWidth,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThemeSettingsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.offline_bolt_outlined,
              title: 'Offline & Storage',
              subtitle: 'Manage local translation cache & data',
              screenWidth: screenWidth,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OfflineSettingsScreen(),
                  ),
                );
              },
            ),

            SizedBox(height: screenHeight * 0.03),

            // Section: About & Help
            _buildSectionHeader('About & Help', screenWidth),
            SizedBox(height: screenHeight * 0.01),
            _buildSettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'How we protect your data & on-device security',
              screenWidth: screenWidth,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.help_outline_rounded,
              title: 'Help & Feedback',
              subtitle: 'Frequently asked questions & contact form',
              screenWidth: screenWidth,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpFeedbackScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, double screenWidth) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: screenWidth * 0.04,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double screenWidth,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: 2,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          title: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: screenWidth * 0.038,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.outfit(
              fontSize: screenWidth * 0.032,
              color: AppColors.textSecondary,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
