import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:translator_app/core/translation_limits.dart';
import 'package:translator_app/data/models/translation_repository.dart';
import 'package:translator_app/viewmodel/lang_model.dart';

class FileTranslateViewModel extends ChangeNotifier {
  final TranslationRepository _repository;

  FileTranslateViewModel({TranslationRepository? repository})
    : _repository = repository ?? TranslationRepository();
  bool _isLoading = false;
  String? _selectedFileName;
  String? _fileContent;
  String? _translatedContent;
  String? _errorMessage;

  LanguageModel _fromLanguage = LanguageModel.fromCode('en'); // Default: English
  LanguageModel _toLanguage = LanguageModel.fromCode('es'); // Default: Spanish

  bool get isLoading => _isLoading;
  String? get selectedFileName => _selectedFileName;
  String? get fileContent => _fileContent;
  String? get translatedContent => _translatedContent;
  String? get errorMessage => _errorMessage;
  LanguageModel get fromLanguage => _fromLanguage;
  LanguageModel get toLanguage => _toLanguage;

  void setFromLanguage(LanguageModel lang) {
    _fromLanguage = lang;
    notifyListeners();
  }

  void setToLanguage(LanguageModel lang) {
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
        final bytes = file.path != null
            ? await File(file.path!).readAsBytes()
            : await file.readAsBytes();
        if (bytes.length > TranslationLimits.maxFileBytes) {
          _fileContent = null;
          _translatedContent = null;
          _errorMessage =
              'That file is larger than 100 KB. Choose a shorter text file.';
          return;
        }
        _fileContent = utf8.decode(bytes);
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
      _translatedContent = await _repository.translate(
        _fileContent!,
        from: _fromLanguage.code,
        to: _toLanguage.code,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
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
