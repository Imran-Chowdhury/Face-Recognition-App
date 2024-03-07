





import 'dart:async';
import 'package:camera/camera.dart';
import 'package:face/features/train_face/presentation/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'package:tflite_flutter/tflite_flutter.dart' as TfLiteModel;



void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that Flutter is initialized

  // Load the model before running the app
  final interpreter = await loadModel();
  final livenessInterpreter = await loadLivenessModel();

  List<CameraDescription> cameras = await availableCameras();

  runApp(
    ProviderScope(
      child: MyApp(interpreter: interpreter,livenessInterpreter: livenessInterpreter, cameras: cameras,),
    ),
  );
}

Future<TfLiteModel.Interpreter> loadModel() async {
  return await TfLiteModel.Interpreter.fromAsset('assets/mobilefacenet.tflite');
  // return await TfLiteModel.Interpreter.fromAsset('assets/mobile_face_net.tflite');
  // mobile_face_net.tflite
}

Future<TfLiteModel.Interpreter> loadLivenessModel() async {
  // return await TfLiteModel.Interpreter.fromAsset('assets/FaceDeSpoofing.tflite');
  return await TfLiteModel.Interpreter.fromAsset('assets/FaceAntiSpoofing.tflite');


}

class MyApp extends StatefulWidget {
  final TfLiteModel.Interpreter interpreter;
  final TfLiteModel.Interpreter livenessInterpreter;
  List<CameraDescription> cameras;

   MyApp({super.key, required this.interpreter,required this.livenessInterpreter, required this.cameras});

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {

  late FaceDetector faceDetector;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print('THE FACENET MODEL NEEDS:');
    print(widget.interpreter.getInputTensors());
    print(widget.interpreter.getOutputTensors());


    print('THE LIVENESS DETECTOR NEEDS:');
    print(widget.livenessInterpreter.getInputTensors());
    print(widget.livenessInterpreter.getOutputTensors());


    final faceDetectorOptions = FaceDetectorOptions(
      // enableTracking: true,
      minFaceSize: 0.2,
      performanceMode: FaceDetectorMode.accurate, // or .fast
    );


    faceDetector = FaceDetector(options: faceDetectorOptions);
  }

  @override
  void dispose() {
    faceDetector.close();
    widget.interpreter.close();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Your app's configuration...
      home: HomeScreen(interpreter: widget.interpreter, livenessInterpreter: widget.livenessInterpreter ,faceDetector: faceDetector,cameras:widget.cameras ,),
    );
  }
}







