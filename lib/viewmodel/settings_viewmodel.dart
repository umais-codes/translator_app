import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator_app/apptheme/app_colors.dart';
import 'package:translator_app/data/services/speech_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();

  // TTS & Audio State
  double _speechRate = 0.5;
  double _pitch = 1.0;
  double _volume = 1.0;
  bool _isPlayingSpeech = false;

  // Voice Recognition State
  bool _preferOfflineRecognition = false;
  bool _autoPunctuation = true;
  bool _soundFeedback = true;

  // Theme & Appearance State
  String _selectedTheme = 'Light Mode';
  String _selectedPalette = 'Cobalt Sapphire (Default)';
  Color _primaryColor = AppColors.cobaltSapphire;

  // Offline & Storage State
  int _cachedPhrasesCount = 0;
  bool _isClearingCache = false;

  // Feedback State
  bool get isSubmittingFeedback => false;

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

  Future<void> _loadSavedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPalette = prefs.getString('pref_palette');
      if (savedPalette != null) {
        setPalette(savedPalette);
      }
      final savedTheme = prefs.getString('pref_theme');
      if (savedTheme != 'Light Mode' && savedTheme != null) {
        await prefs.setString('pref_theme', 'Light Mode');
      }
      _selectedTheme = 'Light Mode';
      _speechRate = prefs.getDouble(SpeechPreferences.rateKey) ?? _speechRate;
      _pitch = prefs.getDouble(SpeechPreferences.pitchKey) ?? _pitch;
      _volume = prefs.getDouble(SpeechPreferences.volumeKey) ?? _volume;
      _preferOfflineRecognition =
          prefs.getBool(SpeechPreferences.onDeviceKey) ?? false;
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setPitch(_pitch);
      await _flutterTts.setVolume(_volume);
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
    SpeechPreferences.save(rate: rate);
  }

  void setPitch(double pitch) {
    _pitch = pitch;
    _flutterTts.setPitch(pitch);
    notifyListeners();
    SpeechPreferences.save(pitch: pitch);
  }

  void setVolume(double vol) {
    _volume = vol;
    _flutterTts.setVolume(vol);
    notifyListeners();
    SpeechPreferences.save(volume: vol);
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
    SpeechPreferences.save(onDevice: val);
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
    _primaryColor = color ?? AppColors.colorForPalette(palette);
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
    return false;
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
