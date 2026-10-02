import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

    final horizontalPadding = 17.w;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Offline & Storage',
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
                      Icons.offline_bolt_rounded,
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
                          'Local Offline Cache',
                          style: GoogleFonts.outfit(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${vm.cachedPhrasesCount} phrases stored locally',
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // How Offline Works Card
            Text(
              'How Offline Mode Operates',
              style: GoogleFonts.outfit(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8.h),

            Container(
              padding: EdgeInsets.all(17.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureRow(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Persistent Offline Storage',
                    desc: 'Every word or sentence translated while connected is cached locally and available without network.',
                  ),
                  Divider(height: 24.h, color: AppColors.borderLight),
                  _buildFeatureRow(
                    icon: Icons.speed_rounded,
                    title: 'Zero Latency',
                    desc: 'Repeated queries load instantaneously with zero data usage.',
                  ),
                  Divider(height: 24.h, color: AppColors.borderLight),
                  _buildFeatureRow(
                    icon: Icons.model_training_rounded,
                    title: 'On-Device ML Ready',
                    desc: 'Compatible with on-device neural translation models for full standalone dictionary translation.',
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Cache Management Button
            CustomButton(
              text: 'Clear Offline Translation Cache',
              variant: ButtonVariant.outlined,
              height: 45.h,
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
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 21.w),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                desc,
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  height: 1.h,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
