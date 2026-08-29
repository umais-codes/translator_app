import 'package:flutter/material.dart';
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.025,
        vertical: screenHeight * 0.008,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
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
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
          ),

          // Center Swap Button
          GestureDetector(
            onTap: onSwap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.lightBlueBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.swap_horiz_rounded,
                color: AppColors.primary,
                size: screenWidth * 0.055,
              ),
            ),
          ),

          // Target Language Pill
          Expanded(
            child: _buildLanguagePill(
              context: context,
              language: targetLanguage,
              isSource: false,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
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
    required double screenWidth,
    required double screenHeight,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
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
          horizontal: screenWidth * 0.025,
          vertical: screenHeight * 0.01,
        ),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            // Flag Avatar Circle
            Container(
              width: screenWidth * 0.075,
              height: screenWidth * 0.075,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  language.flag,
                  style: TextStyle(fontSize: screenWidth * 0.042),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Language Name
            Expanded(
              child: Text(
                language.name,
                style: GoogleFonts.outfit(
                  fontSize: screenWidth * 0.036,
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
              size: screenWidth * 0.05,
            ),
          ],
        ),
      ),
    );
  }
}
