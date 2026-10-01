import 'package:translator_app/data/models/translation_history_model.dart';

abstract class HistoryStore {
  Future<List<TranslationHistoryItem>> loadHistory();
  Future<void> saveHistory(List<TranslationHistoryItem> items);
  Future<List<String>> loadCategories();
  Future<void> saveCategories(List<String> categories);
}

class MemoryHistoryStore implements HistoryStore {
  List<TranslationHistoryItem> history = [];
  List<String> categories = [];

  @override
  Future<List<TranslationHistoryItem>> loadHistory() async {
    return List<TranslationHistoryItem>.from(history);
  }

  @override
  Future<void> saveHistory(List<TranslationHistoryItem> items) async {
    history = List<TranslationHistoryItem>.from(items);
  }

  @override
  Future<List<String>> loadCategories() async {
    return List<String>.from(categories);
  }

  @override
  Future<void> saveCategories(List<String> categories) async {
    this.categories = List<String>.from(categories);
  }
}
