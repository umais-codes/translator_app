import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator_app/data/models/translation_repository.dart';
import 'package:translator_app/viewmodel/lang_model.dart';

class TranslationViewModel extends ChangeNotifier {
  final TranslationRepository _repository;
  final TextEditingController _sourceController = TextEditingController();

  TranslationViewModel(this._repository) {
    _sourceLanguage = LanguageModel.supportedLanguages[0]; // English
    _targetLanguage = LanguageModel.supportedLanguages[1]; // Spanish
    _initializeTts();
    _initializeSpeech();
  }

  String _translatedText = '';
  String _sourceText = '';
  bool _isLoading = false;
  bool _isListening = false;

  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  late LanguageModel _sourceLanguage;
  late LanguageModel _targetLanguage;

  TextEditingController get sourceController => _sourceController;
  String get translatedText => _translatedText;
  String get sourceText => _sourceText;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;

  LanguageModel get sourceLanguage => _sourceLanguage;
  LanguageModel get targetLanguage => _targetLanguage;
  List<LanguageModel> get languages => LanguageModel.supportedLanguages;

  void setSourceLanguage(LanguageModel lang) {
    _sourceLanguage = lang;
    notifyListeners();
    if (_sourceText.trim().isNotEmpty) {
      translateText();
    }
  }

  void setTargetLanguage(LanguageModel lang) {
    _targetLanguage = lang;
    _flutterTts.setLanguage(lang.code);
    notifyListeners();
    if (_sourceText.trim().isNotEmpty) {
      translateText();
    }
  }

  void setLanguages(LanguageModel source, LanguageModel target) {
    _sourceLanguage = source;
    _targetLanguage = target;
    _flutterTts.setLanguage(target.code);
    notifyListeners();
  }

  void swapLanguages() {
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;

    if (_translatedText.isNotEmpty) {
      _sourceText = _translatedText;
      _sourceController.text = _translatedText;
      _translatedText = '';
      translateText();
    }

    _flutterTts.setLanguage(_targetLanguage.code);
    notifyListeners();
  }

  void setSourceText(String text) {
    _sourceText = text;
    if (_sourceController.text != text) {
      _sourceController.text = text;
    }
    notifyListeners();
  }

  Future<void> translateText() async {
    if (_sourceText.trim().isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      _translatedText = await _repository.translate(
        _sourceText,
        from: _sourceLanguage.code,
        to: _targetLanguage.code,
      );
    } catch (e) {
      _translatedText = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void translate() => translateText();

  void clearText() {
    _sourceText = '';
    _sourceController.clear();
    _translatedText = '';
    notifyListeners();
  }

  void clear() => clearText();

  Future<void> pasteText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null && data.text!.isNotEmpty) {
      _sourceText = data.text!;
      _sourceController.text = data.text!;
      notifyListeners();
      translateText();
    }
  }

  Future<void> copyTranslatedText() async {
    if (_translatedText.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _translatedText));
    }
  }

  Future<void> speakSourceText() async {
    if (_sourceText.isNotEmpty) {
      await _flutterTts.setLanguage(_sourceLanguage.code);
      await _flutterTts.speak(_sourceText);
    }
  }

  Future<void> speakTranslatedText() async {
    if (_translatedText.isNotEmpty) {
      await _flutterTts.setLanguage(_targetLanguage.code);
      await _flutterTts.speak(_translatedText);
    }
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _initializeSpeech() async {
    try {
      await _speech.initialize(
        onError: (error) => debugPrint('Speech error: $error'),
        onStatus: (status) => debugPrint('Speech status: $status'),
      );
    } catch (e) {
      debugPrint('Speech initialization skipped: $e');
    }
  }

  Future<void> startListening() async {
    if (!_isListening) {
      try {
        bool available = await _speech.initialize(
          onError: (error) => debugPrint('Speech error: $error'),
          onStatus: (status) => debugPrint('Speech status: $status'),
        );
        if (available) {
          _isListening = true;
          notifyListeners();

          _speech.listen(
            onResult: (result) {
              _sourceText = result.recognizedWords;
              _sourceController.text = result.recognizedWords;
              notifyListeners();
              if (result.finalResult) {
                _isListening = false;
                notifyListeners();
                translateText();
              }
            },
            localeId: _sourceLanguage.code,
          );
        } else {
          debugPrint('Speech recognition not available on this device');
        }
      } catch (e) {
        debugPrint('Speech listening error: $e');
        _isListening = false;
        notifyListeners();
      }
    }
  }

  void stopListening() {
    _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _flutterTts.stop();
    _speech.stop();
    super.dispose();
  }
}
