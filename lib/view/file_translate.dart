import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class FileTranslationScreen extends StatefulWidget {
  const FileTranslationScreen({super.key});

  @override
  State<FileTranslationScreen> createState() => _FileTranslationScreenState();
}

class _FileTranslationScreenState extends State<FileTranslationScreen> {
  bool _isLoading = false;
  String? _selectedFileName;
  String? _fileContent;
  String? _translatedContent;
  String? _errorMessage;

  // Default languages
  String _fromLanguage = 'en'; // English
  String _toLanguage = 'es'; // Spanish

  // MyMemory Translation API
  Future<String> _translateText(
    String text,
    String fromLang,
    String toLang,
  ) async {
    try {
      final encodedText = Uri.encodeComponent(text);
      final url =
          'https://api.mymemory.translated.net/get?q=$encodedText&langpair=$fromLang|$toLang';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['responseData']['translatedText'] ?? 'Translation failed.';
      } else {
        throw Exception('Failed to fetch translation.');
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<void> _selectFile() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['txt', 'json', 'csv'],
      );

      if (file != null) {
        _selectedFileName = file.name;

        if (file.path != null) {
          final fileContent = await File(file.path!).readAsString();
          setState(() {
            _fileContent = fileContent;
          });
        } else {
          final bytes = await file.readAsBytes();
          setState(() {
            _fileContent = utf8.decode(bytes);
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error selecting file: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _translateFile() async {
    if (_fileContent == null || _fileContent!.isEmpty) {
      setState(() {
        _errorMessage = 'No file content to translate.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _translatedContent = null;
      _errorMessage = null;
    });

    try {
      final translatedText = await _translateText(
        _fileContent!,
        _fromLanguage,
        _toLanguage,
      );
      setState(() {
        _translatedContent = translatedText;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Translation error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Translator'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // File Picker Section
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _selectFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Select File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
            ),
            if (_selectedFileName != null) ...[
              const SizedBox(height: 10),
              Text(
                'Selected File: $_selectedFileName',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],

            const SizedBox(height: 20),

            // Language Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _fromLanguage,
                  items: _getLanguageDropdownItems(),
                  onChanged: (value) {
                    setState(() {
                      _fromLanguage = value!;
                    });
                  },
                ),
                const Icon(Icons.swap_horiz),
                DropdownButton<String>(
                  value: _toLanguage,
                  items: _getLanguageDropdownItems(),
                  onChanged: (value) {
                    setState(() {
                      _toLanguage = value!;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Translate Button
            ElevatedButton.icon(
              onPressed:
                  _isLoading || _fileContent == null ? null : _translateFile,
              icon: const Icon(Icons.translate),
              label: const Text('Translate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // Loading Indicator
            if (_isLoading) const Center(child: CircularProgressIndicator()),

            // Error Message
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),

            // Translated Content
            if (_translatedContent != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _translatedContent!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getLanguageDropdownItems() {
    const languages = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'zh': 'Chinese',
      'ar': 'Arabic',
      'hi': 'Hindi',
      'ja': 'Japanese',
      'ru': 'Russian',
      'ko': 'Korean',
    };

    return languages.entries
        .map(
          (entry) =>
              DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        )
        .toList();
  }
}
