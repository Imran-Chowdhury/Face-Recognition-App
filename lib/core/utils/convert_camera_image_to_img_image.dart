import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;


img.Image convertCameraImageToImgImage(CameraImage image, CameraLensDirection dir){

  int width = image.width;
  int height = image.height;
  var bufferImg = img.Image(width, height); //  "create a buffer image"
  const int hexFF = 0xFF000000;
  final int uvyButtonStride = image.planes[1].bytesPerRow;
  final int? uvPixelStride = image.planes[1].bytesPerPixel;
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      final int uvIndex =
          uvPixelStride! * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
      final int index = y * width + x;
      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];
      // Calculate pixel color
      int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
          .round()
          .clamp(0, 255);
      int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
      // color: 0x FF  FF  FF  FF
      //           A   B   G   R
      bufferImg.data[index] = hexFF | (b << 16) | (g << 8) | r;
    }
  }
  var img1 = (dir == CameraLensDirection.front)
      ? img.copyRotate(bufferImg, -90)
      : img.copyRotate(bufferImg, 90);
  return img1;
}
