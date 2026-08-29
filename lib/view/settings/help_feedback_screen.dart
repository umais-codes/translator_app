import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/custom_app_bar.dart';
import 'package:translator_app/view/components/custom_button.dart';
import 'package:translator_app/view/components/textfield.dart';
import 'package:translator_app/viewmodel/settings_viewmodel.dart';

class HelpFeedbackScreen extends StatefulWidget {
  const HelpFeedbackScreen({super.key});

  @override
  State<HelpFeedbackScreen> createState() => _HelpFeedbackScreenState();
}

class _HelpFeedbackScreenState extends State<HelpFeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  static const List<Map<String, String>> _faqs = [
    {
      'q': 'How do I use offline translation?',
      'a':
          'Translations are automatically saved in local memory. Any phrase you translate while connected will continue to work offline without internet.',
    },
    {
      'q': 'How does speech recognition work?',
      'a':
          'Tap the microphone icon on the translation or dictionary screen, speak clearly in your selected source language, and the app will convert speech to text and translate automatically.',
    },
    {
      'q': 'Which file formats can I translate?',
      'a':
          'The File Translator supports plain text (.txt), structured JSON (.json), and CSV spreadsheet (.csv) files up to 5MB.',
    },
    {
      'q': 'How do I hear pronunciation of words?',
      'a':
          'Tap the blue speaker / volume icon next to any input or translated result to trigger on-device text-to-speech.',
    },
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final horizontalPadding = screenWidth * 0.045;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Help & Feedback',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: screenHeight * 0.02,
          ),
          children: [
            // FAQ Header
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.outfit(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),

            ..._faqs.map(
              (faq) => Container(
                margin: EdgeInsets.only(bottom: screenHeight * 0.012),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: ExpansionTile(
                  shape: const RoundedRectangleBorder(side: BorderSide.none),
                  collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                  title: Text(
                    faq['q']!,
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.036,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  childrenPadding: EdgeInsets.all(screenWidth * 0.04),
                  children: [
                    Text(
                      faq['a']!,
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.033,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.025),

            // Feedback Form Header
            Text(
              'Send Us Feedback or Report an Issue',
              style: GoogleFonts.outfit(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),

            Container(
              padding: EdgeInsets.all(screenWidth * 0.045),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    label: 'Your Email (Optional)',
                    hintText: 'Enter your email address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  CustomTextField(
                    label: 'Message',
                    hintText: 'How can we improve Translator App?',
                    controller: _feedbackController,
                    maxLines: 4,
                    minLines: 3,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  CustomButton(
                    text: 'Submit Feedback',
                    variant: ButtonVariant.filled,
                    height: screenHeight * 0.055,
                    leadingIcon: Icons.send_rounded,
                    isLoading: vm.isSubmittingFeedback,
                    onPressed: () async {
                      if (_feedbackController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.error,
                            content: Text('Please enter your feedback message'),
                          ),
                        );
                        return;
                      }

                      final success = await vm.submitFeedback(
                        email: _emailController.text.trim(),
                        message: _feedbackController.text.trim(),
                      );

                      if (context.mounted && success) {
                        _feedbackController.clear();
                        _emailController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.success,
                            content: Text('Thank you! Your feedback has been submitted.'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
