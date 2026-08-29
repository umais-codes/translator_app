import 'package:flutter/material.dart';
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final horizontalPadding = screenWidth * 0.045;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: screenHeight * 0.015,
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

          SizedBox(height: screenHeight * 0.02),

          // 2. Speaker 1 Panel (Input)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.045),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: vm.isListening ? AppColors.primary : AppColors.border,
                width: vm.isListening ? 1.5 : 1,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          vm.inputLanguage.flag,
                          style: TextStyle(fontSize: screenWidth * 0.048),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'You (${vm.inputLanguage.name})',
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.038,
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
                          size: 20,
                          color: AppColors.primary,
                        ),
                        onPressed: () => vm.speak(vm.inputText, vm.inputLanguage.code),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  vm.inputText.isEmpty
                      ? 'Tap the microphone and start speaking...'
                      : vm.inputText,
                  style: GoogleFonts.outfit(
                    fontSize: screenWidth * 0.042,
                    color: vm.inputText.isEmpty
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          // 3. Center Microphone Button
          Center(
            child: GestureDetector(
              onTap: vm.isListening ? vm.stopListening : vm.startListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: screenWidth * 0.18,
                height: screenWidth * 0.18,
                decoration: BoxDecoration(
                  color: vm.isListening ? AppColors.micActive : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: vm.isListening
                          ? AppColors.micActive.withValues(alpha: 0.5)
                          : AppColors.shadowPrimary,
                      blurRadius: vm.isListening ? 18 : 10,
                      spreadRadius: vm.isListening ? 4 : 1,
                    ),
                  ],
                ),
                child: Icon(
                  vm.isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: AppColors.textWhite,
                  size: screenWidth * 0.08,
                ),
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          // 4. Speaker 2 Panel (Output / Translated)
          Container(
            width: double.infinity,
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
                          vm.outputLanguage.flag,
                          style: TextStyle(fontSize: screenWidth * 0.048),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Partner (${vm.outputLanguage.name})',
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.038,
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
                          size: 20,
                          color: AppColors.primary,
                        ),
                        onPressed: () =>
                            vm.speak(vm.translatedText, vm.outputLanguage.code),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  vm.isTranslating
                      ? 'Translating conversation...'
                      : vm.translatedText.isEmpty
                          ? 'Translation will appear here in real-time...'
                          : vm.translatedText,
                  style: GoogleFonts.outfit(
                    fontSize: screenWidth * 0.042,
                    color: vm.translatedText.isEmpty
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                    height: 1.4,
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
