/// Crop rectangle in oriented image pixels.
class ImageCropRect {
  final int x;
  final int y;
  final int width;
  final int height;

  const ImageCropRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

/// Maps the on-screen scan box onto a captured photo.
///
/// [previewWidth] and [previewHeight] are the camera plugin's sensor size.
/// The preview widget displays that size swapped (`height / width`), and this
/// mapper uses the same ratio.
class ScanFrameMapper {
  static ImageCropRect cropRect({
    required double viewWidth,
    required double viewHeight,
    required double previewWidth,
    required double previewHeight,
    required int imageWidth,
    required int imageHeight,
    double boxWidthFraction = 0.85,
    double boxHeightFraction = 0.45,
  }) {
    if (imageWidth <= 1 || imageHeight <= 1) {
      return ImageCropRect(x: 0, y: 0, width: imageWidth, height: imageHeight);
    }

    final displayedAspect = (previewWidth <= 0 || previewHeight <= 0)
        ? imageWidth / imageHeight
        : previewHeight / previewWidth;

    late double dispW;
    late double dispH;
    if (viewWidth <= 0 || viewHeight <= 0) {
      dispW = imageWidth.toDouble();
      dispH = imageHeight.toDouble();
    } else if (viewWidth / viewHeight > displayedAspect) {
      dispH = viewHeight;
      dispW = dispH * displayedAspect;
    } else {
      dispW = viewWidth;
      dispH = dispW / displayedAspect;
    }

    final dispLeft = viewWidth <= 0 ? 0.0 : (viewWidth - dispW) / 2;
    final dispTop = viewHeight <= 0 ? 0.0 : (viewHeight - dispH) / 2;

    final boxW = (viewWidth <= 0 ? dispW : viewWidth) * boxWidthFraction;
    final boxH = (viewHeight <= 0 ? dispH : viewHeight) * boxHeightFraction;
    final boxLeft = (viewWidth <= 0 ? dispW : viewWidth - boxW) / 2;
    final boxTop = (viewHeight <= 0 ? dispH : viewHeight - boxH) / 2;

    final left = _max(boxLeft, dispLeft);
    final top = _max(boxTop, dispTop);
    final right = _min(boxLeft + boxW, dispLeft + dispW);
    final bottom = _min(boxTop + boxH, dispTop + dispH);

    final nx = ((left - dispLeft) / dispW).clamp(0.0, 1.0);
    final ny = ((top - dispTop) / dispH).clamp(0.0, 1.0);
    final nw = ((right - left) / dispW).clamp(0.0, 1.0);
    final nh = ((bottom - top) / dispH).clamp(0.0, 1.0);

    var x = (nx * imageWidth).floor();
    var y = (ny * imageHeight).floor();
    var width = (nw * imageWidth).round();
    var height = (nh * imageHeight).round();

    if (x < 0) x = 0;
    if (y < 0) y = 0;
    if (x >= imageWidth) x = imageWidth - 1;
    if (y >= imageHeight) y = imageHeight - 1;
    if (width < 1) width = 1;
    if (height < 1) height = 1;
    if (x + width > imageWidth) width = imageWidth - x;
    if (y + height > imageHeight) height = imageHeight - y;

    return ImageCropRect(x: x, y: y, width: width, height: height);
  }

  static double _max(double a, double b) => a > b ? a : b;
  static double _min(double a, double b) => a < b ? a : b;
}
