import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DictionaryViewModel extends ChangeNotifier {
  String? _word;
  String? _definition;
  String? _partOfSpeech;
  String? _example;
  String? _phonetics;
  List<String>? _synonyms;
  List<String>? _antonyms;
  String? _errorMessage;
  bool _isLoading = false;

  String? get word => _word;
  String? get definition => _definition;
  String? get partOfSpeech => _partOfSpeech;
  String? get example => _example;
  String? get phonetics => _phonetics;
  List<String>? get synonyms => _synonyms;
  List<String>? get antonyms => _antonyms;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> searchWord(String word) async {
    final query = word.trim();
    if (query.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    _definition = null;
    _partOfSpeech = null;
    _example = null;
    _phonetics = null;
    _synonyms = null;
    _antonyms = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.dictionaryapi.dev/api/v2/entries/en/${query.toLowerCase()}',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty &&
            data[0]['meanings'] != null &&
            data[0]['meanings'][0]['definitions'] != null &&
            data[0]['meanings'][0]['definitions'][0]['definition'] != null) {
          _word = data[0]['word'];
          _definition =
              data[0]['meanings'][0]['definitions'][0]['definition'];
          _partOfSpeech = data[0]['meanings'][0]['partOfSpeech'];
          _example =
              data[0]['meanings'][0]['definitions'][0]['example'] ??
              'No example available.';
          _phonetics =
              data[0]['phonetics'] != null &&
                      data[0]['phonetics'].isNotEmpty &&
                      data[0]['phonetics'][0]['text'] != null
                  ? data[0]['phonetics'][0]['text']
                  : 'Not available';
          _synonyms =
              data[0]['meanings'][0]['definitions'][0]['synonyms']
                  ?.cast<String>() ??
              [];
          _antonyms =
              data[0]['meanings'][0]['definitions'][0]['antonyms']
                  ?.cast<String>() ??
              [];
        } else {
          _errorMessage =
              'Unexpected response format. Please try another word.';
        }
      } else {
        _errorMessage = 'Word not found. Please try another word.';
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again later.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _word = null;
    _definition = null;
    _partOfSpeech = null;
    _example = null;
    _phonetics = null;
    _synonyms = null;
    _antonyms = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
