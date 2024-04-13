
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:face/core/base_state/base_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../../core/utils/convert_camera_image_to_img_image.dart';
import '../../../../core/utils/convert_camera_image_to_input_image.dart';
import '../../../face_detection/presentation/riverpod/face_detection_provider.dart';
import '../../../recognize_face/presentation/riverpod/recognize_face_provider.dart';

import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;






class LiveFeedScreen extends ConsumerStatefulWidget {

  LiveFeedScreen({Key? key, required this.detectionController, required this.faceDetector, required this.cameras, required this.interpreter, required this.livenessInterpreter, required this.nameOfJsonFile}) : super(key: key);

  final FaceDetectionNotifier detectionController;
  final FaceDetector faceDetector;
  late List<CameraDescription> cameras;
  final tf_lite.Interpreter interpreter;
  final tf_lite.Interpreter livenessInterpreter;
  late String nameOfJsonFile;

  @override
  ConsumerState<LiveFeedScreen> createState() => _LiveFeedScreenState();
}


// 2. extend [ConsumerState]
class _LiveFeedScreenState extends ConsumerState<LiveFeedScreen> {
  late CameraController controller;
  int numberOfFrames  = 0;
  // int frameSkipCount = 15;
  int frameSkipCount = 25;
  // int frameSkipCount = 40;
  List frameList = [];
  String message = '';



  @override
  void initState() {
    super.initState();
    initializeCameras();
  }

  Future<void> initializeCameras() async {

    controller = CameraController(
      widget.cameras[1],
      // widget.cameras[0],
      // ResolutionPreset.low,
      // ResolutionPreset.medium,
      // ResolutionPreset.high,
      ResolutionPreset.veryHigh,
      enableAudio: false,


    );
    controller.initialize().then((_){

      if (!mounted) {
        return;
      }
      setState(() {});
      startStream(controller);
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
          // Handle access errors here.
            break;
          default:
          // Handle other errors here.
            break;
        }
      }
    });
    // await startStream(controller);
  }

  @override
  void dispose() {
    controller.stopImageStream();
    controller.dispose();

    print('disposed');
    super.dispose();
  }

  //
  //
  //
  //
  //    var score =  euclideanDistance(realFloatingNumbers3, fakeFloatingNumbers2);
  //  print('the real euclidean score distance is $score');
  //
  //
  //   // var score =  euclideanDistance(realFloatingNumbers1, fakeFloatingNumbers1);
  //   // print('the fake euclidean score distance is $score');
  //
  //
  //   // for (var item in finalOutput) {
  //   //   for (var row in item[0]) { // Accessing the nested list representing the 32x32 grid
  //   //     for (var value in row) {
  //   //       print(value); // Accessing the single value within each nested list
  //   //     }
  //   //   }
  //   // }
  //
  //
  //
  //
  // }
  //
  // Float32List imageToByteListFloat32ForLiveness(int inputSize, img.Image image) {
  //   // Resize the image to match the inputSize
  //   img.Image resizedImage = img.copyResize(image, width: inputSize, height: inputSize);
  //
  //   var convertedBytes = Float32List(1 * inputSize * inputSize * 6);
  //   var buffer = Float32List.view(convertedBytes.buffer);
  //   int pixelIndex = 0;
  //
  //   for (var y = 0; y < inputSize; y++) {
  //     for (var x = 0; x < inputSize; x++) {
  //       var pixel = resizedImage.getPixel(x, y);
  //       buffer[pixelIndex++] = img.getRed(pixel) / 255; // Normalizing the values to [0, 1]
  //       buffer[pixelIndex++] = img.getGreen(pixel) / 255;
  //       buffer[pixelIndex++] = img.getBlue(pixel) / 255;
  //
  //     }
  //   }
  //   return buffer;
  // }


/////////// Using FaceAntiSpoofing.tflite ////////////////


  Future<void> livenessDetection(img.Image image, Interpreter livenessInterpreter) async {
    // Convert image to a byte list with Float32 values
    List input = imageToByteListFloat32ForLiveness(256, image);
    input = input.reshape([1, 256, 256, 3]);
    // print('the input length is ${input}');

    // Initialize an empty list for outputs
    List output0 = List.filled(1 * 8, null, growable: false).reshape([1, 8]); // Adjusted output shape
    List output1 = List.filled(1 * 8, null, growable: false).reshape([1, 8]);

    var outputs = {0: output0, 1: output1};
    // Run inference
    // livenessInterpreter.runForMultipleInputs([input], outputs);
    livenessInterpreter.runForMultipleInputs([input], outputs);
    // output = output.reshape([8]);
    print(outputs);


    // Convert output to a list for further processing if needed
    // var finalOutput = List.from(output);
    // print('The final output is $finalOutput');

    // Print or process final output
    // print('The liveness output is $finalOutput');
    // double sum = 0.0; // Initialize sum
    // for (var item in finalOutput) {
    //   for (var row in item[0]) { // Accessing the nested list representing the 32x32 grid
    //     for (var value in row) {
    //       sum += value; // Accumulate sum of values
    //       print(value); // Accessing the single value within each nested list
    //     }
    //   }
    // }
    //
    // double mean = sum / (finalOutput.length * 32 * 32); // Compute mean
    // print('Mean: $mean'); // Print mean










    // var score =  euclideanDistance(realFloatingNumbers1, fakeFloatingNumbers1);
    // print('the fake euclidean score distance is $score');


    // for (var item in finalOutput) {
    //   for (var row in item[0]) { // Accessing the nested list representing the 32x32 grid
    //     for (var value in row) {
    //       print(value); // Accessing the single value within each nested list
    //     }
    //   }
    // }




  }

  Float32List imageToByteListFloat32ForLiveness(int inputSize, img.Image image) {
    // Resize the image to match the inputSize
    img.Image resizedImage = img.copyResize(image, width: inputSize, height: inputSize);


    var convertedBytes = Float32List(1 * inputSize * inputSize * 3); // 3 channels for RGB
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        var pixel = resizedImage.getPixel(x, y);

        // buffer[pixelIndex++] = img.getRed(pixel) / 256.0; // Normalizing the values to [0, 1]
        // buffer[pixelIndex++] = img.getGreen(pixel) / 256.0;
        // buffer[pixelIndex++] = img.getBlue(pixel) / 256.0;


        buffer[pixelIndex++] = (img.getRed(pixel) - 255.5) / 255.5;
        buffer[pixelIndex++] = (img.getGreen(pixel) -255.5)/ 255.5;
        buffer[pixelIndex++] = (img.getBlue(pixel) -255.5) / 255.5;
      }
    }
    return buffer;
  }


  double euclideanDistance(List e1, List e2) {


    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }














  Future<void> startStream(CameraController controller) async {


    final detectController = ref.watch(faceDetectionProvider.notifier);
    final detectState = ref.watch(faceDetectionProvider);
    final recognizeController = ref.watch(recognizefaceProvider.notifier);


     //Image Streaming
    controller.startImageStream((image) async {

     //
     //  //For detecting faces
     // InputImage inputImage = convertCameraImageToInputImage(image, controller);
     //
     // //For recognizing faces
     // img.Image imgImage = convertCameraImageToImgImage(image, controller.description.lensDirection);

    // final faceDetected =  await detectController.detectFromLiveFeedForRecognition(inputImage, imgImage, widget.faceDetector);

     numberOfFrames++;
     if ( numberOfFrames % frameSkipCount == 0) {
       print('the number of frames are $numberOfFrames');


       DateTime start = DateTime.now();

       //For detecting faces
       InputImage inputImage = convertCameraImageToInputImage(image, controller);

       //For recognizing faces
       img.Image imgImage = convertCameraImageToImgImage(image, controller.description.lensDirection);
       print('the width of the image for recognising from live feed ios ${imgImage.width}');
       print('the height of the image for recognising from live feed ios ${imgImage.height}');

       final faceDetected =  await detectController.detectFromLiveFeedForRecognition([inputImage], [imgImage], widget.faceDetector);
       // final faceDetected =  await detectController.detectFromLiveFeedForRecognition(inputImage, imgImage, widget.faceDetector);


       if(faceDetected.isNotEmpty){
         // await livenessDetection(faceDetected[0], widget.livenessInterpreter);
         await recognizeController.pickImagesAndRecognize(faceDetected [0], widget.interpreter, widget.nameOfJsonFile);

       }
       DateTime end = DateTime.now();
       Duration timeTaken = end.difference(start);
       double milliSeconds = timeTaken.inMilliseconds.toDouble();

       print('Time taken: $milliSeconds milliseconds');



     }



    });
  }





  Widget build(BuildContext context) {
    final recognizeState = ref.watch(recognizefaceProvider);
    final detectState = ref.watch(faceDetectionProvider);




    if (recognizeState is SuccessState && detectState is SuccessState) {
      message = 'Recognized: ${recognizeState.name}';
    } else if (recognizeState is ErrorState  && detectState is SuccessState) {
      message = ' ${recognizeState.errorMessage}';
    }else if(detectState is ErrorState){

      message = detectState.errorMessage;
      // 'No face Detected';
    }
    else{
      message = 'No face Detected';
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(controller),
        Positioned(
          bottom: 16,
          left: 16,
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
      ],
    );
  }
}


//
// class FaceDetectorPainter extends CustomPainter {
//   FaceDetectorPainter(this.imageSize, this.results);
//   final Size imageSize;
//   late double scaleX, scaleY;
//   late dynamic results;
//   late Face face;
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3.0
//       ..color = Colors.blue;
//     for (String label in results.keys) {
//       for (Face face in results[label]) {
//         // face = results[label];
//         scaleX = size.width / imageSize.width;
//         scaleY = size.height / imageSize.height;
//         canvas.drawRRect(
//             _scaleRect(
//                 rect: face.boundingBox,
//                 imageSize: imageSize,
//                 widgetSize: size,
//                 scaleX: scaleX,
//                 scaleY: scaleY),
//             paint);
//         TextSpan span = TextSpan(
//             style: TextStyle(color: Colors.orange[300], fontSize: 15),
//             text: label);
//         TextPainter textPainter = TextPainter(
//             text: span,
//             textAlign: TextAlign.left,
//             textDirection: TextDirection.ltr);
//         textPainter.layout();
//         textPainter.paint(
//             canvas,
//             Offset(
//                 size.width - (60 + face.boundingBox.left.toDouble()) * scaleX,
//                 (face.boundingBox.top.toDouble() - 10) * scaleY));
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(FaceDetectorPainter oldDelegate) {
//     return oldDelegate.imageSize != imageSize || oldDelegate.results != results;
//   }
// }
//
// RRect _scaleRect(
//     {required Rect rect,
//       required Size imageSize,
//       required Size widgetSize,
//       double? scaleX,
//       double? scaleY}) {
//   return RRect.fromLTRBR(
//       (widgetSize.width - rect.left.toDouble() * scaleX!),
//       rect.top.toDouble() * scaleY!,
//       widgetSize.width - rect.right.toDouble() * scaleX,
//       rect.bottom.toDouble() * scaleY,
//       const Radius.circular(10));
// }
//










