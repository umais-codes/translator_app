class AIConfig {
  /// Rephrasing and nuance insights need an OpenRouter key.
  /// Local only: flutter run --dart-define-from-file=dart_defines.json
  /// Do not compile that key into a release APK. It can be extracted from the app.
  static const String apiKey = '';

  static const String _envApiKey = String.fromEnvironment('OPENROUTER_API_KEY');

  static String get openRouterApiKey =>
      _envApiKey.isNotEmpty ? _envApiKey : apiKey;

  static bool get hasApiKey => openRouterApiKey.isNotEmpty;

  static String model = 'google/gemini-2.0-flash-001';

  static const String openRouterEndpoint =
      'https://openrouter.ai/api/v1/chat/completions';
}

class AIUnavailableException implements Exception {
  final String message;

  const AIUnavailableException(this.message);

  @override
  String toString() => message;
}
