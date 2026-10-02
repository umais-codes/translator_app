import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

    final horizontalPadding = 17.w;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Voice Recognition',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16.h,
          ),
          children: [
            // Status Card
            Container(
              padding: EdgeInsets.all(17.w),
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
              child: Row(
                children: [
                  Container(
                    width: 49.w,
                    height: 49.w,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueBackground,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.mic_rounded,
                      color: AppColors.primary,
                      size: 26.w,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Speech Input Engine',
                          style: GoogleFonts.outfit(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Hardware speech recognizer',
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
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

            SizedBox(height: 20.h),

            // Section: Options
            Text(
              'Recognition Preferences',
              style: GoogleFonts.outfit(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8.h),

            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20.r),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: const BorderSide(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  SwitchListTile(
                    value: vm.preferOfflineRecognition,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.lightBlueBackground,
                    title: Text(
                      'Prefer On-Device Recognition',
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Uses the device speech pack when one is installed. Turn this off if listening fails.',
                      style: GoogleFonts.outfit(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onChanged: vm.toggleOfflineRecognition,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Tip / Guide Card
            Container(
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                color: AppColors.lightBlueBackground,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 21.w,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'For optimal voice accuracy without internet, ensure you have downloaded offline speech recognition packs in your device’s system language settings.',
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        color: AppColors.textPrimary,
                        height: 1.h,
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
