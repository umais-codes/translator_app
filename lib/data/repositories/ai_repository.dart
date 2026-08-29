import 'package:translator_app/data/models/ai_models.dart';
import 'package:translator_app/data/services/ai_service.dart';

class AIRepository {
  final AIService _aiService;

  AIRepository({AIService? aiService}) : _aiService = aiService ?? AIService();

  Future<AIToneResponse> rephraseText({
    required String text,
    required AIToneOption tone,
    required AILengthOption length,
    required String language,
  }) async {
    return await _aiService.rephrase(
      text: text,
      tone: tone,
      length: length,
      language: language,
    );
  }

  Future<AIGrammarResponse> explainGrammar({
    required String text,
    required String language,
  }) async {
    return await _aiService.explainGrammar(
      text: text,
      language: language,
    );
  }

  Future<AINuanceResponse> explainNuance({
    required String sourceText,
    required String translatedText,
    required String sourceLang,
    required String targetLang,
  }) async {
    return await _aiService.explainNuance(
      sourceText: sourceText,
      translatedText: translatedText,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );
  }
}
