import 'package:flutter_test/flutter_test.dart';
import 'package:translator_app/core/translation_limits.dart';
import 'package:translator_app/data/repositories/history_store.dart';
import 'package:translator_app/data/repositories/translation_history_repository.dart';
import 'package:translator_app/viewmodel/lang_model.dart';

void main() {
  test('history keeps the newest copy of the same phrase', () async {
    final store = MemoryHistoryStore();
    final repository = TranslationHistoryRepository(store: store);

    await repository.saveTranslation(
      sourceText: 'Hello',
      translatedText: 'Hola',
      sourceLanguage: LanguageModel.fromCode('en'),
      targetLanguage: LanguageModel.fromCode('es'),
    );
    await repository.saveTranslation(
      sourceText: 'hello',
      translatedText: 'Hola updated',
      sourceLanguage: LanguageModel.fromCode('en'),
      targetLanguage: LanguageModel.fromCode('es'),
    );

    final history = await repository.getHistory();
    expect(history, hasLength(1));
    expect(history.first.translatedText, 'Hola updated');
    expect(store.history, hasLength(1));
  });

  test('history drops entries past the cap', () async {
    final repository = TranslationHistoryRepository(store: MemoryHistoryStore());
    for (var i = 0; i < TranslationLimits.maxHistoryItems + 5; i++) {
      await repository.saveTranslation(
        sourceText: 'phrase $i',
        translatedText: 'traduccion $i',
        sourceLanguage: LanguageModel.fromCode('en'),
        targetLanguage: LanguageModel.fromCode('es'),
      );
    }

    final history = await repository.getHistory();
    expect(history, hasLength(TranslationLimits.maxHistoryItems));
    expect(history.first.sourceText, 'phrase ${TranslationLimits.maxHistoryItems + 4}');
  });

  test('clear history can keep favorites', () async {
    final repository = TranslationHistoryRepository(store: MemoryHistoryStore());
    await repository.saveTranslation(
      sourceText: 'Keep',
      translatedText: 'Guardar',
      sourceLanguage: LanguageModel.fromCode('en'),
      targetLanguage: LanguageModel.fromCode('es'),
    );
    await repository.saveTranslation(
      sourceText: 'Drop',
      translatedText: 'Quitar',
      sourceLanguage: LanguageModel.fromCode('en'),
      targetLanguage: LanguageModel.fromCode('es'),
    );
    final history = await repository.getHistory();
    await repository.toggleFavorite(history.last.id);
    await repository.clearHistory();

    final remaining = await repository.getHistory();
    expect(remaining, hasLength(1));
    expect(remaining.first.sourceText, 'Keep');
    expect(remaining.first.isFavorite, isTrue);
  });
}
