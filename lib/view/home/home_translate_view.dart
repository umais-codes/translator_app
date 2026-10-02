import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/core/router/app_routes.dart';
import 'package:translator_app/view/components/custom_button.dart';
import 'package:translator_app/view/components/custom_chip.dart';
import 'package:translator_app/view/components/language_selector.dart';
import 'package:translator_app/viewmodel/ai_viewmodel.dart';
import 'package:translator_app/viewmodel/translation_viewmodel.dart';

class HomeTranslateView extends StatelessWidget {
  const HomeTranslateView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TranslationViewModel>();

    final horizontalPadding = 17.w;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 12.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Language Selector Card
          LanguageSelectorCard(
            sourceLanguage: vm.sourceLanguage,
            targetLanguage: vm.targetLanguage,
            onSourceChanged: vm.setSourceLanguage,
            onTargetChanged: vm.setTargetLanguage,
            onSwap: vm.swapLanguages,
          ),

          SizedBox(height: 12.h),

          // 2. Source Translation Input Card
          _buildTranslationInputCard(context, vm),

          SizedBox(height: 12.h),

          // 3. Action Buttons (Translate & Clear)
          Row(
            children: [
              if (vm.sourceText.isNotEmpty || vm.translatedText.isNotEmpty) ...[
                Expanded(
                  flex: 1,
                  child: CustomButton(
                    text: 'Clear',
                    variant: ButtonVariant.outlined,
                    height: 45.h,
                    leadingIcon: Icons.clear_all_rounded,
                    onPressed: vm.clear,
                  ),
                ),
                SizedBox(width: 11.w),
              ],
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: vm.isLoading ? 'Translating...' : 'Translate',
                  variant: ButtonVariant.filled,
                  height: 45.h,
                  leadingIcon: Icons.translate_rounded,
                  isLoading: vm.isLoading,
                  onPressed: vm.sourceText.trim().isNotEmpty
                      ? () => vm.translate()
                      : null,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // 4. Translation Output Card
          if (vm.translatedText.isNotEmpty || vm.isLoading) ...[
            _buildTranslationOutputCard(context, vm),
          ],
        ],
      ),
    );
  }

  Widget _buildTranslationInputCard(
    BuildContext context,
    TranslationViewModel vm,
  ) {
    return Container(
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
      padding: EdgeInsets.all(17.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header inside card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                vm.sourceLanguage.name.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              if (vm.sourceText.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 18.w, color: AppColors.textSecondary),
                  onPressed: vm.clear,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          SizedBox(height: 6.h),

          // Editable Text Input Area
          TextField(
            controller: vm.sourceController,
            onChanged: (text) => vm.setSourceText(text),
            maxLines: 5,
            minLines: 3,
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              color: AppColors.textPrimary,
              height: 1.h,
            ),
            decoration: InputDecoration(
              hintText: 'Enter text to translate...',
              hintStyle: GoogleFonts.outfit(
                color: AppColors.textMuted,
                fontSize: 15.sp,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              fillColor: AppColors.transparent,
              contentPadding: EdgeInsets.zero,
            ),
          ),

          Divider(height: 24.h, color: AppColors.borderLight),

          // Bottom Actions inside Source Card: Paste, Speak, Mic
          Row(
            children: [
              // Paste Button
              InkWell(
                onTap: vm.pasteText,
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.paste_rounded, size: 16.w, color: AppColors.primary),
                      SizedBox(width: 4.w),
                      Text(
                        'Paste',
                        style: GoogleFonts.outfit(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 10.w),

              // Source Audio Playback
              if (vm.sourceText.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.volume_up_rounded, color: AppColors.primary),
                  onPressed: vm.speakSourceText,
                ),

              const Spacer(),

              // Voice Input Button
              GestureDetector(
                onTap: vm.isListening ? vm.stopListening : vm.startListening,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: vm.isListening ? AppColors.micActive : AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (vm.isListening ? AppColors.micActive : AppColors.primary)
                            .withValues(alpha: 0.3),
                        blurRadius: 8.r,
                        spreadRadius: 2.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    vm.isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: AppColors.textWhite,
                    size: 21.w,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationOutputCard(
    BuildContext context,
    TranslationViewModel vm,
  ) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 2.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      padding: EdgeInsets.all(17.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    vm.targetLanguage.name.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.copy_rounded, size: 20.w, color: AppColors.primary),
                    onPressed: () {
                      vm.copyTranslatedText();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.volume_up_rounded,
                      size: 22.w,
                      color: AppColors.primary,
                    ),
                    onPressed: vm.speakTranslatedText,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            vm.translatedText,
            style: GoogleFonts.outfit(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.h,
            ),
          ),

          if (vm.translatedText.isNotEmpty && !vm.translatedText.startsWith('Error:')) ...[
            SizedBox(height: 12.h),
            Divider(height: 1.h),
            SizedBox(height: 8.h),

            // AI Action Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CustomChip(
                    icon: Icons.auto_awesome_rounded,
                    label: 'AI Rephrase Tone',
                    variant: CustomChipVariant.tonal,
                    size: CustomChipSize.small,
                    onTap: () {
                      context.read<AIViewModel>().preloadFromTranslation(
                            sourceText: vm.sourceText,
                            translatedText: vm.translatedText,
                            sourceLang: vm.sourceLanguage,
                            targetLang: vm.targetLanguage,
                            initialTab: 0,
                          );
                      context.push(AppRoutes.ai);
                    },
                  ),
                  SizedBox(width: 8.w),
                  CustomChip(
                    icon: Icons.lightbulb_outline_rounded,
                    label: 'Explain Nuance',
                    variant: CustomChipVariant.tonal,
                    size: CustomChipSize.small,
                    activeColor: AppColors.info,
                    activeTextColor: AppColors.info,
                    onTap: () {
                      context.read<AIViewModel>().preloadFromTranslation(
                            sourceText: vm.sourceText,
                            translatedText: vm.translatedText,
                            sourceLang: vm.sourceLanguage,
                            targetLang: vm.targetLanguage,
                            initialTab: 2,
                          );
                      context.push(AppRoutes.ai);
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
