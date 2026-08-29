import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart' as g_translator;

class TranslationRepository {
  final Map<String, String> _memoryCache = {};
  final g_translator.GoogleTranslator _googleTranslator = g_translator.GoogleTranslator();
  static const String _cachePrefix = 'offline_trans_';

  String _cacheKey(String text, String from, String to) =>
      '${from.toLowerCase()}_${to.toLowerCase()}_${text.trim().toLowerCase()}';

  Future<String> translate(
    String text, {
    required String from,
    required String to,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return '';

    final key = _cacheKey(cleanText, from, to);

    // 1. Check in-memory cache first (Instant response)
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key]!;
    }

    // 2. Check local persistent storage (Offline cache)
    final cached = await _getCachedTranslation(key);
    if (cached != null && cached.isNotEmpty) {
      _memoryCache[key] = cached;
    }

    try {
      // 3. Try primary online endpoint (MyMemory API)
      final encodedText = Uri.encodeComponent(cleanText);
      final url = Uri.parse(
        'https://api.mymemory.translated.net/get?q=$encodedText&langpair=$from|$to',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText = data['responseData']['translatedText'];
        if (translatedText != null &&
            translatedText is String &&
            !translatedText.toUpperCase().contains('MYMEMORY WARNING')) {
          _saveCache(key, translatedText);
          return translatedText;
        }
      }
    } catch (_) {
      // Primary API failed / offline - proceed to fallback
    }

    try {
      // 4. Try secondary online fallback (Google Translator engine)
      final result = await _googleTranslator
          .translate(cleanText, from: from, to: to)
          .timeout(const Duration(seconds: 4));

      if (result.text.isNotEmpty) {
        _saveCache(key, result.text);
        return result.text;
      }
    } catch (_) {
      // Secondary failed / completely offline
    }

    // 5. If completely offline and has local cached version, return it
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    // 6. Offline fallback error message
    throw Exception(
      'No internet connection and translation is not available offline in cache. Please connect to the internet to download/cache this phrase.',
    );
  }

  Future<String?> _getCachedTranslation(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_cachePrefix$key');
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveCache(String key, String translatedText) async {
    _memoryCache[key] = translatedText;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_cachePrefix$key', translatedText);
    } catch (_) {
      // Ignore cache write failures
    }
  }
}