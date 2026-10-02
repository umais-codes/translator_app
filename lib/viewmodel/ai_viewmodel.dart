import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/core/config/ai_config.dart';
import 'package:translator_app/core/router/app_routes.dart';
import 'package:translator_app/data/models/ai_models.dart';
import 'package:translator_app/data/repositories/ai_repository.dart';
import 'package:translator_app/data/services/speech_preferences.dart';
import 'package:translator_app/viewmodel/lang_model.dart';
import 'package:translator_app/viewmodel/translation_viewmodel.dart';

class AIViewModel extends ChangeNotifier {
  final AIRepository _repository;
  final FlutterTts _flutterTts = FlutterTts();

  // Controllers
  final TextEditingController _toneInputController = TextEditingController();
  final TextEditingController _grammarInputController = TextEditingController();
  final TextEditingController _nuanceSourceController = TextEditingController();
  final TextEditingController _nuanceTargetController = TextEditingController();

  AIViewModel(this._repository) {
    _selectedLanguage = LanguageModel.supportedLanguages[0]; // English
    for (final controller in _inputControllers) {
      controller.addListener(_onInputChanged);
    }
  }

  List<TextEditingController> get _inputControllers => [
        _toneInputController,
        _grammarInputController,
        _nuanceSourceController,
        _nuanceTargetController,
      ];

  void _onInputChanged() {
    notifyListeners();
  }

  Future<void> pasteInto(TextEditingController controller) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) return;
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void clearInput(TextEditingController controller) {
    _errorMessage = null;
    if (identical(controller, _toneInputController)) {
      _toneResult = null;
    } else if (identical(controller, _grammarInputController)) {
      _grammarResult = null;
    } else if (identical(controller, _nuanceSourceController) ||
        identical(controller, _nuanceTargetController)) {
      _nuanceResult = null;
    }
    controller.clear();
  }

  int _selectedTabIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Rephrase State
  AIToneOption _selectedTone = AIToneOption.professional;
  AILengthOption _selectedLength = AILengthOption.balanced;
  late LanguageModel _selectedLanguage;
  AIToneResponse? _toneResult;

  // Grammar State
  AIGrammarResponse? _grammarResult;

  // Nuance State
  LanguageModel _nuanceSourceLang = LanguageModel.supportedLanguages[0];
  LanguageModel _nuanceTargetLang = LanguageModel.supportedLanguages[1];
  AINuanceResponse? _nuanceResult;

  // Getters
  int get selectedTabIndex => _selectedTabIndex;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TextEditingController get toneInputController => _toneInputController;
  TextEditingController get grammarInputController => _grammarInputController;
  TextEditingController get nuanceSourceController => _nuanceSourceController;
  TextEditingController get nuanceTargetController => _nuanceTargetController;

  AIToneOption get selectedTone => _selectedTone;
  AILengthOption get selectedLength => _selectedLength;
  LanguageModel get selectedLanguage => _selectedLanguage;
  AIToneResponse? get toneResult => _toneResult;

  AIGrammarResponse? get grammarResult => _grammarResult;

  LanguageModel get nuanceSourceLang => _nuanceSourceLang;
  LanguageModel get nuanceTargetLang => _nuanceTargetLang;
  AINuanceResponse? get nuanceResult => _nuanceResult;

  void setSelectedTab(int index) {
    _selectedTabIndex = index;
    _errorMessage = null;
    notifyListeners();
  }

  void setSelectedTone(AIToneOption tone) {
    if (_selectedTone == tone) return;
    _selectedTone = tone;
    notifyListeners();
    if (_toneResult != null && _toneInputController.text.trim().isNotEmpty) {
      rephraseTone();
    }
  }

  void setSelectedLength(AILengthOption length) {
    if (_selectedLength == length) return;
    _selectedLength = length;
    notifyListeners();
    if (_toneResult != null && _toneInputController.text.trim().isNotEmpty) {
      rephraseTone();
    }
  }

  void setSelectedLanguage(LanguageModel lang) {
    _selectedLanguage = lang;
    notifyListeners();
  }

  void setNuanceSourceLang(LanguageModel lang) {
    _nuanceSourceLang = lang;
    notifyListeners();
  }

  void setNuanceTargetLang(LanguageModel lang) {
    _nuanceTargetLang = lang;
    notifyListeners();
  }

  void swapNuanceLanguages() {
    final tempLang = _nuanceSourceLang;
    _nuanceSourceLang = _nuanceTargetLang;
    _nuanceTargetLang = tempLang;

    final tempText = _nuanceSourceController.text;
    _nuanceSourceController.text = _nuanceTargetController.text;
    _nuanceTargetController.text = tempText;

    if (_nuanceResult != null &&
        _nuanceSourceController.text.trim().isNotEmpty &&
        _nuanceTargetController.text.trim().isNotEmpty) {
      explainNuance();
    } else {
      notifyListeners();
    }
  }

  // --- Preload from Translator Screen ---
  void preloadFromTranslation({
    required String sourceText,
    required String translatedText,
    LanguageModel? sourceLang,
    LanguageModel? targetLang,
    int initialTab = 0,
  }) {
    _selectedTabIndex = initialTab;
    _errorMessage = null;

    if (sourceLang != null) _nuanceSourceLang = sourceLang;
    if (targetLang != null) {
      _nuanceTargetLang = targetLang;
      _selectedLanguage = targetLang;
    }

    if (initialTab == 0) {
      // Rephrase tone of translated or source text
      _toneInputController.text = translatedText.isNotEmpty
          ? translatedText
          : sourceText;
    } else if (initialTab == 1) {
      _grammarInputController.text = sourceText;
    } else if (initialTab == 2) {
      _nuanceSourceController.text = sourceText;
      _nuanceTargetController.text = translatedText;
    }

    notifyListeners();
  }

  // --- Actions ---

  Future<void> rephraseTone() async {
    final text = _toneInputController.text.trim();
    if (text.isEmpty) {
      _errorMessage = 'Please enter or paste text to rephrase.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _toneResult = await _repository.rephraseText(
        text: text,
        tone: _selectedTone,
        length: _selectedLength,
        language: _selectedLanguage.name,
      );
    } on AIUnavailableException catch (e) {
      _toneResult = null;
      _errorMessage = e.message;
    } catch (e) {
      _toneResult = null;
      _errorMessage = 'Could not generate rephrased text. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> explainGrammar() async {
    final text = _grammarInputController.text.trim();
    if (text.isEmpty) {
      _errorMessage = 'Please enter or paste text to check grammar.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _grammarResult = await _repository.explainGrammar(
        text: text,
        language: _selectedLanguage.name,
      );
    } on AIUnavailableException catch (e) {
      _grammarResult = null;
      _errorMessage = e.message;
    } catch (e) {
      _grammarResult = null;
      _errorMessage = 'Could not analyze grammar. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> explainNuance() async {
    final source = _nuanceSourceController.text.trim();
    final target = _nuanceTargetController.text.trim();

    if (source.isEmpty || target.isEmpty) {
      _errorMessage =
          'Please enter both original phrase and translated phrase.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _nuanceResult = await _repository.explainNuance(
        sourceText: source,
        translatedText: target,
        sourceLang: _nuanceSourceLang.name,
        targetLang: _nuanceTargetLang.name,
      );
    } on AIUnavailableException catch (e) {
      _nuanceResult = null;
      _errorMessage = e.message;
    } catch (e) {
      _nuanceResult = null;
      _errorMessage = 'Could not generate nuance insights. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> speakText(String text, String langCode) async {
    if (text.trim().isEmpty) return;
    try {
      await _flutterTts.stop();
      await SpeechPreferences.apply(_flutterTts, languageCode: langCode);
      await _flutterTts.speak(text);
    } catch (_) {
      // Ignore TTS error
    }
  }

  Future<void> copyToClipboard(
    BuildContext context,
    String text,
    String label,
  ) async {
    if (text.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label copied to clipboard'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void replaceIntoTranslator(BuildContext context, String newText) {
    if (newText.trim().isEmpty) return;

    final translationVm = context.read<TranslationViewModel>();

    translationVm.setSourceText(newText);
    translationVm.translateText();

    context.go(AppRoutes.translate);
  }

  @override
  void dispose() {
    for (final controller in _inputControllers) {
      controller.removeListener(_onInputChanged);
    }
    _toneInputController.dispose();
    _grammarInputController.dispose();
    _nuanceSourceController.dispose();
    _nuanceTargetController.dispose();
    _flutterTts.stop();
    super.dispose();
  }
}
