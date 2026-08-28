import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Conversation extends StatefulWidget {
  const Conversation({super.key});

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String _inputText = '';
  String _translatedText = '';
  String _inputLanguage = 'en'; // Default input language (English)
  String _outputLanguage = 'ar'; // Default output language (Arabic)

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => debugPrint('Status: $status'),
      onError: (error) => debugPrint('Error: $error'),
    );
    if (available) {
      setState(() {
        _isListening = true;
      });
      _speech.listen(
        localeId: _inputLanguage,
        onResult: (result) {
          setState(() {
            _inputText = result.recognizedWords;
          });
          _translateText(_inputText);
        },
      );
    }
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _speech.stop();
  }

  Future<void> _translateText(String text) async {
    final apiKey =
        "https://api.mymemory.translatd.net/get?q=&lang "; // Replace with your API key
    final url = Uri.parse(
      'https://translation.googleapis.com/language/translate/v2?key=$apiKey',
    );
    final response = await http.post(
      url,
      body: {
        'q': text,
        'source': _inputLanguage,
        'target': _outputLanguage,
        'format': 'text',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _translatedText = data['data']['translations'][0]['translatedText'];
      });
    } else {
      setState(() {
        _translatedText = 'Translation failed. Please try again.';
      });
    }
  }

  Future<void> _speak(String text, String language) async {
    await _flutterTts.setLanguage(language);
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Conversation Screeen',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Input Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Input:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _inputText.isEmpty
                          ? 'Press the microphone to speak...'
                          : _inputText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _isListening ? _stopListening : _startListening,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.redAccent,
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Output Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Output:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _translatedText.isEmpty
                          ? 'Translation will appear here...'
                          : _translatedText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => _speak(_translatedText, _outputLanguage),
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Speak'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Language Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  value: _inputLanguage,
                  items: _getLanguageDropdownItems(),
                  onChanged: (value) {
                    setState(() {
                      _inputLanguage = value!;
                    });
                  },
                ),
                const Icon(Icons.swap_horiz, size: 30),
                DropdownButton<String>(
                  value: _outputLanguage,
                  items: _getLanguageDropdownItems(),
                  onChanged: (value) {
                    setState(() {
                      _outputLanguage = value!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getLanguageDropdownItems() {
    const languages = {
      'en': 'English',
      'ar': 'Arabic',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'zh': 'Chinese',
      'hi': 'Hindi',
      'ja': 'Japanese',
      'ru': 'Russian',
      'ko': 'Korean',
      'pk': 'Pakistani',
      'pt': 'Portuguese',
    };

    return languages.entries
        .map(
          (entry) =>
              DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        )
        .toList();
  }
}
