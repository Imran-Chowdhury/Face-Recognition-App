

import 'dart:typed_data';
import 'package:image/image.dart' as img;
Float32List imageToByteListFloat32(
    int inputSize, double mean, double std, img.Image image) {
  // ... Your existing image processing logic remains unchanged ...

  var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
  var buffer = Float32List.view(convertedBytes.buffer);
  int pixelIndex = 0;

  // Resize the image to match the inputSize
  img.Image resizedImage = img.copyResize(image, width: inputSize, height: inputSize);
  // img.Image resizedImage = image;

  for (var y = 0; y < inputSize; y++) {
    for (var x = 0; x < inputSize; x++) {

      var pixel = resizedImage.getPixel(x, y);

      buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std; // test the results by taking mean and std = 127.5
      buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
      buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;


    }
  }
  return convertedBytes.buffer.asFloat32List();
}