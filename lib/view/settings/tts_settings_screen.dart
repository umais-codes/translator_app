import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/view/components/custom_button.dart';
import 'package:translator_app/viewmodel/settings_viewmodel.dart';

class TtsSettingsScreen extends StatelessWidget {
  const TtsSettingsScreen({super.key});

  static const List<double> _speedPresets = [0.25, 0.5, 0.75, 1.0, 1.25];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final horizontalPadding = screenWidth * 0.045;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Speech & Audio',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: screenHeight * 0.02,
          ),
          children: [
            // Preview & Test Card
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
              child: Column(
                children: [
                  Container(
                    width: screenWidth * 0.16,
                    height: screenWidth * 0.16,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.primary,
                      size: screenWidth * 0.08,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    'Speech Synthesis Preview',
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.044,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    'Test how translated text will be pronounced aloud',
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.033,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  CustomButton(
                    text: vm.isPlayingSpeech ? 'Playing Sample...' : 'Test Voice Output',
                    variant: ButtonVariant.filled,
                    height: screenHeight * 0.055,
                    leadingIcon: vm.isPlayingSpeech ? Icons.graphic_eq_rounded : Icons.play_arrow_rounded,
                    isLoading: vm.isPlayingSpeech,
                    onPressed: vm.testSpeech,
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.025),

            // Speed Presets
            Text(
              'Speech Speed Presets',
              style: GoogleFonts.outfit(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              children: _speedPresets.map((speed) {
                final isSelected = (vm.speechRate - speed).abs() < 0.05;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => vm.setSpeechRate(speed),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${speed * 2}x',
                            style: GoogleFonts.outfit(
                              fontSize: screenWidth * 0.034,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: screenHeight * 0.025),

            // Fine-tune Sliders
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
                  // Speech Rate Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Speech Rate',
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.038,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${(vm.speechRate * 2).toStringAsFixed(2)}x',
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: vm.speechRate,
                    min: 0.1,
                    max: 1.0,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.border,
                    onChanged: vm.setSpeechRate,
                  ),

                  const Divider(height: 24, color: AppColors.borderLight),

                  // Voice Pitch Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Voice Pitch',
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.038,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        vm.pitch.toStringAsFixed(1),
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: vm.pitch,
                    min: 0.5,
                    max: 2.0,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.border,
                    onChanged: vm.setPitch,
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
