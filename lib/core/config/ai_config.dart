class AIConfig {
  /// Injected at build time with `--dart-define=OPENROUTER_API_KEY=...`.
  /// There is no default key. A key in the app binary can be extracted.
  static const String _envApiKey = String.fromEnvironment('OPENROUTER_API_KEY');

  static String? customApiKey;

  static String get openRouterApiKey {
    if (customApiKey != null && customApiKey!.isNotEmpty) {
      return customApiKey!;
    }
    return _envApiKey;
  }

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
