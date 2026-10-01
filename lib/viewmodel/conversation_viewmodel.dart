import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator_app/data/models/translation_repository.dart';
import 'package:translator_app/data/services/speech_preferences.dart';
import 'package:translator_app/viewmodel/lang_model.dart';

class ConversationViewModel extends ChangeNotifier {
  final TranslationRepository _repository;
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  ConversationViewModel({TranslationRepository? repository})
    : _repository = repository ?? TranslationRepository();

  bool _isListening = false;
  bool _isTranslating = false;
  String _inputText = '';
  String _translatedText = '';
  LanguageModel _inputLanguage = LanguageModel.fromCode('en');
  LanguageModel _outputLanguage = LanguageModel.fromCode('ar');

  bool get isListening => _isListening;
  bool get isTranslating => _isTranslating;
  String get inputText => _inputText;
  String get translatedText => _translatedText;
  LanguageModel get inputLanguage => _inputLanguage;
  LanguageModel get outputLanguage => _outputLanguage;

  void setInputLanguage(LanguageModel lang) {
    _inputLanguage = lang;
    notifyListeners();
    if (_inputText.isNotEmpty) {
      translateText(_inputText);
    }
  }

  void setOutputLanguage(LanguageModel lang) {
    _outputLanguage = lang;
    notifyListeners();
    if (_inputText.isNotEmpty) {
      translateText(_inputText);
    }
  }

  void swapLanguages() {
    final temp = _inputLanguage;
    _inputLanguage = _outputLanguage;
    _outputLanguage = temp;

    if (_translatedText.isNotEmpty) {
      _inputText = _translatedText;
      _translatedText = '';
      translateText(_inputText);
    }

    notifyListeners();
  }

  Future<void> startListening() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) => debugPrint('Speech Status: $status'),
        onError: (error) => debugPrint('Speech Error: $error'),
      );
      if (available) {
        _isListening = true;
        notifyListeners();
        final speech = await SpeechPreferences.load();
        _speech.listen(
          listenOptions: stt.SpeechListenOptions(
            localeId: _inputLanguage.code,
            onDevice: speech.onDevice,
            listenMode: stt.ListenMode.dictation,
            partialResults: true,
          ),
          onResult: (result) {
            _inputText = result.recognizedWords;
            notifyListeners();
            if (result.finalResult || _inputText.isNotEmpty) {
              translateText(_inputText);
            }
          },
        );
      }
    } catch (e) {
      debugPrint('Error initializing speech: $e');
      _isListening = false;
      notifyListeners();
    }
  }

  void stopListening() {
    _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  Future<void> translateText(String text) async {
    if (text.trim().isEmpty) return;

    _isTranslating = true;
    notifyListeners();

    try {
      _translatedText = await _repository.translate(
        text,
        from: _inputLanguage.code,
        to: _outputLanguage.code,
      );
    } catch (e) {
      _translatedText = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }

  Future<void> speak(String text, String languageCode) async {
    if (text.trim().isEmpty) return;
    try {
      await SpeechPreferences.apply(_flutterTts, languageCode: languageCode);
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS Error: $e');
    }
  }

  void clear() {
    _inputText = '';
    _translatedText = '';
    _isListening = false;
    _isTranslating = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }
}
