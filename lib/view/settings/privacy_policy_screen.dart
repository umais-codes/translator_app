import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final horizontalPadding = (375 * 0.045).w;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Privacy Policy',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: (812 * 0.02).h,
          ),
          children: [
            // Top Badge Card
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
              child: Row(
                children: [
                  Container(
                    width: (375 * 0.13).w,
                    height: (375 * 0.13).w,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueBackground,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: AppColors.primary,
                      size: (375 * 0.07).w,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Privacy Matters',
                          style: GoogleFonts.outfit(
                            fontSize: (375 * 0.042).sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Last Updated: August 2026',
                          style: GoogleFonts.outfit(
                            fontSize: (375 * 0.032).sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: (812 * 0.025).h),

            _buildSection(
              title: '1. Information We Collect',
              content:
                  'Text you type, speak, or scan is sent to a translation provider so the app can return a translation. Cached phrases stay on this device. There is no on-device translation model.',
            ),

            _buildSection(
              title: '2. On-Device & Offline Processing',
              content:
                  'Phrases translated while online are saved on this device and can be shown again without a network. Camera text recognition runs on the device for Latin, Chinese, Hindi, Japanese, and Korean. Arabic, Urdu, Persian, Bengali, Thai, and Cyrillic are not read by the on-device scanner.',
            ),

            _buildSection(
              title: '3. Speech & Audio Data',
              content:
                  'Audio recordings from your microphone are converted to text locally via system voice APIs. We do not store or transmit raw audio files to external servers.',
            ),

            _buildSection(
              title: '4. Third-Party Services',
              content:
                  'When online, translation text is sent to MyMemory. If that request fails, a second public translation client is tried. Dictionary lookups are sent to dictionaryapi.dev. AI rephrasing and nuance explanations are sent to a model service only when an API key is configured for the build. Grammar can fall back to a basic on-device spelling check, which is labeled in the app.',
            ),

            _buildSection(
              title: '5. Data Security & Storage',
              content:
                  'All saved histories are stored in your device’s sandbox memory. You can clear your local database and translation history at any time from the app settings.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: (812 * 0.015).h),
      padding: EdgeInsets.all((375 * 0.045).w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: (375 * 0.038).sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: (812 * 0.008).h),
          Text(
            content,
            style: GoogleFonts.outfit(
              fontSize: (375 * 0.033).sp,
              color: AppColors.textSecondary,
              height: 1.45.h,
            ),
          ),
        ],
      ),
    );
  }
}
