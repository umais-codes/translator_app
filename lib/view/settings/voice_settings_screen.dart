import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/viewmodel/settings_viewmodel.dart';

class VoiceSettingsScreen extends StatelessWidget {
  const VoiceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final horizontalPadding = screenWidth * 0.045;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Voice Recognition',
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
                      Icons.mic_rounded,
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
                          'Speech Input Engine',
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.042,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hardware Microphone Active',
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.032,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.025),

            // Section: Options
            Text(
              'Recognition Preferences',
              style: GoogleFonts.outfit(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),

            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: vm.preferOfflineRecognition,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.lightBlueBackground,
                    title: Text(
                      'Prefer On-Device Recognition',
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.038,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Processes voice input locally without uploading audio',
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.03,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onChanged: vm.toggleOfflineRecognition,
                  ),
                  const Divider(height: 1, color: AppColors.borderLight),
                  SwitchListTile(
                    value: vm.autoPunctuation,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.lightBlueBackground,
                    title: Text(
                      'Auto Punctuation',
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.038,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Automatically insert periods, commas, and question marks',
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.03,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onChanged: vm.toggleAutoPunctuation,
                  ),
                  const Divider(height: 1, color: AppColors.borderLight),
                  SwitchListTile(
                    value: vm.soundFeedback,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.lightBlueBackground,
                    title: Text(
                      'Audio & Haptic Feedback',
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.038,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Vibrate when starting and finishing speech listening',
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.03,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onChanged: vm.toggleSoundFeedback,
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.025),

            // Tip / Guide Card
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: AppColors.lightBlueBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: screenWidth * 0.055,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'For optimal voice accuracy without internet, ensure you have downloaded offline speech recognition packs in your device’s system language settings.',
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.032,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
