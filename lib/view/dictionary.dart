import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:translator_app/view/more_fun.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _word;
  String? _definition;
  String? _partOfSpeech;
  String? _example;
  String? _phonetics;
  List<String>? _synonyms;
  List<String>? _antonyms;
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _searchWord(String word) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _definition = null;
      _partOfSpeech = null;
      _example = null;
      _phonetics = null;
      _synonyms = null;
      _antonyms = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.dictionaryapi.dev/api/v2/entries/en/${word.toLowerCase()}',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty &&
            data[0]['meanings'] != null &&
            data[0]['meanings'][0]['definitions'] != null &&
            data[0]['meanings'][0]['definitions'][0]['definition'] != null) {
          setState(() {
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
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage =
                'Unexpected response format. Please try another word.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Word not found. Please try another word.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dictionary',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MoreFunScreen()),
            );
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _searchWord(value.trim());
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Search for a word',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.blueAccent),
                    onPressed: () {
                      if (_searchController.text.isNotEmpty) {
                        _searchWord(_searchController.text.trim());
                      }
                    },
                  ),
                ),
              ),
            ),
          ),

          // Main Content Area
          Expanded(
            child: Center(
              child:
                  _isLoading
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text(
                            'Searching...',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      )
                      : _errorMessage != null
                      ? Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )
                      : _definition != null
                      ? _buildWordDetails()
                      : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Widget: Word Details
  Widget _buildWordDetails() {
    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Word:', _word),
            _buildDetailRow('Phonetics:', _phonetics, isItalic: true),
            _buildDetailRow('Part of Speech:', _partOfSpeech),
            _buildDetailRow('Definition:', _definition),
            if (_example != null && _example!.isNotEmpty)
              _buildExampleSection(),
            if (_synonyms != null && _synonyms!.isNotEmpty)
              _buildListSection('Synonyms:', _synonyms!),
            if (_antonyms != null && _antonyms!.isNotEmpty)
              _buildListSection('Antonyms:', _antonyms!),
          ],
        ),
      ),
    );
  }

  // Reusable Widget: Detail Row
  Widget _buildDetailRow(String label, String? value, {bool isItalic = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value ?? 'Not available',
            style: TextStyle(
              fontSize: 16,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Widget: Example Section
  Widget _buildExampleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Example:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _example!,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  // Reusable Widget: List Section (for Synonyms and Antonyms)
  Widget _buildListSection(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children:
              items
                  .map(
                    (item) => Chip(
                      label: Text(item),
                      backgroundColor: Colors.blue[50],
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}
