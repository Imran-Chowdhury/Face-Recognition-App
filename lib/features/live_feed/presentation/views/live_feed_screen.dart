




import 'dart:isolate';



import 'package:camera/camera.dart';
import 'package:face/core/base_state/base_state.dart';

import 'package:flutter/foundation.dart';
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



@pragma('vm:entry-point')
void convertedImage(List imageList)async{
  // List<CameraDescription> cameras = await availableCameras();
  // final direction = CameraController(cameras[1],
  //   // widget.cameras[0],
  //   // ResolutionPreset.low,
  //   // ResolutionPreset.medium,
  //   ResolutionPreset.high,
  //   // ResolutionPreset.veryHigh,
  //   enableAudio: false,
  // ).description.lensDirection;

  final img1 = convertCameraImageToImgImage(imageList[0] as CameraImage, CameraLensDirection.front);
  // return img1;
}



class LiveFeedScreen extends ConsumerStatefulWidget {

  LiveFeedScreen({Key? key,required this.isolateInterpreter, required this.detectionController, required this.faceDetector, required this.cameras, required this.interpreter, required this.livenessInterpreter, required this.nameOfJsonFile}) : super(key: key);

  final FaceDetectionNotifier detectionController;
  final FaceDetector faceDetector;
  late List<CameraDescription> cameras;
  final tf_lite.Interpreter interpreter;
  final tf_lite.IsolateInterpreter isolateInterpreter;

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
  // int frameSkipCount = 25;
  int frameSkipCount = 40;
  List frameList = [];
  String message = '';



  @override
  void initState() {
    super.initState();
    initializeCameras();
    print('Camera initialized');
  }

  Future<void> initializeCameras() async {

    controller = CameraController(
      widget.cameras[1],
      // widget.cameras[0],
      ResolutionPreset.low,
      // ResolutionPreset.medium,
      // ResolutionPreset.high,
      // ResolutionPreset.veryHigh,
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



/////////// Using FaceAntiSpoofing.tflite ////////////////


  Future<void> livenessDetection(img.Image image, Interpreter livenessInterpreter) async {
    // Convert image to a byte list with Float32 values


    // Quantization Params of output tensor at index 0
    QuantizationParams outputParams = livenessInterpreter.getOutputTensor(0).params;

    print('The input quantization param is $livenessInterpreter');
    print('The output quantization param is $outputParams');


    List input = imageToByteListFloat32ForLiveness(256, image);
    input = input.reshape([1, 256, 256, 3]);
    // print('the input length is ${input}');

    // Initialize an empty list for outputs
    List output0 = List.filled(1 * 8, null, growable: false).reshape([1, 8]); // Adjusted output shape
    List output1 = List.filled(1 * 8, null, growable: false).reshape([1, 8]);

    var outputs = {0: output0, 1: output1};
    // Run inference


    livenessInterpreter.runForMultipleInputs([input], outputs);
    // output = output.reshape([8]);

    print('Number of elements in the input tensor: ${input.length}');
    print('Number of elements in the output tensor: ${output0.length}');
    print('Shape of the input tensor: ${input.shape}');
    print('Shape of the output tensor: ${output0.shape}');






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


        buffer[pixelIndex++] = (img.getRed(pixel) - 127.5) / 127.5;
        buffer[pixelIndex++] = (img.getGreen(pixel) -127.5)/ 127.5;
        buffer[pixelIndex++] = (img.getBlue(pixel) -127.5) / 127.5;
      }
    }
    return convertedBytes.buffer.asFloat32List();
    // return buffer;
  }















  Future<void> startStream(CameraController controller) async {


    final detectController = ref.watch(faceDetectionProvider.notifier);
    // final detectState = ref.watch(faceDetectionProvider);
    final recognizeController = ref.watch(recognizefaceProvider.notifier);






     //Image Streaming
    controller.startImageStream((image) async {


      // print('The camera image format is ${image.format.group}');



     numberOfFrames++;
     if ( numberOfFrames % frameSkipCount == 0) {
       print('the number of frames are $numberOfFrames');


       // DateTime start = DateTime.now();
       final stopwatch = Stopwatch()..start();
       //For detecting faces
      final  InputImage inputImage = convertCameraImageToInputImage(image, controller);




       //For recognizing faces
      final  img.Image imgImage = convertCameraImageToImgImage(image, controller.description.lensDirection);
       print('the width of the image for recognising from live feed ios ${imgImage.width}');
       print('the height of the image for recognising from live feed ios ${imgImage.height}');
       // stopwatch.stop();
       // final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
       // print('Image conversion time: $elapsedSeconds seconds');


     // await createIsolate(image,);
     //   await flutterCompute(convertedImage, [image]);










       final faceDetected =  await detectController.detectFromLiveFeedForRecognition([inputImage], [imgImage], widget.faceDetector);



       if(faceDetected.isNotEmpty){
         print('Face Detected');
         // await livenessDetection(faceDetected[0], widget.livenessInterpreter);

         await recognizeController.pickImagesAndRecognize(faceDetected [0], widget.interpreter,widget.isolateInterpreter,  widget.nameOfJsonFile);

       }


       stopwatch.stop();
       final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
       print('Detection and Recognition from live feed Execution Time: $elapsedSeconds seconds');

       // print('Time taken: $milliSeconds milliseconds');



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
    } else if(detectState is ErrorState){

      message = detectState.errorMessage;
      // 'No face Detected';
    }

    // }else if(detectState is ErrorState){
    //
    //   message = detectState.errorMessage;
    //   // 'No face Detected';
    // }
    // else{
    //   message = 'No face detected';
    // }

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









