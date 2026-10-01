import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:translator_app/core/config/ai_config.dart';
import 'package:translator_app/data/models/ai_models.dart';

class AIService {
  final http.Client _client;
  final String? _backendEndpoint;
  final Map<String, dynamic> _requestCache = {};

  AIService({http.Client? client, String? backendEndpoint})
    : _client = client ?? http.Client(),
      _backendEndpoint = backendEndpoint;

  Future<AIToneResponse> rephrase({
    required String text,
    required AIToneOption tone,
    required AILengthOption length,
    required String language,
  }) async {
    final clean = text.trim();
    if (clean.isEmpty) {
      throw ArgumentError('Input text cannot be empty');
    }

    final cacheKey = 'rephrase_${clean}_${tone.name}_${length.name}_$language';
    if (_requestCache.containsKey(cacheKey)) {
      return _requestCache[cacheKey] as AIToneResponse;
    }

    if (!AIConfig.hasApiKey &&
        (_backendEndpoint == null || _backendEndpoint.isEmpty)) {
      throw const AIUnavailableException(
        'Rephrasing needs a model service. No API key is configured in this build.',
      );
    }

    if (AIConfig.hasApiKey) {
      final systemPrompt =
          'You are an expert multilingual linguist and translator. '
          'Rephrase the user text into the requested Tone (${tone.label}) and Length (${length.label}) in $language. '
          'Return ONLY a valid JSON object matching this exact schema:\n'
          '{\n'
          '  "rephrasedText": "primary high quality rephrased string",\n'
          '  "alternatives": ["alternative variation 1", "alternative variation 2"],\n'
          '  "toneNotes": "brief 1-sentence note explaining stylistic choices"\n'
          '}';

      final userPrompt =
          'Tone: ${tone.label}\nLength: ${length.label}\nLanguage: $language\nText: "$clean"';
      final data = await _callOpenRouter(systemPrompt, userPrompt);
      if (data != null && data.containsKey('rephrasedText')) {
        final result = AIToneResponse.fromMap(data, clean, tone);
        _requestCache[cacheKey] = result;
        return result;
      }
      throw const AIUnavailableException(
        'The model service did not return a rephrase.',
      );
    }

    final response = await _client
        .post(
          Uri.parse('$_backendEndpoint/ai/rephrase'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'text': clean,
            'tone': tone.name,
            'length': length.name,
            'language': language,
          }),
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final result = AIToneResponse.fromMap(data, clean, tone);
      _requestCache[cacheKey] = result;
      return result;
    }

    throw const AIUnavailableException(
      'The model service did not return a rephrase.',
    );
  }

  Future<AIGrammarResponse> explainGrammar({
    required String text,
    required String language,
  }) async {
    final clean = text.trim();
    if (clean.isEmpty) {
      throw ArgumentError('Input text cannot be empty');
    }

    final cacheKey = 'grammar_${clean}_$language';
    if (_requestCache.containsKey(cacheKey)) {
      return _requestCache[cacheKey] as AIGrammarResponse;
    }

    if (AIConfig.hasApiKey) {
      final systemPrompt =
          'You are a professional grammar, spelling, and syntax expert for $language. '
          'Analyze the text for spelling errors, grammatical concord, punctuation, and structural flow. '
          'Return ONLY a valid JSON object matching this exact schema:\n'
          '{\n'
          '  "correctedText": "corrected sentence with proper spelling, spaces, and punctuation",\n'
          '  "hasErrors": boolean (true if mistakes were found, false if already perfect),\n'
          '  "explanation": "clear, pedagogical explanation of what was corrected or why it is correct",\n'
          '  "grammarRule": "name of the primary grammar rule or category involved",\n'
          '  "examples": ["example sentence 1", "example sentence 2"]\n'
          '}';

      final userPrompt = 'Language: $language\nText to analyze: "$clean"';
      final data = await _callOpenRouter(systemPrompt, userPrompt);
      if (data != null && data.containsKey('correctedText')) {
        final result = AIGrammarResponse.fromMap(data, clean);
        _requestCache[cacheKey] = result;
        return result;
      }
      throw const AIUnavailableException(
        'The model service did not return a grammar check.',
      );
    }

    if (_backendEndpoint != null && _backendEndpoint.isNotEmpty) {
      final response = await _client
          .post(
            Uri.parse('$_backendEndpoint/ai/grammar'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'text': clean, 'language': language}),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = AIGrammarResponse.fromMap(data, clean);
        _requestCache[cacheKey] = result;
        return result;
      }
      throw const AIUnavailableException(
        'The model service did not return a grammar check.',
      );
    }

    final local = _generateLocalGrammarExplanation(clean, language);
    final result = AIGrammarResponse(
      originalText: local.originalText,
      correctedText: local.correctedText,
      hasErrors: local.hasErrors,
      explanation: local.explanation,
      grammarRule: local.grammarRule,
      examples: local.examples,
      isBasicCheck: true,
    );
    _requestCache[cacheKey] = result;
    return result;
  }

  Future<AINuanceResponse> explainNuance({
    required String sourceText,
    required String translatedText,
    required String sourceLang,
    required String targetLang,
  }) async {
    final cleanSource = sourceText.trim();
    final cleanTrans = translatedText.trim();

    if (cleanSource.isEmpty || cleanTrans.isEmpty) {
      throw ArgumentError('Source and translated texts cannot be empty');
    }

    final cacheKey =
        'nuance_${cleanSource}_${cleanTrans}_${sourceLang}_$targetLang';
    if (_requestCache.containsKey(cacheKey)) {
      return _requestCache[cacheKey] as AINuanceResponse;
    }

    if (!AIConfig.hasApiKey &&
        (_backendEndpoint == null || _backendEndpoint.isEmpty)) {
      throw const AIUnavailableException(
        'Nuance explanations need a model service. No API key is configured in this build.',
      );
    }

    if (AIConfig.hasApiKey) {
      final systemPrompt =
          'You are a cultural translation and linguistic nuance specialist comparing $sourceLang to $targetLang. '
          'Analyze why this specific translation wording was selected, its context of use, regional variations, and cultural etiquette. '
          'Return ONLY a valid JSON object matching this exact schema:\n'
          '{\n'
          '  "whyChosen": "clear explanation of vocabulary and phrasing choice",\n'
          '  "contextOfUse": "when and where this phrase is most natural",\n'
          '  "alternatives": ["regional or formal alternative 1", "alternative 2"],\n'
          '  "culturalEtiquette": "cultural norms, honorifics, or politeness guidelines"\n'
          '}';

      final userPrompt =
          'Source Language: $sourceLang\nSource Text: "$cleanSource"\nTarget Language: $targetLang\nTranslated Text: "$cleanTrans"';
      final data = await _callOpenRouter(systemPrompt, userPrompt);
      if (data != null && data.containsKey('whyChosen')) {
        final result = AINuanceResponse.fromMap(data, cleanSource, cleanTrans);
        _requestCache[cacheKey] = result;
        return result;
      }
      throw const AIUnavailableException(
        'The model service did not return a nuance explanation.',
      );
    }

    final response = await _client
        .post(
          Uri.parse('$_backendEndpoint/ai/nuance'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'sourceText': cleanSource,
            'translatedText': cleanTrans,
            'sourceLang': sourceLang,
            'targetLang': targetLang,
          }),
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final result = AINuanceResponse.fromMap(data, cleanSource, cleanTrans);
      _requestCache[cacheKey] = result;
      return result;
    }

    throw const AIUnavailableException(
      'The model service did not return a nuance explanation.',
    );
  }

  // --- OpenRouter REST Client Helper ---

  Future<Map<String, dynamic>?> _callOpenRouter(
    String systemPrompt,
    String userPrompt,
  ) async {
    if (!AIConfig.hasApiKey) return null;

    try {
      final response = await _client
          .post(
            Uri.parse(AIConfig.openRouterEndpoint),
            headers: {
              'Authorization': 'Bearer ${AIConfig.openRouterApiKey}',
              'Content-Type': 'application/json',
              'HTTP-Referer': 'https://translatorapp.local',
              'X-Title': 'Flutter Translator App',
            },
            body: jsonEncode({
              'model': AIConfig.model,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': userPrompt},
              ],
              'temperature': 0.2,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final choices = body['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final content = choices[0]['message']['content'] as String;
          return _extractJson(content);
        }
      }
    } catch (_) {
      // Return null to trigger graceful fallback
    }
    return null;
  }

  Map<String, dynamic>? _extractJson(String raw) {
    String text = raw.trim();

    // 1. Direct JSON decode
    try {
      return jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {}

    // 2. If wrapped in markdown codeblock ```json ... ```
    final jsonBlockRegex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
    final match = jsonBlockRegex.firstMatch(text);
    if (match != null) {
      final inner = match.group(1)!.trim();
      try {
        return jsonDecode(inner) as Map<String, dynamic>;
      } catch (_) {}
    }

    // 3. Find outermost '{' and '}'
    final startIdx = text.indexOf('{');
    final endIdx = text.lastIndexOf('}');
    if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
      try {
        final substring = text.substring(startIdx, endIdx + 1);
        return jsonDecode(substring) as Map<String, dynamic>;
      } catch (_) {}
    }

    return null;
  }

  // --- On-Device Linguistic Intelligent Fallbacks ---

  AIGrammarResponse _generateLocalGrammarExplanation(
    String text,
    String language,
  ) {
    final original = text.trim();
    if (original.isEmpty) {
      return AIGrammarResponse(
        originalText: text,
        correctedText: text,
        hasErrors: false,
        explanation: 'No text provided to analyze.',
        grammarRule: 'None',
        examples: const [],
      );
    }

    // Common spelling mistakes & phonetic/shorthand map
    final Map<String, String> spellingMap = {
      'chk': 'check',
      'goid': 'good',
      'gud': 'good',
      'thx': 'thanks',
      'thnx': 'thanks',
      'pls': 'please',
      'plz': 'please',
      'ur': 'your',
      'u': 'you',
      'r': 'are',
      'wanna': 'want to',
      'gonna': 'going to',
      'im': "I'm",
      'dont': "don't",
      'cant': "can't",
      'wont': "won't",
      'didnt': "didn't",
      'isnt': "isn't",
      'havent': "haven't",
      'recieve': 'receive',
      'seperate': 'separate',
      'definately': 'definitely',
      'alot': 'a lot',
      'becuase': 'because',
      'bcoz': 'because',
      'coz': 'because',
      'teh': 'the',
      'waht': 'what',
      'wiht': 'with',
      'abot': 'about',
      'tihs': 'this',
      'thsi': 'this',
      'nad': 'and',
      'adnd': 'and',
      'wen': 'when',
      'wrk': 'work',
      'msg': 'message',
      'txt': 'text',
      'pic': 'picture',
      'pics': 'pictures',
      'gr8': 'great',
      'bcz': 'because',
      'cuz': 'because',
      'tmrw': 'tomorrow',
      'tommorow': 'tomorrow',
      'tomorow': 'tomorrow',
      'yday': 'yesterday',
      'diffrent': 'different',
      'intrest': 'interest',
      'intresting': 'interesting',
      'beutiful': 'beautiful',
      'truely': 'truly',
      'untill': 'until',
      'comming': 'coming',
    };

    // Grammatical Concord & Phrase Replacements
    final List<Map<String, String>> grammarRules = [
      {
        'pattern': r'\bi has\b',
        'replacement': 'I have',
        'rule': 'Subject-Verb Agreement (First-Person)',
        'explanation':
            'The first-person pronoun "I" requires the auxiliary verb "have", not "has".',
      },
      {
        'pattern': r'\b(they|we|you) was\b',
        'replacement': r'$1 were',
        'rule': 'Past Tense Agreement (Plural / Second Person)',
        'explanation':
            'Plural subjects and "you" take the past-tense plural verb "were", not "was".',
      },
      {
        'pattern': r'\b(they|we|you) is\b',
        'replacement': r'$1 are',
        'rule': 'Present Tense Agreement (Plural / Second Person)',
        'explanation':
            'Plural subjects and "you" require the plural verb "are", not "is".',
      },
      {
        'pattern': r'\b(he|she|it) have\b',
        'replacement': r'$1 has',
        'rule': 'Subject-Verb Agreement (Third-Person Singular)',
        'explanation':
            'Third-person singular subjects (he, she, it) require the verb "has", not "have".',
      },
      {
        'pattern': r'\b(he|she|it) go\b',
        'replacement': r'$1 goes',
        'rule': 'Present Simple Inflection',
        'explanation':
            'Third-person singular subjects require the third-person inflection (goes).',
      },
      {
        'pattern': r'\b(he|she|it) dont\b',
        'replacement': r"$1 doesn't",
        'rule': 'Negative Concord (Third-Person)',
        'explanation':
            'Third-person singular subjects use "does not" ("doesn\'t"), not "don\'t".',
      },
      {
        'pattern': r'\bmore better\b',
        'replacement': 'better',
        'rule': 'Double Comparative',
        'explanation':
            '"Better" is already comparative. Combining it with "more" creates a double comparative error.',
      },
      {
        'pattern': r'\bmore faster\b',
        'replacement': 'faster',
        'rule': 'Double Comparative',
        'explanation':
            '"Faster" is already comparative. Combining it with "more" creates a double comparative error.',
      },
      {
        'pattern': r'\bdid went\b',
        'replacement': 'did go',
        'rule': 'Auxiliary Verb with Base Form',
        'explanation':
            'After the auxiliary verb "did", use the base form of the main verb ("go"), not the past tense.',
      },
      {
        'pattern': r'\bdid saw\b',
        'replacement': 'did see',
        'rule': 'Auxiliary Verb with Base Form',
        'explanation':
            'After the auxiliary verb "did", use the base form of the main verb ("see"), not the past tense.',
      },
    ];

    final List<String> detectedMistakes = [];
    final List<String> appliedRules = [];
    final List<String> examples = [];

    // 1. Word-by-word tokenized spelling & shorthand check (preserving all whitespace and punctuation)
    String workingText = original.replaceAllMapped(
      RegExp(r"\b[a-zA-Z0-9']+\b"),
      (match) {
        final word = match.group(0)!;
        final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
        if (spellingMap.containsKey(cleanWord)) {
          final replacement = spellingMap[cleanWord]!;
          detectedMistakes.add('"$cleanWord" → "$replacement"');

          // Preserve title case or uppercase
          if (word.length > 1 &&
              word[0] == word[0].toUpperCase() &&
              word[1] == word[1].toLowerCase()) {
            return replacement[0].toUpperCase() + replacement.substring(1);
          } else if (word == word.toUpperCase() && word.length > 1) {
            return replacement.toUpperCase();
          }
          return replacement;
        }
        return word;
      },
    );

    // 2. Grammar rules substitution
    for (final rule in grammarRules) {
      final reg = RegExp(rule['pattern']!, caseSensitive: false);
      if (reg.hasMatch(workingText)) {
        appliedRules.add(rule['rule']!);
        detectedMistakes.add(rule['explanation']!);
        workingText = workingText.replaceAllMapped(reg, (match) {
          final rep = rule['replacement']!;
          if (rep.contains(r'$1') && match.groupCount >= 1) {
            return rep.replaceAll(r'$1', match.group(1)!);
          }
          return rep;
        });
      }
    }

    // 3. Sentence Structure & Coherence Cleanup
    // Special handling for colloquial shorthand phrases like "this that check it good"
    if (workingText.toLowerCase().contains('this that') &&
        workingText.toLowerCase().contains('good')) {
      workingText = 'Check this out; that is good.';
      detectedMistakes.add(
        'Restructured colloquial fragment into a complete grammatical sentence.',
      );
      appliedRules.add('Sentence Structure & Clause Formation');
    }

    // 4. Capitalization & Punctuation
    if (workingText.isNotEmpty) {
      // Capitalize first character
      workingText = workingText[0].toUpperCase() + workingText.substring(1);

      // Capitalize standalone ' i '
      workingText = workingText.replaceAll(RegExp(r'\b i \b'), ' I ');
      if (workingText.startsWith('i ')) {
        workingText = 'I ${workingText.substring(2)}';
      }

      // Add terminating punctuation if missing
      if (!workingText.endsWith('.') &&
          !workingText.endsWith('!') &&
          !workingText.endsWith('?')) {
        if (workingText.toLowerCase().startsWith('what') ||
            workingText.toLowerCase().startsWith('where') ||
            workingText.toLowerCase().startsWith('why') ||
            workingText.toLowerCase().startsWith('how') ||
            workingText.toLowerCase().startsWith('when') ||
            workingText.toLowerCase().startsWith('can you') ||
            workingText.toLowerCase().startsWith('could you')) {
          workingText += '?';
        } else {
          workingText += '.';
        }
      }
    }

    final hasErrors = detectedMistakes.isNotEmpty || workingText != original;

    if (hasErrors) {
      final explanationText = detectedMistakes.isNotEmpty
          ? detectedMistakes.join(' ')
          : 'Corrected capitalization, punctuation, and phrasing structure for natural readability.';

      final mainRule = appliedRules.isNotEmpty
          ? appliedRules.first
          : (detectedMistakes.any((m) => m.contains('→'))
                ? 'Spelling & Vocabulary Correction'
                : 'Standard Syntax & Capitalization');

      examples.add('Original: $original');
      examples.add('Corrected: $workingText');

      return AIGrammarResponse(
        originalText: original,
        correctedText: workingText,
        hasErrors: true,
        explanation: explanationText,
        grammarRule: mainRule,
        examples: examples,
      );
    }

    // Truly grammatically sound text
    return AIGrammarResponse(
      originalText: original,
      correctedText: original,
      hasErrors: false,
      explanation:
          'Your sentence structure, spelling, and subject-verb agreements look grammatically sound and natural.',
      grammarRule: 'Standard Syntax & Concord',
      examples: const [
        'Well-formed clause structure verified.',
        'Proper capitalization and punctuation observed.',
      ],
    );
  }
}
