import 'package:flutter/material.dart';
import 'package:translator_app/viewmodel/lang_model.dart';

class TranslationProvider extends ChangeNotifier {
  List<LanguageModel> languages = LanguageModel.supportedLanguages;

  late LanguageModel sourceLanguage = languages.first;
  late LanguageModel targetLanguage = languages[1];

  void setSourceLanguage(LanguageModel lang) {
    sourceLanguage = lang;
    notifyListeners();
  }

  void setTargetLanguage(LanguageModel lang) {
    targetLanguage = lang;
    notifyListeners();
  }

  void swapLanguages() {
    final temp = sourceLanguage;
    sourceLanguage = targetLanguage;
    targetLanguage = temp;
    notifyListeners();
  }
}
