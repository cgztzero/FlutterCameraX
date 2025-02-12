///function:
///@author:zhangteng
///@date:2025/2/11
import 'dart:ui';

class ImageUtil {
  static Future<Image> combineImages({
    required Image backgroundImage,
    required Image waterImage,
    required Offset overlayPosition,
  }) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImage(backgroundImage, Offset.zero, Paint());
    canvas.drawImage(waterImage, overlayPosition, Paint());
    final picture = recorder.endRecording();
    return await picture.toImage(backgroundImage.width, backgroundImage.height);
  }

  static Future<Image> resizeImage(Image originImage, double newWidth, double newHeight) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    canvas.drawImageRect(
      originImage,
      Rect.fromLTWH(0, 0, originImage.width.toDouble(), originImage.height.toDouble()),
      Rect.fromLTWH(0, 0, newWidth, newHeight),
      Paint(),
    );
    final Picture picture = pictureRecorder.endRecording();
    return await picture.toImage(newWidth.toInt(), newHeight.toInt());
  }
}
