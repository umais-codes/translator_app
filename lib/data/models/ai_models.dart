enum AIToneOption {
  professional(
    label: 'Professional',
    description: 'Workplace & business communication',
    iconName: 'work_outline_rounded',
  ),
  formal(
    label: 'Formal',
    description: 'Official & academic communication',
    iconName: 'account_balance_outlined',
  ),
  casual(
    label: 'Casual',
    description: 'Natural everyday conversations',
    iconName: 'chat_bubble_outline_rounded',
  ),
  friendly(
    label: 'Friendly',
    description: 'Warm, empathetic & approachable',
    iconName: 'sentiment_satisfied_alt_rounded',
  ),
  polite(
    label: 'Polite',
    description: 'Respectful, courteous & gentle',
    iconName: 'favorite_border_rounded',
  ),
  academic(
    label: 'Academic',
    description: 'Structured, analytical & scholarly',
    iconName: 'school_outlined',
  ),
  concise(
    label: 'Concise',
    description: 'Brief, punchy & straight to the point',
    iconName: 'compress_rounded',
  ),
  creative(
    label: 'Creative',
    description: 'Expressive, vivid & engaging',
    iconName: 'auto_awesome_rounded',
  );

  final String label;
  final String description;
  final String iconName;

  const AIToneOption({
    required this.label,
    required this.description,
    required this.iconName,
  });
}

enum AILengthOption {
  short(label: 'Short', promptModifier: 'Keep it concise and under 15 words.'),
  balanced(label: 'Balanced', promptModifier: 'Keep a natural, balanced length.'),
  detailed(label: 'Detailed', promptModifier: 'Provide a thorough, complete phrasing.');

  final String label;
  final String promptModifier;

  const AILengthOption({required this.label, required this.promptModifier});
}

class AIToneResponse {
  final String originalText;
  final String rephrasedText;
  final AIToneOption tone;
  final List<String> alternatives;
  final String? toneNotes;

  const AIToneResponse({
    required this.originalText,
    required this.rephrasedText,
    required this.tone,
    this.alternatives = const [],
    this.toneNotes,
  });

  factory AIToneResponse.fromMap(Map<String, dynamic> map, String original, AIToneOption tone) {
    final alts = (map['alternatives'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return AIToneResponse(
      originalText: original,
      rephrasedText: map['rephrasedText'] as String? ?? original,
      tone: tone,
      alternatives: alts,
      toneNotes: map['toneNotes'] as String?,
    );
  }
}

class AIGrammarResponse {
  final String originalText;
  final String correctedText;
  final bool hasErrors;
  final String explanation;
  final String grammarRule;
  final List<String> examples;

  const AIGrammarResponse({
    required this.originalText,
    required this.correctedText,
    required this.hasErrors,
    required this.explanation,
    required this.grammarRule,
    this.examples = const [],
  });

  factory AIGrammarResponse.fromMap(Map<String, dynamic> map, String original) {
    final examplesList = (map['examples'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return AIGrammarResponse(
      originalText: original,
      correctedText: map['correctedText'] as String? ?? original,
      hasErrors: map['hasErrors'] as bool? ?? false,
      explanation: map['explanation'] as String? ?? 'No grammatical errors found.',
      grammarRule: map['grammarRule'] as String? ?? 'Standard Grammar',
      examples: examplesList,
    );
  }
}

class AINuanceResponse {
  final String sourceText;
  final String translatedText;
  final String whyChosen;
  final String contextOfUse;
  final List<String> alternatives;
  final String? culturalEtiquette;

  const AINuanceResponse({
    required this.sourceText,
    required this.translatedText,
    required this.whyChosen,
    required this.contextOfUse,
    this.alternatives = const [],
    this.culturalEtiquette,
  });

  factory AINuanceResponse.fromMap(
    Map<String, dynamic> map,
    String source,
    String translation,
  ) {
    final alts = (map['alternatives'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return AINuanceResponse(
      sourceText: source,
      translatedText: translation,
      whyChosen: map['whyChosen'] as String? ?? 'Standard direct translation.',
      contextOfUse: map['contextOfUse'] as String? ?? 'General conversational use.',
      alternatives: alts,
      culturalEtiquette: map['culturalEtiquette'] as String?,
    );
  }
}
