


import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';






class CameraBurstCaptureScreen extends ConsumerStatefulWidget {

  CameraBurstCaptureScreen({Key? key,  required this.cameras,}) : super(key: key);
  late List<CameraDescription> cameras;
  @override
  // _CameraCaptureScreenState createState() => _CameraCaptureScreenState();
  ConsumerState<CameraBurstCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends ConsumerState<CameraBurstCaptureScreen> {
  late CameraController controller;
  late List<CameraDescription> _cameras;
  late List<XFile> capturedImages = [];
  late List<CameraImage> cameraImages = [];
  int counter = 0;

  @override
  void initState() {
    super.initState();

    setupCamera();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> setupCamera() async {

    controller = CameraController(widget.cameras[1], ResolutionPreset.max);
    await controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }




  Future<void> captureImage() async {

  await controller.startImageStream((image) async{




    counter++;
         if(counter%15==0){
           cameraImages.add(image);
         }


       //for 40 images
      if(cameraImages.length>39){
        print('The length of captured image is ${cameraImages.length}');
        controller.stopImageStream();

        Navigator.pop(context, {'images':cameraImages, 'camController': controller});
      }



    });
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

              child: const Text('Capture Images'),
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