


import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:face/core/base_state/base_state.dart';
import 'package:image/image.dart' as img;
import 'package:face/features/face_detection/presentation/riverpod/face_detection_provider.dart';
import 'package:face/features/recognize_face/presentation/riverpod/recognize_face_provider.dart';
import 'package:face/features/train_face/presentation/riverpod/train_face_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;
import 'package:flutter/src/widgets/image.dart' as IMG;

class HomeScreen extends ConsumerWidget{

  HomeScreen({required this.interpreter,required this.faceDetector});
  final tf_lite.Interpreter interpreter;
  final FaceDetector faceDetector;



  // Future<TfLiteModel.Interpreter> loadModel() async {
  //   return await TfLiteModel.Interpreter.fromAsset('assets/mobilefacenet.tflite');
  // }
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



    Uint8List convertImageToUint8List(img.Image image) {
      // Encode the image to PNG format
      final List<int> pngBytes = img.encodePng(image);

      // Convert the List<int> to Uint8List
      final Uint8List uint8List = Uint8List.fromList(pngBytes);

      return uint8List;
    }


    return Scaffold(
      appBar: AppBar(
        title: Text('Face Recognition'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
                      borderSide: BorderSide(width: 2.0), // Adjust border thickness
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
                      // Validation passed, perform desired actions here



                     await detectController.detectFacesFromImages(faceDetector, 'Training').then((imgList)async{
                      //  if(detectState is SuccessState){
                      // await trainController.pickImagesAndTrain(personName,interpreter,detectState.data);
                      //  }

                       final stopwatch = Stopwatch()..start();

                         await trainController.pickImagesAndTrain(personName,interpreter,imgList);

                       stopwatch.stop();
                       final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
                       print('Detection and Training Execution Time: $elapsedSeconds seconds');

                     });



                      // _detectedFaces = await detectController.detectFacesFromImages(faceDetector);
                      // print(_detectedFaces.length);

                      // detectController.detectFacesFromImages(faceDetector).then((resizedImageList) {
                      //   print('The number of faces is ${resizedImageList.length}');
                      //   // _detectedFaces = resizedImageList;
                      // });
                          // .then((resizedImageList) => trainController.pickImagesAndTrain(personName,interpreter,resizedImageList));
                       // trainController.pickImagesAndTrain(personName,interpreter);

                    } else {
                      // Validation failed
                      print('Validation failed');
                    }
                  },


                  child: const Text('Pick and Train Images'),
                ),
                const SizedBox(height: 30.0,),
                ElevatedButton(
                  onPressed: ()async{

                   await detectController.detectFacesFromImages(faceDetector, 'Recognize').then((value) async{
                     final stopwatch = Stopwatch()..start();

                       await recognizeController. pickImagesAndRecognize(value[0], interpreter);

                     stopwatch.stop();
                     final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
                     print('Detection and Recognition Execution Time: $elapsedSeconds seconds');

                    });




                  },
                  child: const Text('Recognize Image'),
                ),
                const SizedBox(height: 30.0,),


                ElevatedButton(
                  // onPressed: deleteJsonKeyFromSharedPreferences,
                  onPressed: (){},
                  child: const Text(' delete trainings'),
                ),

                const SizedBox(height: 30.0,),

                ElevatedButton(
                  onPressed: getKeysFromTestMap,
                  child: const Text(' Print the Keys'),
                ),
                const SizedBox(height: 30.0,),

              ],
            ),
          ),
          if(detectState is SuccessState)
          // (_detectedFaces.isNotEmpty)?
            Flexible(
              child: ListView.builder(
                // itemCount: _detectedFaces.length,
                itemCount: detectState.data?.length ?? 0,
                itemBuilder: (context, index) {
                  final img.Image image = detectState.data[index];
                  final Uint8List uint8List = convertImageToUint8List(image);
                  // print('Displaying image at index $index: $image');

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
  Future<void> deleteJsonKeyFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the key exists
    bool keyExists = prefs.containsKey('testMap');

    if (keyExists) {
      // Delete the key (file) from SharedPreferences
      prefs.remove('testMap');
      print('deleted json');
    } else {
      print('Key testMap does not exist in SharedPreferences.');
    }
  }
  Future<void> getKeysFromTestMap() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the JSON string from SharedPreferences
    String? jsonTestMap = prefs.getString('testMap');

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
      // print('Keys in testMap:');
      // keys.forEach((key) {
      //   print(key);
      //
      // });
    } else {
      print('testMap is empty or not found in SharedPreferences.');
    }
  }
}