import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/language_selector.dart';
import 'package:translator_app/viewmodel/conversation_viewmodel.dart';

class Conversation extends StatelessWidget {
  const Conversation({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConversationViewModel>();

    final horizontalPadding = 17.w;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 12.h,
      ),
      child: Column(
        children: [
          // 1. Language Selector Card with Flag Pills
          LanguageSelectorCard(
            sourceLanguage: vm.inputLanguage,
            targetLanguage: vm.outputLanguage,
            onSourceChanged: vm.setInputLanguage,
            onTargetChanged: vm.setOutputLanguage,
            onSwap: vm.swapLanguages,
          ),

          SizedBox(height: 16.h),

          // 2. Speaker 1 Panel (Input)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(17.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: vm.isListening ? AppColors.primary : AppColors.border,
                width: vm.isListening ? 2.w : 1.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          vm.inputLanguage.flag,
                          style: TextStyle(fontSize: 18.sp),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'You (${vm.inputLanguage.name})',
                          style: GoogleFonts.outfit(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    if (vm.inputText.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.volume_up_rounded,
                          size: 20.w,
                          color: AppColors.primary,
                        ),
                        onPressed: () => vm.speak(vm.inputText, vm.inputLanguage.code),
                      ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  vm.inputText.isEmpty
                      ? 'Tap the microphone and start speaking...'
                      : vm.inputText,
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    color: vm.inputText.isEmpty
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                    height: 1.h,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // 3. Center Microphone Button
          Center(
            child: GestureDetector(
              onTap: vm.isListening ? vm.stopListening : vm.startListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 68.w,
                height: 68.w,
                decoration: BoxDecoration(
                  color: vm.isListening ? AppColors.micActive : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: vm.isListening
                          ? AppColors.micActive.withValues(alpha: 0.5)
                          : AppColors.shadowPrimary,
                      blurRadius: vm.isListening ? 18.r : 10.r,
                      spreadRadius: vm.isListening ? 4.r : 1.r,
                    ),
                  ],
                ),
                child: Icon(
                  vm.isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: AppColors.textWhite,
                  size: 30.w,
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // 4. Speaker 2 Panel (Output / Translated)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(17.w),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          vm.outputLanguage.flag,
                          style: TextStyle(fontSize: 18.sp),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Partner (${vm.outputLanguage.name})',
                          style: GoogleFonts.outfit(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    if (vm.translatedText.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.volume_up_rounded,
                          size: 20.w,
                          color: AppColors.primary,
                        ),
                        onPressed: () =>
                            vm.speak(vm.translatedText, vm.outputLanguage.code),
                      ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  vm.isTranslating
                      ? 'Translating conversation...'
                      : vm.translatedText.isEmpty
                          ? 'Translation will appear here in real-time...'
                          : vm.translatedText,
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    color: vm.translatedText.isEmpty
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                    height: 1.h,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
