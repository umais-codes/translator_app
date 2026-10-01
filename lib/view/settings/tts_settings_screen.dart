import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

    final horizontalPadding = (375 * 0.045).w;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Speech & Audio',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: (812 * 0.02).h,
          ),
          children: [
            // Preview & Test Card
            Container(
              padding: EdgeInsets.all((375 * 0.045).w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: (375 * 0.16).w,
                    height: (375 * 0.16).w,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.primary,
                      size: (375 * 0.08).w,
                    ),
                  ),
                  SizedBox(height: (812 * 0.015).h),
                  Text(
                    'Speech Synthesis Preview',
                    style: GoogleFonts.outfit(
                      fontSize: (375 * 0.044).sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: (812 * 0.005).h),
                  Text(
                    'Test how translated text will be pronounced aloud',
                    style: GoogleFonts.outfit(
                      fontSize: (375 * 0.033).sp,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: (812 * 0.02).h),
                  CustomButton(
                    text: vm.isPlayingSpeech ? 'Playing Sample...' : 'Test Voice Output',
                    variant: ButtonVariant.filled,
                    height: (812 * 0.055).h,
                    leadingIcon: vm.isPlayingSpeech ? Icons.graphic_eq_rounded : Icons.play_arrow_rounded,
                    isLoading: vm.isPlayingSpeech,
                    onPressed: vm.testSpeech,
                  ),
                ],
              ),
            ),

            SizedBox(height: (812 * 0.025).h),

            // Speed Presets
            Text(
              'Speech Speed Presets',
              style: GoogleFonts.outfit(
                fontSize: (375 * 0.04).sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: (812 * 0.01).h),
            Row(
              children: _speedPresets.map((speed) {
                final isSelected = (vm.speechRate - speed).abs() < 0.05;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: GestureDetector(
                      onTap: () => vm.setSpeechRate(speed),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${speed * 2}x',
                            style: GoogleFonts.outfit(
                              fontSize: (375 * 0.034).sp,
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

            SizedBox(height: (812 * 0.025).h),

            // Fine-tune Sliders
            Container(
              padding: EdgeInsets.all((375 * 0.045).w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20.r),
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
                          fontSize: (375 * 0.038).sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${(vm.speechRate * 2).toStringAsFixed(2)}x',
                        style: GoogleFonts.outfit(
                          fontSize: (375 * 0.035).sp,
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

                  Divider(height: 24.h, color: AppColors.borderLight),

                  // Voice Pitch Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Voice Pitch',
                        style: GoogleFonts.outfit(
                          fontSize: (375 * 0.038).sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        vm.pitch.toStringAsFixed(1),
                        style: GoogleFonts.outfit(
                          fontSize: (375 * 0.035).sp,
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
