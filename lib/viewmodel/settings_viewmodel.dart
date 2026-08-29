import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator_app/apptheme/app_colors.dart';

class SettingsViewModel extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();

  // TTS & Audio State
  double _speechRate = 0.5;
  double _pitch = 1.0;
  double _volume = 1.0;
  bool _isPlayingSpeech = false;

  // Voice Recognition State
  bool _preferOfflineRecognition = true;
  bool _autoPunctuation = true;
  bool _soundFeedback = true;

  // Theme & Appearance State
  String _selectedTheme = 'Light Mode';
  String _selectedPalette = 'Cobalt Sapphire (Default)';
  Color _primaryColor = const Color(0xFF2563EB);

  // Offline & Storage State
  int _cachedPhrasesCount = 0;
  bool _isClearingCache = false;

  // Feedback State
  bool _isSubmittingFeedback = false;

  SettingsViewModel() {
    _initTts();
    _loadSavedPreferences();
    loadCacheStats();
  }

  // Getters
  double get speechRate => _speechRate;
  double get pitch => _pitch;
  double get volume => _volume;
  bool get isPlayingSpeech => _isPlayingSpeech;

  bool get preferOfflineRecognition => _preferOfflineRecognition;
  bool get autoPunctuation => _autoPunctuation;
  bool get soundFeedback => _soundFeedback;

  String get selectedTheme => _selectedTheme;
  String get selectedPalette => _selectedPalette;
  Color get primaryColor => _primaryColor;

  int get cachedPhrasesCount => _cachedPhrasesCount;
  bool get isClearingCache => _isClearingCache;
  bool get isSubmittingFeedback => _isSubmittingFeedback;

  Future<void> _loadSavedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPalette = prefs.getString('pref_palette');
      if (savedPalette != null) {
        setPalette(savedPalette);
      }
      final savedTheme = prefs.getString('pref_theme');
      if (savedTheme != null) {
        _selectedTheme = savedTheme;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _initTts() async {
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setPitch(_pitch);
    await _flutterTts.setVolume(_volume);

    _flutterTts.setCompletionHandler(() {
      _isPlayingSpeech = false;
      notifyListeners();
    });
  }

  void setSpeechRate(double rate) {
    _speechRate = rate;
    _flutterTts.setSpeechRate(rate);
    notifyListeners();
  }

  void setPitch(double pitch) {
    _pitch = pitch;
    _flutterTts.setPitch(pitch);
    notifyListeners();
  }

  void setVolume(double vol) {
    _volume = vol;
    _flutterTts.setVolume(vol);
    notifyListeners();
  }

  Future<void> testSpeech() async {
    _isPlayingSpeech = true;
    notifyListeners();
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setPitch(_pitch);
    await _flutterTts.setVolume(_volume);
    await _flutterTts.speak('Hello! This is a test of your text-to-speech settings in Translator App.');
  }

  void toggleOfflineRecognition(bool val) {
    _preferOfflineRecognition = val;
    notifyListeners();
  }

  void toggleAutoPunctuation(bool val) {
    _autoPunctuation = val;
    notifyListeners();
  }

  void toggleSoundFeedback(bool val) {
    _soundFeedback = val;
    notifyListeners();
  }

  void setTheme(String theme) async {
    _selectedTheme = theme;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pref_theme', theme);
    } catch (_) {}
  }

  void setPalette(String palette, {Color? color}) async {
    _selectedPalette = palette;
    if (color != null) {
      _primaryColor = color;
    } else {
      switch (palette) {
        case 'Cobalt Sapphire (Default)':
          _primaryColor = const Color(0xFF2563EB);
          break;
        case 'Ocean Indigo':
          _primaryColor = const Color(0xFF1D4ED8);
          break;
        case 'Azure Tech Blue':
          _primaryColor = const Color(0xFF0070F3);
          break;
        case 'Emerald Accent':
          _primaryColor = const Color(0xFF10B981);
          break;
        default:
          _primaryColor = const Color(0xFF2563EB);
      }
    }
    AppColors.updatePalette(_primaryColor);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pref_palette', palette);
    } catch (_) {}
  }

  Future<void> loadCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('offline_trans_'));
      _cachedPhrasesCount = keys.length;
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> clearCache() async {
    _isClearingCache = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('offline_trans_')).toList();
      for (final k in keys) {
        await prefs.remove(k);
      }
      _cachedPhrasesCount = 0;
      _isClearingCache = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isClearingCache = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitFeedback({String? email, required String message}) async {
    if (message.trim().isEmpty) return false;
    _isSubmittingFeedback = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    _isSubmittingFeedback = false;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
