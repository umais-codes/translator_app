import 'package:flutter/material.dart';
import 'package:translator_app/viewmodel/lang_model.dart';

class TranslationProvider extends ChangeNotifier {
  List<LanguageModel> languages = [
    LanguageModel(code: 'en', name: 'English', flagAsset: 'us'),
    LanguageModel(code: 'ur', name: 'Urdu (Pakistan)', flagAsset: 'pk'),
    LanguageModel(code: 'hi', name: 'Hindi', flagAsset: 'in'),
    LanguageModel(code: 'fr', name: 'French', flagAsset: 'fr'),
    LanguageModel(code: 'es', name: 'Spanish', flagAsset: 'es'),
    LanguageModel(code: 'de', name: 'German', flagAsset: 'de'),
    LanguageModel(code: 'ar', name: 'Arabic', flagAsset: 'sa'),
    LanguageModel(code: 'zh', name: 'Chinese', flagAsset: 'cn'),
    LanguageModel(code: 'ru', name: 'Russian', flagAsset: 'ru'),
    LanguageModel(code: 'ja', name: 'Japanese', flagAsset: 'jp'),
    LanguageModel(code: 'ko', name: 'Korean', flagAsset: 'kr'),
    LanguageModel(code: 'it', name: 'Italian', flagAsset: 'it'),
    LanguageModel(code: 'pt', name: 'Portuguese', flagAsset: 'pt'),
    LanguageModel(code: 'bn', name: 'Bengali', flagAsset: 'bd'),
    LanguageModel(code: 'fa', name: 'Persian', flagAsset: 'ir'),
    LanguageModel(code: 'ps', name: 'Pashto', flagAsset: 'af'),
    LanguageModel(code: 'tr', name: 'Turkish', flagAsset: 'tr'),
    LanguageModel(code: 'id', name: 'Indonesian', flagAsset: 'id'),
    LanguageModel(code: 'ms', name: 'Malay', flagAsset: 'my'),
    LanguageModel(code: 'sw', name: 'Swahili', flagAsset: 'ke'),
    LanguageModel(code: 'am', name: 'Amharic', flagAsset: 'et'),
    LanguageModel(code: 'he', name: 'Hebrew', flagAsset: 'il'),
    LanguageModel(code: 'th', name: 'Thai', flagAsset: 'th'),
    LanguageModel(code: 'vi', name: 'Vietnamese', flagAsset: 'vn'),
    LanguageModel(code: 'pl', name: 'Polish', flagAsset: 'pl'),
    LanguageModel(code: 'ro', name: 'Romanian', flagAsset: 'ro'),
    LanguageModel(code: 'uk', name: 'Ukrainian', flagAsset: 'ua'),
    LanguageModel(code: 'hu', name: 'Hungarian', flagAsset: 'hu'),
    LanguageModel(code: 'cs', name: 'Czech', flagAsset: 'cz'),
    LanguageModel(code: 'sv', name: 'Swedish', flagAsset: 'se'),
    LanguageModel(code: 'no', name: 'Norwegian', flagAsset: 'no'),
    LanguageModel(code: 'fi', name: 'Finnish', flagAsset: 'fi'),
    LanguageModel(code: 'el', name: 'Greek', flagAsset: 'gr'),
    LanguageModel(code: 'ta', name: 'Tamil', flagAsset: 'lk'),
    LanguageModel(code: 'te', name: 'Telugu', flagAsset: 'in'),
    LanguageModel(code: 'ml', name: 'Malayalam', flagAsset: 'in'),
    LanguageModel(code: 'gu', name: 'Gujarati', flagAsset: 'in'),
    LanguageModel(code: 'mr', name: 'Marathi', flagAsset: 'in'),
    LanguageModel(code: 'kn', name: 'Kannada', flagAsset: 'in'),
    LanguageModel(code: 'pa', name: 'Punjabi', flagAsset: 'pk'),
    LanguageModel(code: 'ne', name: 'Nepali', flagAsset: 'np'),
  ];

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
