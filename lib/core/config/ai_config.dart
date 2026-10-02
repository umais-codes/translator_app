class AIConfig {
  /// Rephrasing and nuance insights need an OpenRouter key.
  /// Pass it at run time; do not commit it:
  /// `--dart-define=OPENROUTER_API_KEY=your_key`
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
