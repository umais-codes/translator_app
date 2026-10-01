import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/language_picker_modal.dart';
import 'package:translator_app/viewmodel/lang_model.dart';

class LanguageSelectorCard extends StatelessWidget {
  final LanguageModel sourceLanguage;
  final LanguageModel targetLanguage;
  final ValueChanged<LanguageModel> onSourceChanged;
  final ValueChanged<LanguageModel> onTargetChanged;
  final VoidCallback onSwap;
  final List<LanguageModel>? customLanguages;

  const LanguageSelectorCard({
    super.key,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.onSourceChanged,
    required this.onTargetChanged,
    required this.onSwap,
    this.customLanguages,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (375 * 0.025).w,
        vertical: (812 * 0.008).h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Source Language Pill
          Expanded(
            child: _buildLanguagePill(
              context: context,
              language: sourceLanguage,
              isSource: true,
            ),
          ),

          // Center Swap Button
          GestureDetector(
            onTap: onSwap,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.lightBlueBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.swap_horiz_rounded,
                color: AppColors.primary,
                size: (375 * 0.055).w,
              ),
            ),
          ),

          // Target Language Pill
          Expanded(
            child: _buildLanguagePill(
              context: context,
              language: targetLanguage,
              isSource: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePill({
    required BuildContext context,
    required LanguageModel language,
    required bool isSource,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () {
        LanguagePickerModal.show(
          context,
          title: isSource ? 'Select Source Language' : 'Select Target Language',
          languages: customLanguages ?? LanguageModel.supportedLanguages,
          selectedLanguage: language,
          onSelected: isSource ? onSourceChanged : onTargetChanged,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: (375 * 0.025).w,
          vertical: (812 * 0.01).h,
        ),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            // Flag Avatar Circle
            Container(
              width: (375 * 0.075).w,
              height: (375 * 0.075).w,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  language.flag,
                  style: TextStyle(fontSize: (375 * 0.042).sp),
                ),
              ),
            ),
            SizedBox(width: 8.w),

            // Language Name
            Expanded(
              child: Text(
                language.name,
                style: GoogleFonts.outfit(
                  fontSize: (375 * 0.036).sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Dropdown Chevron
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
              size: (375 * 0.05).w,
            ),
          ],
        ),
      ),
    );
  }
}
