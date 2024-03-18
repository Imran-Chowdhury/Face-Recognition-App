


import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../../../../core/utils/convert_camera_image_to_img_image.dart';
import '../../../../core/utils/convert_camera_image_to_input_image.dart';





class CameraCaptureScreen extends ConsumerStatefulWidget {

  CameraCaptureScreen({Key? key,  required this.cameras,}) : super(key: key);
  late List<CameraDescription> cameras;
  @override
  // _CameraCaptureScreenState createState() => _CameraCaptureScreenState();
  ConsumerState<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends ConsumerState<CameraCaptureScreen> {
  late CameraController controller;
  late List<CameraDescription> _cameras;
 late List<XFile> capturedImages = [];
  late List<CameraImage> cameraImages = [];

  @override
  void initState() {
    super.initState();

    setupCamera();
  }

  Future<void> setupCamera() async {

    controller = CameraController(widget.cameras[1], ResolutionPreset.max);
    await controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> captureImage() async {

    try {
      // Directory appDocDir = await getApplicationDocumentsDirectory();
      // File file = File('${appDocDir.path}/saved_image.png');

      final XFile capturedImage = await controller.takePicture();



      // File fileImage = File(capturedImage.path);
      // img.Image decodedImg = img.decodeImage(fileImage.readAsBytesSync())!;
      // img.Image resizedImage = img.copyResize(decodedImg,width: 720,height: 1280);
      // List<int> pngBytes = img.encodePng(resizedImage);
      // await file.writeAsBytes(pngBytes);

      // print('The width of the captured image is ${decodedImg.width}');
      // print('The height of the captured image is ${decodedImg.height}');




      setState(() {
        capturedImages.add(capturedImage);
      });
      // if (capturedImages.length == 5) {
      if (capturedImages.length == 10) {
        // If 5 images are captured, navigate back to the home screen
        Navigator.pop(context, capturedImages);
      }
    } catch (e) {
      print('Error capturing image: $e');
    }
  }




  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Camera Capture'),
        ),
        body: Column(
          children: [
            Expanded(
              child: CameraPreview(controller),
            ),
           const SizedBox(height: 20),
            ElevatedButton(
              onPressed: captureImage,
              // child: Text('Capture Image (${capturedImages.length}/5)'),
              child: Text('Capture Image (${capturedImages.length}/10)'),
            ),
          ],
        ),
      );
    } else {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}