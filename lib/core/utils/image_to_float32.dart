

import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:math' as math;


Float32List imageToByteListFloat32(
    int inputSize, double mean, double std, img.Image image) {


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
  print('the convertedbyte from imageToByteListFloat32 function is $convertedBytes');
  return convertedBytes.buffer.asFloat32List();

}

Float32List preProcess(img.Image image, int inputSize) {
  // Resize the image to the required size
  img.Image resizedImage = img.copyResize(image, width: inputSize, height: inputSize);

  // Convert image pixel values to float32
  Float32List float32Image = Float32List(inputSize * inputSize * 3);

  int pixelIndex = 0;
  for (int y = 0; y < inputSize; y++) {
    for (int x = 0; x < inputSize; x++) {
      // Get RGB pixel values
      int pixel = resizedImage.getPixel(x, y);
      float32Image[pixelIndex++] = img.getRed(pixel).toDouble();
      float32Image[pixelIndex++] = img.getGreen(pixel).toDouble();
      float32Image[pixelIndex++] = img.getBlue(pixel).toDouble();
    }
  }

  // Standardize pixel values across channels (global)
  double mean = float32Image.reduce((a, b) => a + b) / float32Image.length;
  double std = float32Image.fold(0, (prev, pixel) => prev + math.pow(pixel - mean, 2));
  std = std / (float32Image.length - 1);
  std = math.sqrt(std);

  for (int i = 0; i < float32Image.length; i++) {
    float32Image[i] = (float32Image[i] - mean) / std;
  }

  print('The preprocessed mean is $mean and std $std');
  print('The Float32List from the preProcess function is $float32Image');

  return float32Image;
}

// Float32List preProcess(img.Image image, int inputSize) {
//   // img.Image faceImage = img.decodeImage(faceBytes)!;
//
//   // Resize the image to the required size
//   img.Image resizedImage =
//   img.copyResize(image, width: inputSize, height: inputSize);
//
//   // Convert image pixel values to float32
//   Float32List float32Image = Float32List(resizedImage.length);
//
//   for (int i = 0; i < resizedImage.length; i++) {
//     float32Image[i] = resizedImage[i].toDouble();
//   }
//
//   // Standardize pixel values across channels (global)
//   double mean = float32Image.reduce((a, b) => a + b) / float32Image.length;
//   double std = float32Image.fold(0, (prev, pixel) => prev + (pixel - mean) * (pixel - mean));
//   std = std / (float32Image.length - 1);
//   std = math.sqrt(std);
//   // std = std.sqrt();
//   print('The pre processed mean is $mean and std $std');
//
//   for (int i = 0; i < float32Image.length; i++) {
//     float32Image[i] = (float32Image[i] - mean) / std;
//   }
//   print('the floatlist from the preProcess fucntion is $float32Image');
//
//
//
//   return float32Image;
// }



