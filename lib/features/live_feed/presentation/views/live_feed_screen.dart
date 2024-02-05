
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:face/core/base_state/base_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;

import '../../../../core/utils/convert_camera_image_to_img_image.dart';
import '../../../../core/utils/convert_camera_image_to_input_image.dart';
import '../../../face_detection/presentation/riverpod/face_detection_provider.dart';
import '../../../recognize_face/presentation/riverpod/recognize_face_provider.dart';

import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;






class LiveFeedScreen extends ConsumerStatefulWidget {

  LiveFeedScreen({Key? key, required this.detectionController, required this.faceDetector, required this.cameras, required this.interpreter}) : super(key: key);

  final FaceDetectionNotifier detectionController;
  final FaceDetector faceDetector;
  late List<CameraDescription> cameras;
  final tf_lite.Interpreter interpreter;

  @override
  ConsumerState<LiveFeedScreen> createState() => _LiveFeedScreenState();
}


// 2. extend [ConsumerState]
class _LiveFeedScreenState extends ConsumerState<LiveFeedScreen> {
  late CameraController controller;
  int numberOfFrames  = 0;
  int frameSkipCount = 25;
  List frameList = [];



  @override
  void initState() {
    super.initState();
    initializeCameras();
  }

  Future<void> initializeCameras() async {
    // cameras = await availableCameras();
    controller = CameraController(
      widget.cameras[1],
      ResolutionPreset.low,
      enableAudio: false,
      // imageFormatGroup: ImageFormatGroup.yuv420,
    );
    controller.initialize().then((_){
      // startStream(controller);
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


  Future<void> startStream(CameraController controller) async {

    final detectController = ref.watch(faceDetectionProvider.notifier);
    final recognizeController = ref.watch(recognizefaceProvider.notifier);
    final recognizeState = ref.watch(recognizefaceProvider);

     //Image Streaming
    controller.startImageStream((image) async {




     InputImage inputImage = convertCameraImageToInputImage(image, controller);

     img.Image imgImage = convertCameraImageToImgImage(image, controller.description.lensDirection);

    final faceDetected =  await detectController.detectFromLiveFeed(inputImage, imgImage, widget.faceDetector);

     numberOfFrames++;
     if (numberOfFrames % frameSkipCount == 0) {
       print('the number of frames are $numberOfFrames');

       await recognizeController.pickImagesAndRecognize(faceDetected [0], widget.interpreter);
       if(recognizeState is SuccessState){
         print(recognizeState.name);
       }
     }



    });
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        CameraPreview(controller),

      ],
    );
  }
}



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











