import 'package:translator_app/core/translation_limits.dart';

/// Splits long text into pieces a short translation query can carry.
class TranslationChunker {
  static List<String> split(
    String text, {
    int maxCharacters = TranslationLimits.maxChunkCharacters,
  }) {
    final clean = text.trim();
    if (clean.isEmpty) return const [];
    if (clean.length <= maxCharacters) return [clean];

    final chunks = <String>[];
    final buffer = StringBuffer();

    void flush() {
      final value = buffer.toString().trim();
      buffer.clear();
      if (value.isNotEmpty) chunks.add(value);
    }

    for (final paragraph in clean.split(RegExp(r'\n{2,}'))) {
      final piece = paragraph.trim();
      if (piece.isEmpty) continue;
      if (piece.length > maxCharacters) {
        flush();
        chunks.addAll(_splitOversized(piece, maxCharacters));
        continue;
      }

      final next = buffer.isEmpty ? piece : '${buffer.toString()}\n\n$piece';
      if (next.length > maxCharacters) {
        flush();
        buffer.write(piece);
      } else {
        if (buffer.isNotEmpty) buffer.write('\n\n');
        buffer.write(piece);
      }
    }

    flush();
    return chunks;
  }

  static List<String> _splitOversized(String text, int maxCharacters) {
    final chunks = <String>[];
    final buffer = StringBuffer();

    void flush() {
      final value = buffer.toString().trim();
      buffer.clear();
      if (value.isNotEmpty) chunks.add(value);
    }

    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    for (final sentence in sentences) {
      final piece = sentence.trim();
      if (piece.isEmpty) continue;
      if (piece.length > maxCharacters) {
        flush();
        chunks.addAll(_splitByWords(piece, maxCharacters));
        continue;
      }
      final next = buffer.isEmpty ? piece : '${buffer.toString()} $piece';
      if (next.length > maxCharacters) {
        flush();
        buffer.write(piece);
      } else {
        if (buffer.isNotEmpty) buffer.write(' ');
        buffer.write(piece);
      }
    }

    flush();
    return chunks;
  }

  static List<String> _splitByWords(String text, int maxCharacters) {
    final chunks = <String>[];
    final buffer = StringBuffer();

    void flush() {
      final value = buffer.toString().trim();
      buffer.clear();
      if (value.isNotEmpty) chunks.add(value);
    }

    for (final word in text.split(RegExp(r'\s+'))) {
      if (word.length > maxCharacters) {
        flush();
        for (var i = 0; i < word.length; i += maxCharacters) {
          final end = i + maxCharacters > word.length
              ? word.length
              : i + maxCharacters;
          chunks.add(word.substring(i, end));
        }
        continue;
      }
      final next = buffer.isEmpty ? word : '${buffer.toString()} $word';
      if (next.length > maxCharacters) {
        flush();
        buffer.write(word);
      } else {
        if (buffer.isNotEmpty) buffer.write(' ');
        buffer.write(word);
      }
    }

    flush();
    return chunks;
  }
}
