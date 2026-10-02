import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/viewmodel/translation_viewmodel.dart';
import 'package:translator_app/view/components/input_area.dart';

class TextInputArea extends StatelessWidget {
  const TextInputArea({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationViewModel>(context);

    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Paste Button
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  provider.pasteText(); // ✅ calls method from ViewModel
                },
                icon: const Icon(Icons.paste, color: AppColors.textWhite),
                label: const Text(
                  'Paste Text',
                  style: TextStyle(color: AppColors.textWhite),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Text Input Field
          Container(
            height: 81.h,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              onChanged: (text) => provider.setSourceText(text),
              maxLines: null,
              expands: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Type your text here...',
                hintStyle: TextStyle(color: AppColors.textMuted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: AppColors.transparent,
                contentPadding: EdgeInsets.all(16.r),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InputArea()),
                );
              },
            ),
          ),

          SizedBox(height: 16.h),

          // Show Translated Text
          if (provider.translatedText.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.lightBlueBackground,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                provider.translatedText,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Show Loading Indicator
          if (provider.isLoading) ...[
            Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}
