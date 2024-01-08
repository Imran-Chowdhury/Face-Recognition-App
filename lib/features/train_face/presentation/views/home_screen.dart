


import 'dart:convert';

import 'package:face/core/base_state/base_state.dart';
import 'package:face/features/recognize_face/presentation/riverpod/recognize_face_provider.dart';
import 'package:face/features/train_face/presentation/riverpod/train_face_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as TfLiteModel;

class HomeScreen extends ConsumerWidget{

  HomeScreen({required this.interpreter});
  final TfLiteModel.Interpreter interpreter;



  // Future<TfLiteModel.Interpreter> loadModel() async {
  //   return await TfLiteModel.Interpreter.fromAsset('assets/mobilefacenet.tflite');
  // }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late String personName;
    final _formKey = GlobalKey<FormState>();
    final trainController = ref.watch(trainFaceProvider.notifier);
    final trainState = ref.watch(trainFaceProvider);
    final recognizeController = ref.watch(recognizefaceProvider.notifier);
    final recognizeState = ref.watch(recognizefaceProvider);


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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Validation passed, perform desired actions here

                      print('Validation successful!');
                      trainController.pickImagesAndTrain(personName,interpreter);

                    } else {
                      // Validation failed
                      print('Validation failed');
                    }
                  },


                  child: const Text('Pick and Train Images'),
                ),
                const SizedBox(height: 30.0,),
                ElevatedButton(
                  onPressed: (){
                    recognizeController. pickImagesAndRecognize(interpreter);
                  },
                  child: const Text('Recognize Image'),
                ),
                const SizedBox(height: 30.0,),
                // Text(BaseState.success().data),

                ElevatedButton(
                  onPressed: deleteJsonKeyFromSharedPreferences,
                  // onPressed: (){},
                  child: const Text(' delete trainings'),
                ),

                const SizedBox(height: 30.0,),

                ElevatedButton(
                  onPressed: getKeysFromTestMap,
                  child: Text(' Print the Keys'),
                ),



              ],
            ),
          ),


          // const SizedBox(height: 30.0,),
          // ElevatedButton(
          //   onPressed: _pickImagesAndRecognize,
          //   child: const Text('Recognize Image'),
          // ),
          // Text(personName!),
          // Text('The euclidean distance is $displayDist'),
          // const SizedBox(height: 30.0,),
          //
          // ElevatedButton(
          //   onPressed: deleteJsonKeyFromSharedPreferences,
          //   // onPressed: (){},
          //   child: const Text(' delete trainings'),
          // ),
          //
          // const SizedBox(height: 30.0,),
          //
          // ElevatedButton(
          //   onPressed: getKeysFromTestMap,
          //   child: Text(' Print the Keys'),
          // ),
          //



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

      print('Keys in testMap:');
      keys.forEach((key) {
        print(key);
      });
    } else {
      print('testMap is empty or not found in SharedPreferences.');
    }
  }
}