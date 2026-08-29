import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/data/models/translation_provider.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/view/components/language_selector.dart';

class TranslationScreen extends StatelessWidget {
  const TranslationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final horizontalPadding = screenWidth * 0.05;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Translate",
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.swap_horiz,
              color: AppColors.textWhite,
              size: screenWidth * 0.065,
            ),
            onPressed: () => provider.swapLanguages(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            children: [
              LanguageSelectorCard(
                sourceLanguage: provider.sourceLanguage,
                targetLanguage: provider.targetLanguage,
                onSourceChanged: provider.setSourceLanguage,
                onTargetChanged: provider.setTargetLanguage,
                onSwap: provider.swapLanguages,
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Text(
                    provider.sourceLanguage.name,
                    style: TextStyle(
                      fontSize: screenWidth * 0.042,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.volume_up,
                      color: AppColors.primary,
                      size: screenWidth * 0.055,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              TextField(
                decoration: const InputDecoration(
                  hintText: "Enter Text",
                ),
                onChanged: (value) {},
              ),
              SizedBox(height: screenHeight * 0.015),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.paste),
                    label: Text(
                      "Paste Text",
                      style: TextStyle(fontSize: screenWidth * 0.038),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.textWhite,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.012,
                      ),
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: screenWidth * 0.06,
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      icon: Icon(
                        Icons.mic,
                        color: AppColors.textWhite,
                        size: screenWidth * 0.06,
                      ),
                      onPressed: () {
                        // Voice input hook
                      },
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                  horizontal: screenWidth * 0.04,
                ),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.sourceLanguage.flag,
                      style: TextStyle(fontSize: screenWidth * 0.05),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      provider.sourceLanguage.name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: screenWidth * 0.038,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.025),
                    Icon(
                      Icons.compare_arrows,
                      color: AppColors.primary,
                      size: screenWidth * 0.05,
                    ),
                    SizedBox(width: screenWidth * 0.025),
                    Text(
                      provider.targetLanguage.flag,
                      style: TextStyle(fontSize: screenWidth * 0.05),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      provider.targetLanguage.name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: screenWidth * 0.038,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
