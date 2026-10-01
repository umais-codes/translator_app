import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpeechSettings {
  final double rate;
  final double pitch;
  final double volume;
  final bool onDevice;

  const SpeechSettings({
    required this.rate,
    required this.pitch,
    required this.volume,
    required this.onDevice,
  });
}

class SpeechPreferences {
  static const rateKey = 'pref_speech_rate';
  static const pitchKey = 'pref_pitch';
  static const volumeKey = 'pref_volume';
  static const onDeviceKey = 'pref_on_device_speech';

  static Future<SpeechSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SpeechSettings(
      rate: prefs.getDouble(rateKey) ?? 0.5,
      pitch: prefs.getDouble(pitchKey) ?? 1.0,
      volume: prefs.getDouble(volumeKey) ?? 1.0,
      onDevice: prefs.getBool(onDeviceKey) ?? false,
    );
  }

  static Future<void> save({
    double? rate,
    double? pitch,
    double? volume,
    bool? onDevice,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (rate != null) await prefs.setDouble(rateKey, rate);
    if (pitch != null) await prefs.setDouble(pitchKey, pitch);
    if (volume != null) await prefs.setDouble(volumeKey, volume);
    if (onDevice != null) await prefs.setBool(onDeviceKey, onDevice);
  }

  static Future<void> apply(FlutterTts tts, {String? languageCode}) async {
    final settings = await load();
    await tts.setSpeechRate(settings.rate);
    await tts.setPitch(settings.pitch);
    await tts.setVolume(settings.volume);
    if (languageCode != null && languageCode.isNotEmpty) {
      await tts.setLanguage(languageCode);
    }
  }
}
