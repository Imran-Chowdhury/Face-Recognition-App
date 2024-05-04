





import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:face/features/train_face/presentation/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'package:tflite_flutter/tflite_flutter.dart' as TfLiteModel;
import 'package:tflite_flutter/tflite_flutter.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that Flutter is initialized

  // Load the model before running the app
  final interpreter = await loadModel();
  final isolateInterpreter =
  await IsolateInterpreter.create(address: interpreter.address);
  final livenessInterpreter = await loadLivenessModel();

  List<CameraDescription> cameras = await availableCameras();

  runApp(
    ProviderScope(
      child: MyApp(interpreter: interpreter,isolateInterpreter:isolateInterpreter,livenessInterpreter: livenessInterpreter, cameras: cameras,),
    ),
  );
}

Future<TfLiteModel.Interpreter> loadModel() async {

  InterpreterOptions interpreterOptions = InterpreterOptions();
 // final processorNum =  Platform.numberOfProcessors;
 // print('The number of processors are $processorNum');


  if (Platform.isAndroid) {
    interpreterOptions.addDelegate(XNNPackDelegate());
  }

  if (Platform.isIOS) {
    interpreterOptions.addDelegate(GpuDelegate());
  }
  //  GpuDelegateOptionsV2 gpuDelegateOptionsV2 = GpuDelegateOptionsV2({
  //
  //
  //   bool isPrecisionLossAllowed = false,
  //   int inferencePreference = TfLiteGpuInferenceUsage.TFLITE_GPU_INFERENCE_PREFERENCE_FAST_SINGLE_ANSWER,
  //   int inferencePriority1 = TfLiteGpuInferencePriority.TFLITE_GPU_INFERENCE_PRIORITY_MAX_PRECISION,
  //   int inferencePriority2 = TfLiteGpuInferencePriority.TFLITE_GPU_INFERENCE_PRIORITY_AUTO,
  //   int inferencePriority3 = TfLiteGpuInferencePriority.TFLITE_GPU_INFERENCE_PRIORITY_AUTO,
  //   List<int> experimentalFlags = const [TfLiteGpuExperimentalFlags.TFLITE_GPU_EXPERIMENTAL_FLAGS_ENABLE_QUANT],
  //   int maxDelegatePartitions = 1,
  //
  // });


  // return await TfLiteModel.Interpreter.fromAsset('assets/facenet.tflite');
  // return await TfLiteModel.Interpreter.fromAsset('assets/mobile_face_net.tflite');
  // return await TfLiteModel.Interpreter.fromAsset('assets/FaceMobileNet_Float32.tflite');
  return await TfLiteModel.Interpreter.fromAsset('assets/facenet_512.tflite',
    // options: interpreterOptions..threads = 4,
  );
  // return await TfLiteModel.Interpreter.fromAsset('assets/facenet(face_recognizer_android_repo).tflite');
  // facenet(face_recognizer_android_repo).tflite
}

Future<TfLiteModel.Interpreter> loadLivenessModel() async {
  // return await TfLiteModel.Interpreter.fromAsset('assets/FaceDeSpoofing.tflite');
  return await TfLiteModel.Interpreter.fromAsset('assets/FaceAntiSpoofing.tflite');


}

class MyApp extends StatefulWidget {
  final TfLiteModel.Interpreter interpreter;
  final TfLiteModel.Interpreter livenessInterpreter;
  final TfLiteModel.IsolateInterpreter isolateInterpreter;
  List<CameraDescription> cameras;

   MyApp({super.key, required this.interpreter,required this.livenessInterpreter, required this.isolateInterpreter, required this.cameras});

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
    final inputType = widget.interpreter.getInputTensor(0).type;
    final outputType = widget.interpreter.getOutputTensor(0).type;


    print('Input type: $inputType');
    print('Output type: $outputType');


    print('THE LIVENESS DETECTOR NEEDS:');
    // print(widget.livenessInterpreter.getInputIndex('input'));
    // print(widget.livenessInterpreter.getInputTensor(0));
    // print(widget.livenessInterpreter.getInputTensor(widget.livenessInterpreter.getInputIndex('input')));
    print(widget.livenessInterpreter.getInputTensors());
    print(widget.livenessInterpreter.getOutputTensors());


    final faceDetectorOptions = FaceDetectorOptions(

      minFaceSize: 0.2,


      performanceMode: FaceDetectorMode.accurate, // or .fast
      // performanceMode: FaceDetectorMode.fast, // or .accurate

    );


    faceDetector = FaceDetector(options: faceDetectorOptions);
  }

  @override
  void dispose() {
    faceDetector.close();
    widget.interpreter.close();
    super.dispose();
  }

// background colour  hex #3a3b45
  //button hex  #0cdec1 and #0ad8e6

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3a3b45)),
        useMaterial3: true,
      ),
      // Your app's configuration...
      home: SafeArea(child: HomeScreen(interpreter: widget.interpreter, isolateInterpreter: widget.isolateInterpreter,livenessInterpreter: widget.livenessInterpreter ,faceDetector: faceDetector,cameras:widget.cameras ,)),
    );
  }
}







