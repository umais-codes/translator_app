import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FileTranslateViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _selectedFileName;
  String? _fileContent;
  String? _translatedContent;
  String? _errorMessage;

  String _fromLanguage = 'en'; // Default: English
  String _toLanguage = 'es'; // Default: Spanish

  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'zh': 'Chinese',
    'ja': 'Japanese',
    'ko': 'Korean',
    'ar': 'Arabic',
    'hi': 'Hindi',
    'ur': 'Urdu',
  };

  bool get isLoading => _isLoading;
  String? get selectedFileName => _selectedFileName;
  String? get fileContent => _fileContent;
  String? get translatedContent => _translatedContent;
  String? get errorMessage => _errorMessage;
  String get fromLanguage => _fromLanguage;
  String get toLanguage => _toLanguage;

  void setFromLanguage(String lang) {
    _fromLanguage = lang;
    notifyListeners();
  }

  void setToLanguage(String lang) {
    _toLanguage = lang;
    notifyListeners();
  }

  void swapLanguages() {
    final temp = _fromLanguage;
    _fromLanguage = _toLanguage;
    _toLanguage = temp;
    notifyListeners();
  }

  Future<void> selectFile() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['txt', 'json', 'csv'],
      );

      if (file != null) {
        _selectedFileName = file.name;

        if (file.path != null) {
          _fileContent = await File(file.path!).readAsString();
        } else {
          final bytes = await file.readAsBytes();
          _fileContent = utf8.decode(bytes);
        }
        _translatedContent = null;
      }
    } catch (e) {
      _errorMessage = 'Error selecting file: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> translateFile() async {
    if (_fileContent == null || _fileContent!.trim().isEmpty) {
      _errorMessage = 'No file content to translate.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _translatedContent = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final encodedText = Uri.encodeComponent(_fileContent!);
      final url =
          'https://api.mymemory.translated.net/get?q=$encodedText&langpair=$_fromLanguage|$_toLanguage';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _translatedContent =
            data['responseData']?['translatedText'] ?? 'Translation failed.';
      } else {
        _errorMessage = 'Failed to fetch translation from server.';
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _isLoading = false;
    _selectedFileName = null;
    _fileContent = null;
    _translatedContent = null;
    _errorMessage = null;
    notifyListeners();
  }
}
