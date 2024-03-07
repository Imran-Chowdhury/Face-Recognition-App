
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
  // Future<void> livenessDetection(img.Image image, Interpreter livenessInterpreter) async {
  //   // Convert image to a byte list with Float32 values
  //   List input = imageToByteListFloat32ForLiveness(256, image);
  //   input = input.reshape([1, 256, 256, 6]);
  //
  //   // Initialize an empty list for outputs
  //   List output = List.filled(1 * 32 * 32 * 1, null, growable: false).reshape([1, 32, 32, 1]); // Adjusted output shape
  //
  //   // Run inference
  //   livenessInterpreter.run(input, output);
  //   output = output.reshape([1, 32, 32, 1]);
  //
  //   // Convert output to a list for further processing if needed
  //   var finalOutput = List.from(output);
  //
  //   // Print or process final output
  //   // print('The liveness output is $finalOutput');
  //   // double sum = 0.0; // Initialize sum
  //   // for (var item in finalOutput) {
  //   //   for (var row in item[0]) { // Accessing the nested list representing the 32x32 grid
  //   //     for (var value in row) {
  //   //       sum += value; // Accumulate sum of values
  //   //       print(value); // Accessing the single value within each nested list
  //   //     }
  //   //   }
  //   // }
  //   //
  //   // double mean = sum / (finalOutput.length * 32 * 32); // Compute mean
  //   // print('Mean: $mean'); // Print mean
  //
  //   List<double> realFloatingNumbers1 = [
  //     0.8364946842193604,
  //     0.9950121641159058,
  //     0.9833574295043945,
  //     0.9913017749786377,
  //     0.9757819175720215,
  //     0.9709447622299194,
  //     0.9888770580291748,
  //     1.004549264907837,
  //     1.011019229888916,
  //     1.0131237506866455,
  //     0.9968426823616028,
  //     1.003918170928955,
  //     0.9905408620834351,
  //     0.9784078001976013,
  //     0.9676072001457214,
  //     0.9684531688690186,
  //     0.985454797744751,
  //     0.9765955209732056,
  //     0.9905943274497986,
  //     0.9782648682594299,
  //     0.9835549592971802,
  //     0.9764506816864014,
  //     0.993013322353363,
  //     1.0099691152572632,
  //     1.0078537464141846,
  //     1.008267879486084,
  //     0.9820156097412109,
  //     0.9860879778862,
  //     0.9741199016571045,
  //     0.9541129469871521,
  //     0.8615359663963318,
  //     0.7334750890731812,
  //   ];
  //
  //
  //   List<double> realFloatingNumbers2 = [
  //     0.8213189244270325,
  //     0.9866055846214294,
  //     0.9721662402153015,
  //     1.003218412399292,
  //     1.001542568206787,
  //     1.0019047260284424,
  //     1.016228199005127,
  //     1.0169167518615723,
  //     1.0202372074127197,
  //     1.0053520202636719,
  //     0.9907532334327698,
  //     0.9825235605239868,
  //     0.9608615040779114,
  //     0.9514442682266235,
  //     0.9479791522026062,
  //     0.9625592827796936,
  //     0.9637981653213501,
  //     0.9733883738517761,
  //     0.9695136547088623,
  //     0.9740919470787048,
  //     0.9968187808990479,
  //     0.9994555711746216,
  //     1.0189208984375,
  //     1.0306073427200317,
  //     1.022058129310608,
  //     1.0051683187484741,
  //     0.97980797290802,
  //     0.9729629158973694,
  //     0.9420199990272522,
  //     0.9204161763191223,
  //     0.8269293308258057,
  //     0.696033239364624,
  //   ];
  //
  //   List<double> realFloatingNumbers3 = [
  //     0.8324052691459656,
  //     1.000307321548462,
  //     0.9971771240234375,
  //     1.0370618104934692,
  //     1.022201418876648,
  //     1.027098298072815,
  //     1.033239722251892,
  //     1.02018141746521,
  //     1.0297235250473022,
  //     1.0213451385498047,
  //     1.009474515914917,
  //     0.9972934126853943,
  //     0.9881449937820435,
  //     0.9884228110313416,
  //     0.9886943697929382,
  //     0.9897547364234924,
  //     1.0016798973083496,
  //     1.0196913480758667,
  //     1.016508936882019,
  //     1.0239956378936768,
  //     1.0205037593841553,
  //     1.0227644443511963,
  //     1.024243712425232,
  //     1.015271544456482,
  //     1.0264250040054321,
  //     1.0139473676681519,
  //     1.0047104358673096,
  //     1.0000934600830078,
  //     0.9785221219062805,
  //     0.9523835182189941,
  //     0.8547003865242004,
  //     0.7257161736488342,
  //   ];
  //
  //   List<double> realFloatingNumbers4 = [
  //     0.8298551440238953,
  //     0.9754037857055664,
  //     0.9924368262290955,
  //     1.0215377807617188,
  //     1.0039488077163696,
  //     1.0144157409667969,
  //     1.0190976858139038,
  //     1.0130817890167236,
  //     1.0172663927078247,
  //     1.0193915367126465,
  //     1.0050358772277832,
  //     1.0057406425476074,
  //     0.9994701147079468,
  //     0.9982895851135254,
  //     0.9863775968551636,
  //     0.9783665537834167,
  //     0.9853695631027222,
  //     1.0032564401626587,
  //     1.0051571130752563,
  //     1.0082467794418335,
  //     1.0042593479156494,
  //     1.0281625986099243,
  //     1.0322710275650024,
  //     1.0162023305892944,
  //     1.0146924257278442,
  //     1.020379662513733,
  //     1.0116498470306396,
  //     1.0089493989944458,
  //     0.9886182546615601,
  //     0.9574705958366394,
  //     0.8554062247276306,
  //     0.7216940522193909,
  //   ];
  //
  //
  //
  //   List<double> fakeFloatingNumbers1 = [
  //     0.8327109813690186,
  //     0.9434898495674133,
  //     0.9780601859092712,
  //     1.0057774782180786,
  //     1.0026013851165771,
  //     1.0077190399169922,
  //     1.004275918006897,
  //     0.9940490126609802,
  //     0.9872788190841675,
  //     0.9921378493309021,
  //     1.001494288444519,
  //     0.9964501857757568,
  //     0.9897323846817017,
  //     0.9848468899726868,
  //     0.9799239039421082,
  //     0.9803444147109985,
  //     0.9792712330818176,
  //     0.9813993573188782,
  //     0.9828583002090454,
  //     0.9904141426086426,
  //     0.9961951375007629,
  //     0.999580979347229,
  //     1.0012248754501343,
  //     0.99128657579422,
  //     0.9860723614692688,
  //     0.9831362366676331,
  //     0.980658233165741,
  //     0.9770996570587158,
  //     0.9642221331596375,
  //     0.9391499757766724,
  //     0.8622456192970276,
  //     0.7293643951416016,
  //   ];
  //   List<double> fakeFloatingNumbers2 = [
  //     0.8150590062141418,
  //     0.9419770836830139,
  //     0.970895528793335,
  //     0.9991909265518188,
  //     1.0009105205535889,
  //     0.9958356022834778,
  //     0.9992169737815857,
  //     1.0080071687698364,
  //     1.0040708780288696,
  //     0.9922041893005371,
  //     0.9866783618927002,
  //     0.9838973879814148,
  //     0.9893638491630554,
  //     0.9848211407661438,
  //     0.9814603924751282,
  //     0.999315083026886,
  //     0.989160418510437,
  //     0.9926458597183228,
  //     0.9915799498558044,
  //     0.980720579624176,
  //     0.9973613619804382,
  //     0.9907235503196716,
  //     0.9999688267707825,
  //     1.0141628980636597,
  //     1.0033575296401978,
  //     0.9932150840759277,
  //     0.9811590909957886,
  //     0.9919142723083496,
  //     0.973204493522644,
  //     0.9378347992897034,
  //     0.8493999242782593,
  //     0.710087239742279,
  //   ];
  //
  //   List<double> fakeFloatingNumbers3 = [
  //     0.8414655327796936,
  //     0.9388964772224426,
  //     0.966916561126709,
  //     0.9978177547454834,
  //     0.987680196762085,
  //     0.9907951354980469,
  //     0.9950687289237976,
  //     1.0015363693237305,
  //     1.0002561807632446,
  //     0.9944164752960205,
  //     0.9866164922714233,
  //     0.9911314249038696,
  //     0.9918162822723389,
  //     0.9879651069641113,
  //     0.9738106727600098,
  //     0.9967805743217468,
  //     0.9972992539405823,
  //     0.9973859786987305,
  //     0.9961745142936707,
  //     0.9832642674446106,
  //     0.9935707449913025,
  //     0.9958022236824036,
  //     0.9973722696304321,
  //     1.007232427597046,
  //     0.998944103717804,
  //     0.989325761795044,
  //     0.9737231135368347,
  //     0.9876551032066345,
  //     0.9696135520935059,
  //     0.9406945109367371,
  //     0.8527743220329285,
  //     0.718484103679657,
  //   ];
  //
  //   List<double> fakeFloatingNumbers4 = [
  //     0.8250874280929565,
  //     0.9482201337814331,
  //     0.9649606943130493,
  //     1.0053596496582031,
  //     1.0053719282150269,
  //     1.0116485357284546,
  //     1.0084962844848633,
  //     1.0032931566238403,
  //     0.9922356009483337,
  //     0.9924300312995911,
  //     0.9934720396995544,
  //     0.9928587675094604,
  //     0.9916014075279236,
  //     0.9765114784240723,
  //     0.9722974896430969,
  //     0.9896996021270752,
  //     0.9924007058143616,
  //     0.9933357238769531,
  //     0.9883813261985779,
  //     0.9850362539291382,
  //     0.9963749647140503,
  //     1.0013362169265747,
  //     1.0025697946548462,
  //     0.9969310760498047,
  //     0.9897264838218689,
  //     0.9854634404182434,
  //     0.9771246910095215,
  //     0.981407880783081,
  //     0.9682193994522095,
  //     0.9378497004508972,
  //     0.8519571423530579,
  //     0.7154380083084106,
  //   ];
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

       final faceDetected =  await detectController.detectFromLiveFeedForRecognition(inputImage, imgImage, widget.faceDetector);


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










