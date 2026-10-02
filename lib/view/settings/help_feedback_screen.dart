import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          'The File Translator supports plain text (.txt), JSON (.json), and CSV (.csv) files up to 100 KB. Longer text is split into short sections, up to 8,000 characters.',
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

    final horizontalPadding = 17.w;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Help & Feedback',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16.h,
          ),
          children: [
            // FAQ Header
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.outfit(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8.h),

            ..._faqs.map(
              (faq) => Container(
                margin: EdgeInsets.only(bottom: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: ExpansionTile(
                  shape: const RoundedRectangleBorder(side: BorderSide.none),
                  collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                  title: Text(
                    faq['q']!,
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  childrenPadding: EdgeInsets.all(15.w),
                  children: [
                    Text(
                      faq['a']!,
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                        height: 1.h,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Feedback Form Header
            Text(
              'Send Us Feedback or Report an Issue',
              style: GoogleFonts.outfit(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8.h),

            Container(
              padding: EdgeInsets.all(17.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20.r),
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
                  SizedBox(height: 12.h),
                  CustomTextField(
                    label: 'Message',
                    hintText: 'How can we improve Translator App?',
                    controller: _feedbackController,
                    maxLines: 4,
                    minLines: 3,
                  ),
                  SizedBox(height: 16.h),
                  CustomButton(
                    text: 'Submit Feedback',
                    variant: ButtonVariant.filled,
                    height: 45.h,
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

                      await vm.submitFeedback(
                        email: _emailController.text.trim(),
                        message: _feedbackController.text.trim(),
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.warning,
                            content: Text(
                              'Feedback is not sent in this build. A delivery service is not connected yet.',
                            ),
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
