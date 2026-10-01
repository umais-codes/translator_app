import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:translator_app/core/ocr_language_support.dart';

class OcrService {
  final Map<OcrScriptKind, TextRecognizer> _recognizers = {};
  bool _isClosed = false;

  /// Performs on-device OCR for the requested script.
  /// Returns the extracted text, or an empty string when nothing is readable.
  Future<String> recognizeTextFromPath(
    String imagePath, {
    required OcrScriptKind script,
  }) async {
    if (_isClosed) {
      throw StateError('OcrService is already closed.');
    }
    if (script == OcrScriptKind.unsupported) {
      throw StateError('This script is not supported on device.');
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      throw ArgumentError('Image file does not exist at path: $imagePath');
    }

    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _recognizerFor(script).processImage(inputImage);
    return _formatRecognizedText(recognizedText);
  }

  TextRecognizer _recognizerFor(OcrScriptKind script) {
    return _recognizers.putIfAbsent(script, () {
      return TextRecognizer(script: _pluginScript(script));
    });
  }

  TextRecognitionScript _pluginScript(OcrScriptKind script) {
    switch (script) {
      case OcrScriptKind.chinese:
        return TextRecognitionScript.chinese;
      case OcrScriptKind.devanagari:
        return TextRecognitionScript.devanagiri;
      case OcrScriptKind.japanese:
        return TextRecognitionScript.japanese;
      case OcrScriptKind.korean:
        return TextRecognitionScript.korean;
      case OcrScriptKind.latin:
      case OcrScriptKind.unsupported:
        return TextRecognitionScript.latin;
    }
  }

  String _formatRecognizedText(RecognizedText recognizedText) {
    if (recognizedText.text.trim().isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final text = line.text.trim();
        if (text.isNotEmpty) {
          buffer.writeln(text);
        }
      }
      buffer.writeln();
    }

    return buffer.toString().trim();
  }

  Future<void> dispose() async {
    if (_isClosed) return;
    _isClosed = true;
    for (final recognizer in _recognizers.values) {
      await recognizer.close();
    }
    _recognizers.clear();
  }
}
