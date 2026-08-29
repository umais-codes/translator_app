import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator_app/data/models/translation_history_model.dart';
import 'package:translator_app/viewmodel/lang_model.dart';

class TranslationHistoryRepository {
  static const String _historyKey = 'translation_history_items_v1';
  static const String _categoriesKey = 'translation_categories_v1';

  static const List<String> defaultCategories = [
    'General',
    'Travel',
    'Work',
    'Study',
    'Personal',
    'Emergency',
  ];

  final List<TranslationHistoryItem> _cachedHistory = [];
  final List<String> _cachedCategories = [];
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();

    // Load categories
    final categoriesJson = prefs.getStringList(_categoriesKey);
    if (categoriesJson != null && categoriesJson.isNotEmpty) {
      _cachedCategories.clear();
      _cachedCategories.addAll(categoriesJson);
    } else {
      _cachedCategories.clear();
      _cachedCategories.addAll(defaultCategories);
      await prefs.setStringList(_categoriesKey, _cachedCategories);
    }

    // Load history
    final historyJson = prefs.getString(_historyKey);
    if (historyJson != null && historyJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(historyJson);
        _cachedHistory.clear();
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            _cachedHistory.add(TranslationHistoryItem.fromMap(item));
          }
        }
      } catch (_) {
        _cachedHistory.clear();
      }
    }

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

    await _ensureInitialized();

    // Deduplication check: if identical source+target+text exists, update its timestamp & place at the top
    final existingIndex = _cachedHistory.indexWhere(
      (item) =>
          item.sourceText.trim().toLowerCase() == cleanSource.toLowerCase() &&
          item.sourceLanguageCode == sourceLanguage.code &&
          item.targetLanguageCode == targetLanguage.code,
    );

    if (existingIndex != -1) {
      final existingItem = _cachedHistory.removeAt(existingIndex);
      final updatedItem = existingItem.copyWith(
        translatedText: cleanTranslated,
        timestamp: DateTime.now(),
      );
      _cachedHistory.insert(0, updatedItem);
    } else {
      final newItem = TranslationHistoryItem(
        id: '${DateTime.now().millisecondsSinceEpoch}_${cleanSource.hashCode}',
        sourceText: cleanSource,
        translatedText: cleanTranslated,
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

    await _persistHistory();
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _cachedHistory.map((item) => item.toMap()).toList();
      await prefs.setString(_historyKey, jsonEncode(list));
    } catch (_) {
      // Ignore cache persistence errors
    }
  }

  Future<void> _persistCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_categoriesKey, _cachedCategories);
    } catch (_) {
      // Ignore cache persistence errors
    }
  }
}
