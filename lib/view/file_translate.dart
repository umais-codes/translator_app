import 'package:flutter/material.dart';
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final horizontalPadding = screenWidth * 0.045;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'File Translator',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: screenHeight * 0.015,
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

              SizedBox(height: screenHeight * 0.02),

              // 2. Upload Zone Card
              GestureDetector(
                onTap: vm.isLoading ? null : vm.selectFile,
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: vm.selectedFileName != null
                          ? AppColors.primary
                          : AppColors.border,
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlueBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          vm.selectedFileName != null
                              ? Icons.check_circle_rounded
                              : Icons.cloud_upload_rounded,
                          size: screenWidth * 0.12,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        vm.selectedFileName ?? 'Tap to Select Document',
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.044,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Supports .txt, .json, and .csv files',
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.034,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // 3. Translate Button
              CustomButton(
                text: 'Translate File',
                variant: ButtonVariant.filled,
                height: screenHeight * 0.062,
                borderRadius: 16,
                leadingIcon: Icons.translate_rounded,
                isLoading: vm.isLoading,
                isDisabled: vm.fileContent == null,
                onPressed: vm.translateFile,
                fontSize: screenWidth * 0.044,
                fontWeight: FontWeight.bold,
              ),

              if (vm.errorMessage != null) ...[
                SizedBox(height: screenHeight * 0.015),
                Text(
                  vm.errorMessage!,
                  style: GoogleFonts.outfit(
                    color: AppColors.error,
                    fontSize: screenWidth * 0.036,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // 4. Translated Output Preview
              if (vm.translatedContent != null) ...[
                SizedBox(height: screenHeight * 0.02),
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.045),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 8,
                        offset: Offset(0, 2),
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
                                style: TextStyle(fontSize: screenWidth * 0.048),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Translated Output (${vm.toLanguage.name})',
                                style: GoogleFonts.outfit(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.copy_rounded, color: AppColors.primary, size: 20),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copied translation!')),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vm.translatedContent!,
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.04,
                          color: AppColors.textPrimary,
                          height: 1.4,
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
