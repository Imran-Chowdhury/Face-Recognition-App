
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

InputImage convertCameraImageToInputImage(CameraImage image, CameraController controller){
  final WriteBuffer allBytes = WriteBuffer();
  for (Plane plane in image.planes) {
    allBytes.putUint8List(plane.bytes);
  }
  final bytes = allBytes.done().buffer.asUint8List();


  return InputImage.fromBytes(
      // bytes: image.planes[0].bytes,
      bytes: bytes,
      metadata: InputImageMetadata(
          size:Size(image.width.toDouble(),image.height.toDouble()),
          rotation: rotationIntToImageRotation(controller.description.sensorOrientation) ,
          // format: InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21,
        // format: InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.bgra8888,
        // format: InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.yuv_420_888,
        format: InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.yuv420,

          bytesPerRow: image.planes[0].bytesPerRow,
          // format: InputImageFormat.yuv420,

      ));
}


InputImageRotation rotationIntToImageRotation(int rotation) {
  switch (rotation) {
    case 0:
      return InputImageRotation.rotation0deg;
    case 90:
      return InputImageRotation.rotation90deg;
    case 180:
      return InputImageRotation.rotation180deg;
    default:
      assert(rotation == 270);
      return InputImageRotation.rotation270deg;
  }
}
