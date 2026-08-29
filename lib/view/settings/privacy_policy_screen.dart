import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final horizontalPadding = screenWidth * 0.045;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Privacy Policy',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: screenHeight * 0.02,
          ),
          children: [
            // Top Badge Card
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
                    width: screenWidth * 0.13,
                    height: screenWidth * 0.13,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: AppColors.primary,
                      size: screenWidth * 0.07,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Privacy Matters',
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.042,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Last Updated: August 2026',
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.032,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.025),

            _buildSection(
              title: '1. Information We Collect',
              content:
                  'We collect only the minimal data required to deliver real-time translations, speech-to-text recognition, and text-to-speech features. Text entered for translation is cached locally on your device and sent to translation providers only to generate the output.',
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),

            _buildSection(
              title: '2. On-Device & Offline Processing',
              content:
                  'Translator App is designed to prioritize on-device processing. Cached phrases, dictionary queries, and offline model operations never leave your physical device and do not require remote server logging.',
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),

            _buildSection(
              title: '3. Speech & Audio Data',
              content:
                  'Audio recordings from your microphone are converted to text locally via system voice APIs. We do not store or transmit raw audio files to external servers.',
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),

            _buildSection(
              title: '4. Third-Party Services',
              content:
                  'When online, translations are routed through public translation APIs (e.g. MyMemory / Google Translator). These requests contain only the text snippet and language codes needed for translation.',
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),

            _buildSection(
              title: '5. Data Security & Storage',
              content:
                  'All saved histories are stored in your device’s sandbox memory. You can clear your local database and translation history at any time from the app settings.',
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      padding: EdgeInsets.all(screenWidth * 0.045),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: screenWidth * 0.038,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          Text(
            content,
            style: GoogleFonts.outfit(
              fontSize: screenWidth * 0.033,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
