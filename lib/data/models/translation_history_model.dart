class TranslationHistoryItem {
  final String id;
  final String sourceText;
  final String translatedText;
  final String sourceLanguageCode;
  final String sourceLanguageName;
  final String sourceLanguageFlag;
  final String targetLanguageCode;
  final String targetLanguageName;
  final String targetLanguageFlag;
  final DateTime timestamp;
  final bool isFavorite;
  final String category;

  const TranslationHistoryItem({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguageCode,
    required this.sourceLanguageName,
    required this.sourceLanguageFlag,
    required this.targetLanguageCode,
    required this.targetLanguageName,
    required this.targetLanguageFlag,
    required this.timestamp,
    this.isFavorite = false,
    this.category = 'General',
  });

  TranslationHistoryItem copyWith({
    String? id,
    String? sourceText,
    String? translatedText,
    String? sourceLanguageCode,
    String? sourceLanguageName,
    String? sourceLanguageFlag,
    String? targetLanguageCode,
    String? targetLanguageName,
    String? targetLanguageFlag,
    DateTime? timestamp,
    bool? isFavorite,
    String? category,
  }) {
    return TranslationHistoryItem(
      id: id ?? this.id,
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguageCode: sourceLanguageCode ?? this.sourceLanguageCode,
      sourceLanguageName: sourceLanguageName ?? this.sourceLanguageName,
      sourceLanguageFlag: sourceLanguageFlag ?? this.sourceLanguageFlag,
      targetLanguageCode: targetLanguageCode ?? this.targetLanguageCode,
      targetLanguageName: targetLanguageName ?? this.targetLanguageName,
      targetLanguageFlag: targetLanguageFlag ?? this.targetLanguageFlag,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sourceText': sourceText,
      'translatedText': translatedText,
      'sourceLanguageCode': sourceLanguageCode,
      'sourceLanguageName': sourceLanguageName,
      'sourceLanguageFlag': sourceLanguageFlag,
      'targetLanguageCode': targetLanguageCode,
      'targetLanguageName': targetLanguageName,
      'targetLanguageFlag': targetLanguageFlag,
      'timestamp': timestamp.toIso8601String(),
      'isFavorite': isFavorite,
      'category': category,
    };
  }

  factory TranslationHistoryItem.fromMap(Map<String, dynamic> map) {
    return TranslationHistoryItem(
      id: map['id'] as String? ?? '',
      sourceText: map['sourceText'] as String? ?? '',
      translatedText: map['translatedText'] as String? ?? '',
      sourceLanguageCode: map['sourceLanguageCode'] as String? ?? 'en',
      sourceLanguageName: map['sourceLanguageName'] as String? ?? 'English',
      sourceLanguageFlag: map['sourceLanguageFlag'] as String? ?? '🇺🇸',
      targetLanguageCode: map['targetLanguageCode'] as String? ?? 'es',
      targetLanguageName: map['targetLanguageName'] as String? ?? 'Spanish',
      targetLanguageFlag: map['targetLanguageFlag'] as String? ?? '🇪🇸',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      isFavorite: map['isFavorite'] as bool? ?? false,
      category: map['category'] as String? ?? 'General',
    );
  }
}
