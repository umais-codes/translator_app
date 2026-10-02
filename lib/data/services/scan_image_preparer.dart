import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:translator_app/core/scan_frame.dart';

class ScanFrameInput {
  final double viewWidth;
  final double viewHeight;
  final double previewWidth;
  final double previewHeight;

  const ScanFrameInput({
    required this.viewWidth,
    required this.viewHeight,
    required this.previewWidth,
    required this.previewHeight,
  });
}

class ScanImagePreparer {
  static const int maxEdge = 1600;

  Future<String> prepareForOcr({
    required String sourcePath,
    ScanFrameInput? frame,
  }) async {
    final bytes = await File(sourcePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw FormatException('Could not read that image.');
    }

    var image = img.bakeOrientation(decoded);
    if (frame != null) {
      final rect = ScanFrameMapper.cropRect(
        viewWidth: frame.viewWidth,
        viewHeight: frame.viewHeight,
        previewWidth: frame.previewWidth,
        previewHeight: frame.previewHeight,
        imageWidth: image.width,
        imageHeight: image.height,
      );
      image = img.copyCrop(
        image,
        x: rect.x,
        y: rect.y,
        width: rect.width,
        height: rect.height,
      );
    }

    image = _downscale(image, maxEdge);
    final jpg = img.encodeJpg(image, quality: 85);
    final out = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}scan_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await out.writeAsBytes(jpg, flush: true);
    return out.path;
  }

  Future<void> discardPrepared(String? path, {required String sourcePath}) async {
    if (path == null || path == sourcePath) return;
    try {
      await File(path).delete();
    } catch (_) {}
  }

  img.Image _downscale(img.Image image, int maxEdge) {
    if (image.width <= maxEdge && image.height <= maxEdge) return image;
    if (image.width >= image.height) {
      return img.copyResize(image, width: maxEdge);
    }
    return img.copyResize(image, height: maxEdge);
  }
}
