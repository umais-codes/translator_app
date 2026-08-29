import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _isClosed = false;

  /// Performs on-device Optical Character Recognition (OCR) on an image file.
  /// Returns the extracted clean text, or empty string if no readable text was detected.
  Future<String> recognizeTextFromPath(String imagePath) async {
    if (_isClosed) {
      throw StateError('OcrService is already closed.');
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      throw ArgumentError('Image file does not exist at path: $imagePath');
    }

    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _textRecognizer.processImage(inputImage);

    return _formatRecognizedText(recognizedText);
  }

  /// Extracts and cleans lines/paragraphs from recognized text blocks.
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
      buffer.writeln(); // Separate blocks with empty line
    }

    return buffer.toString().trim();
  }

  /// Closes and releases native ML Kit OCR resources.
  Future<void> dispose() async {
    if (!_isClosed) {
      _isClosed = true;
      await _textRecognizer.close();
    }
  }
}
