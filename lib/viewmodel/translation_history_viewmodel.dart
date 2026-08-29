import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator_app/data/models/translation_history_model.dart';
import 'package:translator_app/data/repositories/translation_history_repository.dart';

enum HistorySortOrder {
  newest,
  oldest,
}

class TranslationHistoryViewModel extends ChangeNotifier {
  final TranslationHistoryRepository _repository;
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _searchController = TextEditingController();

  TranslationHistoryViewModel(this._repository) {
    _init();
  }

  List<TranslationHistoryItem> _allItems = [];
  List<String> _categories = [];
  bool _isLoading = false;
  bool _isSearchOpen = false;
  String _searchQuery = '';
  String _selectedCategoryFilter = 'All';
  HistorySortOrder _sortOrder = HistorySortOrder.newest;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSearchOpen => _isSearchOpen;
  String get searchQuery => _searchQuery;
  TextEditingController get searchController => _searchController;
  String get selectedCategoryFilter => _selectedCategoryFilter;
  HistorySortOrder get sortOrder => _sortOrder;
  List<String> get categories => _categories;

  int get totalCount => _allItems.length;
  int get favoritesCount => _allItems.where((i) => i.isFavorite).length;

  List<TranslationHistoryItem> get filteredItems {
    var items = List<TranslationHistoryItem>.from(_allItems);

    // Filter by Tab/Category
    if (_selectedCategoryFilter == '⭐ Favorites') {
      items = items.where((item) => item.isFavorite).toList();
    } else if (_selectedCategoryFilter != 'All') {
      items = items.where((item) => item.category == _selectedCategoryFilter).toList();
    }

    // Filter by Search Query
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      items = items.where((item) {
        return item.sourceText.toLowerCase().contains(query) ||
            item.translatedText.toLowerCase().contains(query) ||
            item.sourceLanguageName.toLowerCase().contains(query) ||
            item.targetLanguageName.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query);
      }).toList();
    }

    // Sorting
    if (_sortOrder == HistorySortOrder.newest) {
      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } else {
      items.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }

    return items;
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    await reload();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> reload() async {
    _allItems = await _repository.getHistory();
    _categories = await _repository.getCategories();
    notifyListeners();
  }

  void toggleSearch() {
    _isSearchOpen = !_isSearchOpen;
    if (!_isSearchOpen) {
      _searchController.clear();
      _searchQuery = '';
    }
    notifyListeners();
  }

  void openSearch() {
    _isSearchOpen = true;
    notifyListeners();
  }

  void closeSearch() {
    _isSearchOpen = false;
    _searchController.clear();
    _searchQuery = '';
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    if (_searchController.text != query) {
      _searchController.text = query;
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchController.clear();
    _searchQuery = '';
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  void setSortOrder(HistorySortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    await _repository.toggleFavorite(id);
    await reload();
  }

  Future<void> updateItemCategory(String id, String category) async {
    await _repository.updateCategory(id, category);
    await reload();
  }

  Future<void> deleteItem(String id) async {
    await _repository.deleteItem(id);
    await reload();
  }

  Future<void> clearHistory({bool keepFavorites = true}) async {
    await _repository.clearHistory(keepFavorites: keepFavorites);
    await reload();
  }

  Future<void> addCategory(String name) async {
    await _repository.addCategory(name);
    await reload();
  }

  Future<void> renameCategory(String oldName, String newName) async {
    await _repository.renameCategory(oldName, newName);
    if (_selectedCategoryFilter == oldName) {
      _selectedCategoryFilter = newName;
    }
    await reload();
  }

  Future<void> deleteCategory(String name) async {
    await _repository.deleteCategory(name);
    if (_selectedCategoryFilter == name) {
      _selectedCategoryFilter = 'All';
    }
    await reload();
  }

  Future<void> speakText(String text, String languageCode) async {
    if (text.trim().isEmpty) return;
    try {
      await _flutterTts.stop();
      await _flutterTts.setLanguage(languageCode);
      await _flutterTts.speak(text);
    } catch (_) {
      // Ignore audio speech errors
    }
  }

  Future<void> copyToClipboard(BuildContext context, String text, String label) async {
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

  @override
  void dispose() {
    _searchController.dispose();
    _flutterTts.stop();
    super.dispose();
  }
}
