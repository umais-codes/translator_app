import 'package:flutter_test/flutter_test.dart';
import 'package:translator_app/core/ocr_language_support.dart';
import 'package:translator_app/core/scan_frame.dart';
import 'package:translator_app/core/translation_chunker.dart';
import 'package:translator_app/core/translation_limits.dart';

void main() {
  test('short text stays one chunk', () {
    expect(TranslationChunker.split('Hello'), ['Hello']);
  });

  test('long text is split under the query limit', () {
    final text = List.filled(30, 'This is a sentence about travel.').join(' ');
    final chunks = TranslationChunker.split(text);
    expect(chunks.length, greaterThan(1));
    for (final chunk in chunks) {
      expect(chunk.length, lessThanOrEqualTo(TranslationLimits.maxChunkCharacters));
    }
    expect(chunks.join(' '), text);
  });

  test('short paragraphs that fit stay in one chunk', () {
    final chunks = TranslationChunker.split('One paragraph.\n\nTwo paragraph.');
    expect(chunks, ['One paragraph.\n\nTwo paragraph.']);
  });

  test('scan box maps to a centered crop when the preview fills the view', () {
    final rect = ScanFrameMapper.cropRect(
      viewWidth: 400,
      viewHeight: 800,
      previewWidth: 1600,
      previewHeight: 800,
      imageWidth: 800,
      imageHeight: 1600,
    );

    expect(rect.x, 60);
    expect(rect.y, 440);
    expect(rect.width, 680);
    expect(rect.height, 720);
    expect(rect.x + rect.width, lessThanOrEqualTo(800));
    expect(rect.y + rect.height, lessThanOrEqualTo(1600));
  });

  test('ocr script follows the source language', () {
    expect(
      OcrLanguageSupport.forCode('en').kind,
      OcrScriptKind.latin,
    );
    expect(
      OcrLanguageSupport.forCode('zh-cn').kind,
      OcrScriptKind.chinese,
    );
    expect(
      OcrLanguageSupport.forCode('hi').kind,
      OcrScriptKind.devanagari,
    );
    expect(OcrLanguageSupport.forCode('ar').isSupported, isFalse);
    expect(OcrLanguageSupport.forCode('ur').isSupported, isFalse);
    expect(OcrLanguageSupport.forCode('ru').isSupported, isFalse);
    expect(
      OcrLanguageSupport.forCode('ja').kind,
      OcrScriptKind.japanese,
    );
  });
}
