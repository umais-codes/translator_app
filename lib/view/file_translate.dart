import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/view/components/custom_button.dart';
import 'package:translator_app/view/components/language_selector.dart';
import 'package:translator_app/viewmodel/file_translate_viewmodel.dart';

class FileTranslationScreen extends StatelessWidget {
  const FileTranslationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FileTranslateViewModel>();

    final horizontalPadding = (375 * 0.045).w;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'File Translator',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: (812 * 0.015).h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Language Selector Card with Flag Pills
              LanguageSelectorCard(
                sourceLanguage: vm.fromLanguage,
                targetLanguage: vm.toLanguage,
                onSourceChanged: vm.setFromLanguage,
                onTargetChanged: vm.setToLanguage,
                onSwap: vm.swapLanguages,
              ),

              SizedBox(height: (812 * 0.02).h),

              // 2. Upload Zone Card
              GestureDetector(
                onTap: vm.isLoading ? null : vm.selectFile,
                child: Container(
                  padding: EdgeInsets.all((375 * 0.06).w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: vm.selectedFileName != null
                          ? AppColors.primary
                          : AppColors.border,
                      width: 1.5.w,
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
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlueBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          vm.selectedFileName != null
                              ? Icons.check_circle_rounded
                              : Icons.cloud_upload_rounded,
                          size: (375 * 0.12).w,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        vm.selectedFileName ?? 'Tap to Select Document',
                        style: GoogleFonts.outfit(
                          fontSize: (375 * 0.044).sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Supports .txt, .json, and .csv files',
                        style: GoogleFonts.outfit(
                          fontSize: (375 * 0.034).sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: (812 * 0.02).h),

              // 3. Translate Button
              CustomButton(
                text: 'Translate File',
                variant: ButtonVariant.filled,
                height: (812 * 0.062).h,
                borderRadius: 16,
                leadingIcon: Icons.translate_rounded,
                isLoading: vm.isLoading,
                isDisabled: vm.fileContent == null,
                onPressed: vm.translateFile,
                fontSize: (375 * 0.044).sp,
                fontWeight: FontWeight.bold,
              ),

              if (vm.errorMessage != null) ...[
                SizedBox(height: (812 * 0.015).h),
                Text(
                  vm.errorMessage!,
                  style: GoogleFonts.outfit(
                    color: AppColors.error,
                    fontSize: (375 * 0.036).sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // 4. Translated Output Preview
              if (vm.translatedContent != null) ...[
                SizedBox(height: (812 * 0.02).h),
                Container(
                  padding: EdgeInsets.all((375 * 0.045).w),
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
                                vm.toLanguage.flag,
                                style: TextStyle(fontSize: (375 * 0.048).sp),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Translated Output (${vm.toLanguage.name})',
                                style: GoogleFonts.outfit(
                                  fontSize: (375 * 0.04).sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.copy_rounded, color: AppColors.primary, size: 20.w),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copied translation!')),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        vm.translatedContent!,
                        style: GoogleFonts.outfit(
                          fontSize: (375 * 0.04).sp,
                          color: AppColors.textPrimary,
                          height: 1.4.h,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
