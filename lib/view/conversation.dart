import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/viewmodel/conversation_viewmodel.dart';

class Conversation extends StatelessWidget {
  const Conversation({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConversationViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final horizontalPadding = screenWidth * 0.05;
    final micRadius = screenWidth * 0.08;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Conversation Screen',
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
              // Input Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Input:',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * 0.035),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlueBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            vm.inputText.isEmpty
                                ? 'Press the microphone to speak...'
                                : vm.inputText,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Center(
                      child: GestureDetector(
                        onTap: vm.isListening
                            ? vm.stopListening
                            : vm.startListening,
                        child: CircleAvatar(
                          radius: micRadius,
                          backgroundColor: vm.isListening
                              ? AppColors.micActive
                              : AppColors.primary,
                          child: Icon(
                            vm.isListening ? Icons.mic : Icons.mic_none,
                            color: AppColors.textWhite,
                            size: micRadius * 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Output Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Output:',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * 0.035),
                        decoration: BoxDecoration(
                          color: AppColors.lightRedBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            vm.isTranslating
                                ? 'Translating...'
                                : vm.translatedText.isEmpty
                                    ? 'Translation will appear here...'
                                    : vm.translatedText,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Center(
                      child: SizedBox(
                        width: screenWidth * 0.45,
                        height: screenHeight * 0.055,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              vm.speak(vm.translatedText, vm.outputLanguage),
                          icon: const Icon(Icons.volume_up),
                          label: Text(
                            'Speak',
                            style: TextStyle(fontSize: screenWidth * 0.04),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textWhite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Language Selection
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.008,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DropdownButton<String>(
                      value: vm.inputLanguage,
                      underline: const SizedBox(),
                      items: _getLanguageDropdownItems(),
                      onChanged: (value) {
                        if (value != null) {
                          vm.setInputLanguage(value);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.swap_horiz,
                        size: screenWidth * 0.07,
                        color: AppColors.primary,
                      ),
                      onPressed: vm.swapLanguages,
                    ),
                    DropdownButton<String>(
                      value: vm.outputLanguage,
                      underline: const SizedBox(),
                      items: _getLanguageDropdownItems(),
                      onChanged: (value) {
                        if (value != null) {
                          vm.setOutputLanguage(value);
                        }
                      },
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

  List<DropdownMenuItem<String>> _getLanguageDropdownItems() {
    return ConversationViewModel.supportedLanguages.entries
        .map(
          (entry) =>
              DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        )
        .toList();
  }
}
