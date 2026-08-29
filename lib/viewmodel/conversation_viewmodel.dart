import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator_app/viewmodel/lang_model.dart';

class ConversationViewModel extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

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
        _speech.listen(
          localeId: _inputLanguage.code,
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
      final encodedText = Uri.encodeComponent(text);
      final url =
          'https://api.mymemory.translated.net/get?q=$encodedText&langpair=${_inputLanguage.code}|${_outputLanguage.code}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _translatedText =
            data['responseData']?['translatedText'] ?? 'Translation failed.';
      } else {
        _translatedText = 'Translation failed. Please try again.';
      }
    } catch (e) {
      _translatedText = 'Error: ${e.toString()}';
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }

  Future<void> speak(String text, String languageCode) async {
    if (text.trim().isEmpty) return;
    try {
      await _flutterTts.setLanguage(languageCode);
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
