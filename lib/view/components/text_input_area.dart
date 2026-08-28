import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/viewmodel/translation_viewmodel.dart';
import 'package:translator_app/view/components/input_area.dart';

class TextInputArea extends StatelessWidget {
  const TextInputArea({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationViewModel>(context);
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Text Input Field
          Container(
            height: mediaQuery.size.height * 0.1,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              onChanged: (text) => provider.setSourceText(text),
              maxLines: null,
              expands: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Type your text here...',
                hintStyle: TextStyle(color: AppColors.textMuted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.all(16),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InputArea()),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Show Translated Text
          if (provider.translatedText.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightBlueBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                provider.translatedText,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Show Loading Indicator
          if (provider.isLoading) ...[
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}
