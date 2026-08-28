import 'package:flutter/material.dart';
import 'package:translator_app/view/components/bottom_nav.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/view/components/language_selector.dart';
import 'package:translator_app/view/components/text_input_area.dart';
import 'package:translator_app/view/components/translation_button.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Language Translator',
        showBackButton: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - kToolbarHeight - mediaQuery.padding.top - mediaQuery.padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Text input area
                  const TextInputArea(),

                  SizedBox(height: screenHeight * 0.05),

                  // Microphone button (centered)
                  const Center(child: MicrophoneButton()),

                  SizedBox(height: screenHeight * 0.03),

                  // Language selector
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: const LanguageSelector(),
                  ),

                  const Spacer(),

                  // Bottom navigation
                  const BottomNav(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
