import 'package:translator_app/data/models/translation_history_model.dart';
import 'package:translator_app/data/repositories/history_store.dart';
import 'package:translator_app/data/repositories/sqlite_history_store.dart';
import 'package:translator_app/core/translation_limits.dart';
import 'package:translator_app/viewmodel/lang_model.dart';

class TranslationHistoryRepository {
  static const List<String> defaultCategories = [
    'General',
    'Travel',
    'Work',
    'Study',
    'Personal',
    'Emergency',
  ];

  final HistoryStore _store;
  final List<TranslationHistoryItem> _cachedHistory = [];
  final List<String> _cachedCategories = [];
  bool _isInitialized = false;

  TranslationHistoryRepository({HistoryStore? store})
    : _store = store ?? SqliteHistoryStore();

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    final categories = await _store.loadCategories();
    _cachedCategories
      ..clear()
      ..addAll(categories.isEmpty ? defaultCategories : categories);
    if (categories.isEmpty) {
      await _store.saveCategories(_cachedCategories);
    }

    final history = await _store.loadHistory();
    _cachedHistory
      ..clear()
      ..addAll(history);

    _isInitialized = true;
  }

  Future<List<TranslationHistoryItem>> getHistory() async {
    await _ensureInitialized();
    return List.unmodifiable(_cachedHistory);
  }

  Future<List<String>> getCategories() async {
    await _ensureInitialized();
    return List.unmodifiable(_cachedCategories);
  }

  Future<void> saveTranslation({
    required String sourceText,
    required String translatedText,
    required LanguageModel sourceLanguage,
    required LanguageModel targetLanguage,
    String category = 'General',
  }) async {
    final cleanSource = sourceText.trim();
    final cleanTranslated = translatedText.trim();

    if (cleanSource.isEmpty ||
        cleanTranslated.isEmpty ||
        cleanTranslated.startsWith('Error:')) {
      return;
    }

    final limitedSource = _limit(cleanSource);
    final limitedTranslation = _limit(cleanTranslated);

    await _ensureInitialized();

    final existingIndex = _cachedHistory.indexWhere(
      (item) =>
          item.sourceText.trim().toLowerCase() == limitedSource.toLowerCase() &&
          item.sourceLanguageCode == sourceLanguage.code &&
          item.targetLanguageCode == targetLanguage.code,
    );

    if (existingIndex != -1) {
      final existingItem = _cachedHistory.removeAt(existingIndex);
      final updatedItem = existingItem.copyWith(
        translatedText: limitedTranslation,
        timestamp: DateTime.now(),
      );
      _cachedHistory.insert(0, updatedItem);
    } else {
      final newItem = TranslationHistoryItem(
        id: '${DateTime.now().millisecondsSinceEpoch}_${limitedSource.hashCode}',
        sourceText: limitedSource,
        translatedText: limitedTranslation,
        sourceLanguageCode: sourceLanguage.code,
        sourceLanguageName: sourceLanguage.name,
        sourceLanguageFlag: sourceLanguage.flag,
        targetLanguageCode: targetLanguage.code,
        targetLanguageName: targetLanguage.name,
        targetLanguageFlag: targetLanguage.flag,
        timestamp: DateTime.now(),
        category: category,
      );
      _cachedHistory.insert(0, newItem);
    }

    if (_cachedHistory.length > TranslationLimits.maxHistoryItems) {
      _cachedHistory.removeRange(
        TranslationLimits.maxHistoryItems,
        _cachedHistory.length,
      );
    }

    await _persistHistory();
  }

  String _limit(String value) {
    if (value.length <= TranslationLimits.maxHistoryTextCharacters) return value;
    return '${value.substring(0, TranslationLimits.maxHistoryTextCharacters)}…';
  }

  Future<void> toggleFavorite(String id) async {
    await _ensureInitialized();
    final index = _cachedHistory.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _cachedHistory[index];
      _cachedHistory[index] = item.copyWith(isFavorite: !item.isFavorite);
      await _persistHistory();
    }
  }

  Future<void> updateCategory(String id, String category) async {
    await _ensureInitialized();
    final index = _cachedHistory.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _cachedHistory[index];
      _cachedHistory[index] = item.copyWith(category: category);
      await _persistHistory();
    }
  }

  Future<void> deleteItem(String id) async {
    await _ensureInitialized();
    _cachedHistory.removeWhere((item) => item.id == id);
    await _persistHistory();
  }

  Future<void> clearHistory({bool keepFavorites = true}) async {
    await _ensureInitialized();
    if (keepFavorites) {
      _cachedHistory.removeWhere((item) => !item.isFavorite);
    } else {
      _cachedHistory.clear();
    }
    await _persistHistory();
  }

  Future<void> addCategory(String categoryName) async {
    final clean = categoryName.trim();
    if (clean.isEmpty) return;

    await _ensureInitialized();
    if (!_cachedCategories.contains(clean)) {
      _cachedCategories.add(clean);
      await _persistCategories();
    }
  }

  Future<void> renameCategory(String oldName, String newName) async {
    final clean = newName.trim();
    if (clean.isEmpty || oldName == clean) return;

    await _ensureInitialized();
    final index = _cachedCategories.indexOf(oldName);
    if (index != -1) {
      _cachedCategories[index] = clean;
      await _persistCategories();

      // Update all items in this category
      for (var i = 0; i < _cachedHistory.length; i++) {
        if (_cachedHistory[i].category == oldName) {
          _cachedHistory[i] = _cachedHistory[i].copyWith(category: clean);
        }
      }
      await _persistHistory();
    }
  }

  Future<void> deleteCategory(String categoryName) async {
    await _ensureInitialized();
    _cachedCategories.remove(categoryName);
    await _persistCategories();

    // Move orphaned items back to 'General'
    for (var i = 0; i < _cachedHistory.length; i++) {
      if (_cachedHistory[i].category == categoryName) {
        _cachedHistory[i] = _cachedHistory[i].copyWith(category: 'General');
      }
    }
    await _persistHistory();
  }

  Future<void> _persistHistory() async {
    await _store.saveHistory(_cachedHistory);
  }

  Future<void> _persistCategories() async {
    await _store.saveCategories(_cachedCategories);
  }
}
