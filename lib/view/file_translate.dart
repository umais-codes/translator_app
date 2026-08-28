import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/viewmodel/file_translate_viewmodel.dart';

class FileTranslationScreen extends StatelessWidget {
  const FileTranslationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FileTranslateViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final horizontalPadding = screenWidth * 0.05;
    final buttonHeight = screenHeight * 0.055;
    final buttonWidth = screenWidth * 0.85;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'File Translator',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            children: [
              // File Picker Section
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: vm.isLoading ? null : vm.selectFile,
                  icon: const Icon(Icons.upload_file),
                  label: Text(
                    'Select File',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              if (vm.selectedFileName != null) ...[
                SizedBox(height: screenHeight * 0.015),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.008,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.description, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          vm.selectedFileName!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.036,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: screenHeight * 0.02),

              // Language Selection
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.006,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: vm.fromLanguage,
                      underline: const SizedBox(),
                      items: _getLanguageDropdownItems(screenWidth),
                      onChanged: (value) {
                        if (value != null) {
                          vm.setFromLanguage(value);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.swap_horiz,
                        color: AppColors.primary,
                        size: screenWidth * 0.065,
                      ),
                      onPressed: vm.swapLanguages,
                    ),
                    DropdownButton<String>(
                      value: vm.toLanguage,
                      underline: const SizedBox(),
                      items: _getLanguageDropdownItems(screenWidth),
                      onChanged: (value) {
                        if (value != null) {
                          vm.setToLanguage(value);
                        }
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Translate Button
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: vm.isLoading || vm.fileContent == null
                      ? null
                      : vm.translateFile,
                  icon: const Icon(Icons.translate),
                  label: Text(
                    'Translate',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.textWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Loading Indicator
              if (vm.isLoading)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),

              // Error Message
              if (vm.errorMessage != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                  child: Text(
                    vm.errorMessage!,
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: screenWidth * 0.038,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Translated Content
              if (vm.translatedContent != null)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        vm.translatedContent!,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getLanguageDropdownItems(double screenWidth) {
    return FileTranslateViewModel.supportedLanguages.entries
        .map(
          (entry) => DropdownMenuItem(
            value: entry.key,
            child: Text(
              entry.value,
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        )
        .toList();
  }
}
