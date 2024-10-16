



import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';






class CameraCaptureScreen extends ConsumerStatefulWidget {

  CameraCaptureScreen({Key? key,  required this.cameras,}) : super(key: key);
  late List<CameraDescription> cameras;
  @override

  ConsumerState<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends ConsumerState<CameraCaptureScreen> {
  late CameraController controller;
  // late List<CameraDescription> _cameras;
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


      final XFile capturedImage = await controller.takePicture();








      setState(() {
        capturedImages.add(capturedImage);
      });
      // if (capturedImages.length == 5) {
      // if (capturedImages.length == 10) {
      //   // If 5 images are captured, navigate back to the home screen
      //   Navigator.pop(context, capturedImages);
      // }
      Navigator.pop(context, capturedImages);
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
              child: Text('Capture Image (${capturedImages.length}/1)'),
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