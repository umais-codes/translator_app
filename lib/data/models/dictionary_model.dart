class DictionaryEntry {
  final String word;
  final String? phonetic;
  final List<MeaningModel> meanings;
  final List<String> allSynonyms;
  final List<String> allAntonyms;

  DictionaryEntry({
    required this.word,
    this.phonetic,
    required this.meanings,
    required this.allSynonyms,
    required this.allAntonyms,
  });

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    final word = json['word'] ?? '';

    // Find first non-empty phonetic
    String? phonetic = json['phonetic'];
    if ((phonetic == null || phonetic.isEmpty) && json['phonetics'] != null) {
      for (final p in (json['phonetics'] as List)) {
        if (p['text'] != null && (p['text'] as String).isNotEmpty) {
          phonetic = p['text'];
          break;
        }
      }
    }

    final meanings = <MeaningModel>[];
    final allSynonyms = <String>{};
    final allAntonyms = <String>{};

    if (json['meanings'] != null) {
      for (final m in (json['meanings'] as List)) {
        final meaning = MeaningModel.fromJson(m);
        meanings.add(meaning);
        allSynonyms.addAll(meaning.synonyms);
        allAntonyms.addAll(meaning.antonyms);
        for (final def in meaning.definitions) {
          allSynonyms.addAll(def.synonyms);
          allAntonyms.addAll(def.antonyms);
        }
      }
    }

    return DictionaryEntry(
      word: word,
      phonetic: phonetic,
      meanings: meanings,
      allSynonyms: allSynonyms.toList(),
      allAntonyms: allAntonyms.toList(),
    );
  }
}

class MeaningModel {
  final String partOfSpeech;
  final List<DefinitionModel> definitions;
  final List<String> synonyms;
  final List<String> antonyms;

  MeaningModel({
    required this.partOfSpeech,
    required this.definitions,
    required this.synonyms,
    required this.antonyms,
  });

  factory MeaningModel.fromJson(Map<String, dynamic> json) {
    final definitions = <DefinitionModel>[];
    if (json['definitions'] != null) {
      for (final d in (json['definitions'] as List)) {
        definitions.add(DefinitionModel.fromJson(d));
      }
    }

    final synonyms =
        (json['synonyms'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final antonyms =
        (json['antonyms'] as List?)?.map((e) => e.toString()).toList() ?? [];

    return MeaningModel(
      partOfSpeech: json['partOfSpeech'] ?? '',
      definitions: definitions,
      synonyms: synonyms,
      antonyms: antonyms,
    );
  }
}

class DefinitionModel {
  final String definition;
  final String? example;
  final List<String> synonyms;
  final List<String> antonyms;

  DefinitionModel({
    required this.definition,
    this.example,
    required this.synonyms,
    required this.antonyms,
  });

  factory DefinitionModel.fromJson(Map<String, dynamic> json) {
    return DefinitionModel(
      definition: json['definition'] ?? '',
      example: json['example'],
      synonyms:
          (json['synonyms'] as List?)?.map((e) => e.toString()).toList() ?? [],
      antonyms:
          (json['antonyms'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
