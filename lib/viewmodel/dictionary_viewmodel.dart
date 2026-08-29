import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:translator_app/data/models/dictionary_model.dart';

class DictionaryViewModel extends ChangeNotifier {
  DictionaryEntry? _entry;
  String? _errorMessage;
  bool _isLoading = false;
  String _selectedPartOfSpeech = 'all';
  String _searchQuery = '';
  final FlutterTts _flutterTts = FlutterTts();

  DictionaryEntry? get entry => _entry;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  String get selectedPartOfSpeech => _selectedPartOfSpeech;
  String get searchQuery => _searchQuery;

  // Convenience getters for backward compatibility
  String? get word => _entry?.word;
  String? get phonetics => _entry?.phonetic;
  String? get definition =>
      _entry?.meanings.isNotEmpty == true &&
          _entry!.meanings[0].definitions.isNotEmpty
      ? _entry!.meanings[0].definitions[0].definition
      : null;
  String? get partOfSpeech => _entry?.meanings.isNotEmpty == true
      ? _entry!.meanings[0].partOfSpeech
      : null;
  String? get example =>
      _entry?.meanings.isNotEmpty == true &&
          _entry!.meanings[0].definitions.isNotEmpty
      ? _entry!.meanings[0].definitions[0].example
      : null;
  List<String>? get synonyms => _entry?.allSynonyms;
  List<String>? get antonyms => _entry?.allAntonyms;

  List<String> get partsOfSpeech {
    if (_entry == null) return [];
    return _entry!.meanings.map((m) => m.partOfSpeech.toLowerCase()).toSet().toList();
  }

  List<MeaningModel> get filteredMeanings {
    if (_entry == null) return [];
    if (_selectedPartOfSpeech == 'all') {
      return _entry!.meanings;
    }
    return _entry!.meanings
        .where((m) => m.partOfSpeech.toLowerCase() == _selectedPartOfSpeech.toLowerCase())
        .toList();
  }

  void setSelectedPartOfSpeech(String pos) {
    _selectedPartOfSpeech = pos;
    notifyListeners();
  }

  Future<void> searchWord(String word) async {
    final query = word.trim();
    if (query.isEmpty) return;

    _searchQuery = query;
    _isLoading = true;
    _errorMessage = null;
    _entry = null;
    _selectedPartOfSpeech = 'all';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.dictionaryapi.dev/api/v2/entries/en/${query.toLowerCase()}',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          _entry = DictionaryEntry.fromJson(data[0]);
        } else {
          _errorMessage = 'No definitions found for "$query".';
        }
      } else {
        _errorMessage = 'Word "$query" not found. Check spelling and try again.';
      }
    } catch (e) {
      _errorMessage = 'Network error. Please check your internet connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> speakWord() async {
    if (_entry != null && _entry!.word.isNotEmpty) {
      try {
        await _flutterTts.setLanguage('en-US');
        await _flutterTts.speak(_entry!.word);
      } catch (e) {
        debugPrint('TTS Error: $e');
      }
    }
  }

  void clear() {
    _entry = null;
    _errorMessage = null;
    _isLoading = false;
    _searchQuery = '';
    _selectedPartOfSpeech = 'all';
    notifyListeners();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
