


import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:face/core/base_state/base_state.dart';
import 'package:face/features/live_feed/presentation/views/live_feed_screen.dart';
import 'package:image/image.dart' as img;
import 'package:face/features/face_detection/presentation/riverpod/face_detection_provider.dart';
import 'package:face/features/recognize_face/presentation/riverpod/recognize_face_provider.dart';
import 'package:face/features/train_face/presentation/riverpod/train_face_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../../core/utils/image_to_float32.dart';
import '../../../live_feed/presentation/views/live_feed_training_screen.dart';

class HomeScreen extends ConsumerWidget{

  HomeScreen({required this.interpreter,required this.livenessInterpreter, required this.faceDetector, required this.cameras});
  final tf_lite.Interpreter interpreter;
  final tf_lite.Interpreter livenessInterpreter;
  final FaceDetector faceDetector;
  List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late String personName;
    final _formKey = GlobalKey<FormState>();
    final detectController = ref.watch(faceDetectionProvider.notifier);
    final detectState = ref.watch(faceDetectionProvider);
    final trainController = ref.watch(trainFaceProvider.notifier);
    final trainState = ref.watch(trainFaceProvider);
    final recognizeController = ref.watch(recognizefaceProvider.notifier);
    final recognizeState = ref.watch(recognizefaceProvider);
    final TextEditingController textFieldController = TextEditingController();

//for deleting and printing name
//     String fileName = 'galleryData';
//     String fileName = 'galleryData2(th = 0.62)';
    String fileName = 'liveTraining(Th = 0.58, mean = std = 127.5)';
    // String fileName = 'testMap';
    // String fileName = 'liveGallery-live';




    Uint8List convertImageToUint8List(img.Image image) {
      // Encode the image to PNG format
      final List<int> pngBytes = img.encodePng(image);

      // Convert the List<int> to Uint8List
      final Uint8List uint8List = Uint8List.fromList(pngBytes);

      return uint8List;
    }

    print('the length of the camera is ${cameras.length}');


    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Recognition'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
                'File being used is $fileName',
              style: const TextStyle(fontSize: 15.0),
            ),
          ),

          const SizedBox(height: 10.0,),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter Name',
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0), // Adjust border radius
                      borderSide: const BorderSide(width: 2.0), // Adjust border thickness
                    ),
                  ),
                  onChanged: (value) {
                     personName = value;

                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please fill in this field';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: ()async {
                    if (_formKey.currentState!.validate()) {


                      //detect face and train the mobilefacenet model
                     await detectController.detectFacesFromImages(faceDetector, 'Train from gallery').then((imgList)async{


                       final stopwatch = Stopwatch()..start();

                         await trainController.pickImagesAndTrain(personName,interpreter,imgList,fileName);
                         personName = '';

                       stopwatch.stop();
                       final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
                       print('Detection and Training Execution Time: $elapsedSeconds seconds');

                     });

                    } else {
                      // Validation failed
                      print('Validation failed');
                    }
                  },


                  child: const Text('Pick and Train Images'),
                ),
                const SizedBox(height: 30.0,),

                ElevatedButton(
                  onPressed: ()async {
                    if (_formKey.currentState!.validate()) {



                      final List<XFile>? capturedImages = await  Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CameraCaptureScreen(cameras: cameras,)),
                      );

                      if (capturedImages != null) {
                        await detectController.detectFacesFromImages(faceDetector, 'Train from captures', capturedImages).then((imgList)async{


                          final stopwatch = Stopwatch()..start();

                          await trainController.pickImagesAndTrain(personName,interpreter,imgList, fileName);

                          // personName = '';



                          stopwatch.stop();
                          final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
                          print('Detection and Training Execution Time: $elapsedSeconds seconds');

                        });
                      }

                    } else {
                      // Validation failed
                      print('Validation failed');
                    }
                  },


                  child: const Text('Capture and train image from live feed'),
                ),
                const SizedBox(height: 30.0,),
                ElevatedButton(
                  onPressed: ()async{
                    //detect and recognize face
                   await detectController.detectFacesFromImages(faceDetector, 'Recognize from gallery').then((value) async{

                    // await livenessDetection(value[0], livenessInterpreter);


                     // final stopwatch = Stopwatch()..start();
                     //
                     // await recognizeController. pickImagesAndRecognize(value[0], interpreter);
                     //
                     // stopwatch.stop();
                     // final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
                     // print('Detection and Recognition Execution Time: $elapsedSeconds seconds');


                     //For collection of data for FAR and FRR
                     for(var i = 0; i<value.length;i++){
                       final stopwatch = Stopwatch()..start();

                       await recognizeController. pickImagesAndRecognize(value[i], interpreter, fileName);

                       stopwatch.stop();
                       final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
                       print('Detection and Recognition Execution Time: $elapsedSeconds seconds');
                     }

                    });




                  },
                  child: const Text('Recognize Image'),
                ),
                const SizedBox(height: 30.0,),


                ElevatedButton(



                  //Deletes a person from the mentioned file
                  // onPressed: (){
                  //
                  //   if (_formKey.currentState!.validate()) {
                  //     deleteNameFromSharedPreferences(personName,fileName);
                  //   }
                  //
                  //
                  // },

                  // Deletes the mentioned file
                  // onPressed: (){
                  //  deleteJsonFromSharedPreferences(fileName);
                  // },


                  // onPressed: (){
                  //     deleteNameFromSharedPreferences('Laboni',fileName);
                  //
                  // },


                  onPressed: (){},
                  child: const Text(' delete trainings'),
                ),

                const SizedBox(height: 30.0,),

                ElevatedButton(
                  onPressed: (){
                    getKeysFromTestMap(fileName);
                  },
                  child: const Text(' Print the Keys'),
                ),
                const SizedBox(height: 30.0,),



                ElevatedButton(
                  onPressed: ()async{
                    // List<CameraDescription> cameras;
                    List<CameraDescription>  cameras = await availableCameras();
                    // CameraController controller = CameraController(
                    //     cameras[1],
                    //     ResolutionPreset.medium,
                    //     enableAudio: false,
                    //     imageFormatGroup: ImageFormatGroup.yuv420
                    // );
                    Navigator.push(
                      context,
                      // MaterialPageRoute(builder: (context) => LiveFeedScreen()),
                      MaterialPageRoute(builder: (context) => LiveFeedScreen(
                        detectionController: detectController,faceDetector: faceDetector,
                        cameras: cameras,interpreter: interpreter,
                      livenessInterpreter: livenessInterpreter,nameOfJsonFile: fileName,)),
                    );
                  },
                  child: const Text(' Live Feed Recognition'),
                ),
                const SizedBox(height: 30.0,),




              ],
            ),
          ),
          if(detectState is SuccessState)

            Flexible(
              child: ListView.builder(

                itemCount: detectState.data?.length ?? 0,
                itemBuilder: (context, index) {
                  final img.Image image = detectState.data[index];
                  final Uint8List uint8List = convertImageToUint8List(image);


                  return
                    Container(
                      margin: const EdgeInsets.all(8.0),
                      child: Image.memory(
                        uint8List,
                        width: 112.0,
                        height: 112.0,
                        // fit: BoxFit.cover,
                      ),
                    );
                },
              ),
            ),

          const SizedBox(height: 10.0,),

          if(recognizeState is SuccessState)
            Center(child: Text(recognizeState.name,
            style: const  TextStyle(fontWeight: FontWeight.bold),)),


        ],
      ),
    );
  }




  Future<void> deleteJsonFromSharedPreferences(String nameOfJsonFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the key exists
    bool keyExists = prefs.containsKey(nameOfJsonFile);

    if (keyExists) {
      // Delete the key (file) from SharedPreferences
      prefs.remove(nameOfJsonFile);
      print('deleted $nameOfJsonFile');
    } else {
      print('$nameOfJsonFile does not exist in SharedPreferences.');
    }
  }


  Future<void> getKeysFromTestMap(String nameOfJsonFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the JSON string from SharedPreferences
    // String? jsonTestMap = prefs.getString('testMap');
    // String? jsonTestMap = prefs.getString('liveTraining');
    String? jsonTestMap = prefs.getString(nameOfJsonFile);


    if (jsonTestMap != null) {
      // Parse the JSON string into a Map
      Map<String, dynamic> testMap = jsonDecode(jsonTestMap);

      // Get the keys from the Map
      List<String> keys = testMap.keys.toList();

      keys.forEach((key) {
        // Access the corresponding value for each key
        dynamic value = testMap[key];

        print('$key: $value');
      });

    } else {

      print('$nameOfJsonFile is empty or not found in SharedPreferences.');
      // print('testMap is empty or not found in SharedPreferences.');
    }
  }


  Future<void> deleteNameFromSharedPreferences(String name, String nameOfJsonFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the JSON string from SharedPreferences
    // String? jsonString = prefs.getString('testMap');
    // String? jsonString = prefs.getString('liveTraining');
    String? jsonString = prefs.getString(nameOfJsonFile);
    if (jsonString != null) {
      // Parse the JSON string into a Map
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      // Remove the desired key from the Map
      // jsonMap.remove('Imran');
      jsonMap.remove(name);

      // Serialize the Map back into a JSON string
      String updatedJsonString = json.encode(jsonMap);

      // Save the updated JSON string back into SharedPreferences
      // prefs.setString('testMap', updatedJsonString);
      // prefs.setString('liveTraining', updatedJsonString);
      prefs.setString(nameOfJsonFile, updatedJsonString);

      print('Deleted $name from $nameOfJsonFile');
    } else {
      print('Name does not exist in $nameOfJsonFile');
    }
  }



  Future<void> livenessDetection(img.Image image, Interpreter livenessInterpreter) async {
    // Convert image to a byte list with Float32 values
    List input = imageToByteListFloat32ForLiveness(256, image);
    input = input.reshape([1, 256, 256, 6]);

    // Initialize an empty list for outputs
    List output = List.filled(1 * 32 * 32 * 1, null, growable: false).reshape([1, 32, 32, 1]); // Adjusted output shape

    // Run inference
    livenessInterpreter.run(input, output);
    output = output.reshape([1, 32, 32, 1]);

    // Convert output to a list for further processing if needed
    var finalOutput = List.from(output);

    // Print or process final output
    print('The liveness output is $finalOutput');
  }

  Float32List imageToByteListFloat32ForLiveness(int inputSize, img.Image image) {
    // Resize the image to match the inputSize
    img.Image resizedImage = img.copyResize(image, width: inputSize, height: inputSize);

    var convertedBytes = Float32List(1 * inputSize * inputSize * 6);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        var pixel = resizedImage.getPixel(x, y);
        buffer[pixelIndex++] = img.getRed(pixel) / 255; // Normalizing the values to [0, 1]
        buffer[pixelIndex++] = img.getGreen(pixel) / 255;
        buffer[pixelIndex++] = img.getBlue(pixel) / 255;

      }
    }
    return buffer;
  }

  // Future<void> livenessDetection(img.Image image, Interpreter livenessInterpreter) async {
  //   // Convert image to a byte list with Float32 values
  //   List input =  imageToByteListFloat32ForLiveness(256, 256, 6, image); // Adjusted input shape
  //   input = input.reshape([1, 256, 256, 6]);
  //
  //   // Initialize an empty list for outputs
  //   List output = List.filled(1 * 32 * 32 * 1, null, growable: false).reshape([1, 32, 32, 1]); // Adjusted output shape
  //
  //   // Run inference
  //   interpreter.run(input, output);
  //
  //   // Reshape output to match the required shape
  //   output = output.reshape([1, 32, 32, 1]);
  //
  //   // Convert output to a list for further processing if needed
  //   var finalOutput = List.from(output);
  //
  //   // Print or process final output
  //   print('The liveness output is $finalOutput');
  // }
  //
  // Float32List imageToByteListFloat32ForLiveness(
  //     int inputSize, double mean, double std, img.Image image) {
  //   // ... Your existing image processing logic remains unchanged ...
  //
  //   var convertedBytes = Float32List(1 * inputSize * inputSize * 6);
  //   var buffer = Float32List.view(convertedBytes.buffer);
  //   int pixelIndex = 0;
  //
  //   // Resize the image to match the inputSize
  //   img.Image resizedImage = img.copyResize(image, width: inputSize, height: inputSize);
  //   // img.Image resizedImage = image;
  //
  //   for (var y = 0; y < inputSize; y++) {
  //     for (var x = 0; x < inputSize; x++) {
  //
  //       var pixel = resizedImage.getPixel(x, y);
  //
  //       buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
  //       buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
  //       buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
  //     }
  //   }
  //   return convertedBytes.buffer.asFloat32List();
  // }





}