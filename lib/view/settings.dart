import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/core/router/app_routes.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {

    final horizontalPadding = 17.w;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Settings',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16.h,
          ),
          children: [
            // App Information Card
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
                    width: 53.w,
                    height: 53.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 10.r,
                          offset: Offset(0, 3.h),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Translator App',
                          style: GoogleFonts.outfit(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Version 1.0.0 • AI-Powered Translation',
                          style: GoogleFonts.outfit(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Section: Audio & Speech
            _buildSectionHeader('Speech & Audio'),
            SizedBox(height: 8.h),
            _buildSettingsTile(
              icon: Icons.volume_up_rounded,
              title: 'Text-to-Speech Speed',
              subtitle: 'Configure speech rate, pitch & voice output',
              onTap: () => context.push(AppRoutes.settingsTts),
            ),
            _buildSettingsTile(
              icon: Icons.mic_rounded,
              title: 'Voice Recognition',
              subtitle: 'Microphone preferences & offline speech',
              onTap: () => context.push(AppRoutes.settingsVoice),
            ),

            SizedBox(height: 24.h),

            // Section: Preferences
            _buildSectionHeader('Appearance & Language'),
            SizedBox(height: 8.h),
            _buildSettingsTile(
              icon: Icons.palette_outlined,
              title: 'App Theme',
              subtitle: 'Choose accent color palette & light mode',
              onTap: () => context.push(AppRoutes.settingsTheme),
            ),
            _buildSettingsTile(
              icon: Icons.offline_bolt_outlined,
              title: 'Offline & Storage',
              subtitle: 'Manage local translation cache & data',
              onTap: () => context.push(AppRoutes.settingsOffline),
            ),

            SizedBox(height: 24.h),

            // Section: About & Help
            _buildSectionHeader('About & Help'),
            SizedBox(height: 8.h),
            _buildSettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'How we protect your data & on-device security',
              onTap: () => context.push(AppRoutes.settingsPrivacy),
            ),
            _buildSettingsTile(
              icon: Icons.help_outline_rounded,
              title: 'Help & Feedback',
              subtitle: 'Frequently asked questions & contact form',
              onTap: () => context.push(AppRoutes.settingsHelp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 15.w,
            vertical: 2.h,
          ),
          leading: Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22.w),
          ),
          title: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14.w,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
