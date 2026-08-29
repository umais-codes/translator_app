import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/custom_button.dart';
import 'package:translator_app/view/components/language_selector.dart';
import 'package:translator_app/viewmodel/translation_viewmodel.dart';

class HomeTranslateView extends StatelessWidget {
  const HomeTranslateView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TranslationViewModel>();
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

          SizedBox(height: screenHeight * 0.015),

          // 2. Source Translation Input Card
          _buildTranslationInputCard(context, vm, screenWidth, screenHeight),

          SizedBox(height: screenHeight * 0.015),

          // 3. Action Buttons (Translate & Clear)
          Row(
            children: [
              if (vm.sourceText.isNotEmpty || vm.translatedText.isNotEmpty) ...[
                Expanded(
                  flex: 1,
                  child: CustomButton(
                    text: 'Clear',
                    variant: ButtonVariant.outlined,
                    height: screenHeight * 0.055,
                    leadingIcon: Icons.clear_all_rounded,
                    onPressed: vm.clear,
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
              ],
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: vm.isLoading ? 'Translating...' : 'Translate',
                  variant: ButtonVariant.filled,
                  height: screenHeight * 0.055,
                  leadingIcon: Icons.translate_rounded,
                  isLoading: vm.isLoading,
                  onPressed: vm.sourceText.trim().isNotEmpty
                      ? () => vm.translate()
                      : null,
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.015),

          // 4. Translation Output Card
          if (vm.translatedText.isNotEmpty || vm.isLoading) ...[
            _buildTranslationOutputCard(context, vm, screenWidth, screenHeight),
          ],
        ],
      ),
    );
  }

  Widget _buildTranslationInputCard(
    BuildContext context,
    TranslationViewModel vm,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
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
      padding: EdgeInsets.all(screenWidth * 0.045),
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
                  fontSize: screenWidth * 0.032,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              if (vm.sourceText.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                  onPressed: vm.clear,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 6),

          // Editable Text Input Area
          TextField(
            controller: vm.sourceController,
            onChanged: (text) => vm.setSourceText(text),
            maxLines: 5,
            minLines: 3,
            style: GoogleFonts.outfit(
              fontSize: screenWidth * 0.042,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: 'Enter text to translate...',
              hintStyle: GoogleFonts.outfit(
                color: AppColors.textMuted,
                fontSize: screenWidth * 0.04,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
            ),
          ),

          const Divider(height: 24, color: AppColors.borderLight),

          // Bottom Actions inside Source Card: Paste, Speak, Mic
          Row(
            children: [
              // Paste Button
              InkWell(
                onTap: vm.pasteText,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.paste_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Paste',
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.034,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: vm.isListening ? AppColors.micActive : AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (vm.isListening ? AppColors.micActive : AppColors.primary)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    vm.isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: AppColors.textWhite,
                    size: screenWidth * 0.055,
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
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      margin: EdgeInsets.only(top: screenHeight * 0.01),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.045),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    vm.targetLanguage.name.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.032,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.copy_rounded, size: 20, color: AppColors.primary),
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
                      size: 22,
                      color: AppColors.primary,
                    ),
                    onPressed: vm.speakTranslatedText,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            vm.translatedText,
            style: GoogleFonts.outfit(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
