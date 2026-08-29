import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/view/components/custom_button.dart';
import 'package:translator_app/viewmodel/settings_viewmodel.dart';

class OfflineSettingsScreen extends StatelessWidget {
  const OfflineSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final horizontalPadding = screenWidth * 0.045;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Offline & Storage',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: screenHeight * 0.02,
          ),
          children: [
            // Status Card
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
                      Icons.offline_bolt_rounded,
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
                          'Local Offline Cache',
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.042,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${vm.cachedPhrasesCount} phrases stored locally',
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

            // How Offline Works Card
            Text(
              'How Offline Mode Operates',
              style: GoogleFonts.outfit(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),

            Container(
              padding: EdgeInsets.all(screenWidth * 0.045),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureRow(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Persistent Offline Storage',
                    desc: 'Every word or sentence translated while connected is cached locally and available without network.',
                    screenWidth: screenWidth,
                  ),
                  const Divider(height: 24, color: AppColors.borderLight),
                  _buildFeatureRow(
                    icon: Icons.speed_rounded,
                    title: 'Zero Latency',
                    desc: 'Repeated queries load instantaneously with zero data usage.',
                    screenWidth: screenWidth,
                  ),
                  const Divider(height: 24, color: AppColors.borderLight),
                  _buildFeatureRow(
                    icon: Icons.model_training_rounded,
                    title: 'On-Device ML Ready',
                    desc: 'Compatible with on-device neural translation models for full standalone dictionary translation.',
                    screenWidth: screenWidth,
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Cache Management Button
            CustomButton(
              text: 'Clear Offline Translation Cache',
              variant: ButtonVariant.outlined,
              height: screenHeight * 0.055,
              leadingIcon: Icons.delete_outline_rounded,
              borderColor: AppColors.error,
              textColor: AppColors.error,
              isLoading: vm.isClearingCache,
              onPressed: vm.cachedPhrasesCount > 0
                  ? () async {
                      final success = await vm.clearCache();
                      if (context.mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.success,
                            content: Text('Offline translation cache cleared successfully'),
                          ),
                        );
                      }
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String desc,
    required double screenWidth,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: screenWidth * 0.055),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: screenWidth * 0.036,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: GoogleFonts.outfit(
                  fontSize: screenWidth * 0.031,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
