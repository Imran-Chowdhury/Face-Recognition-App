


import 'package:face/features/train_face/presentation/riverpod/train_face_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as TfLiteModel;

class HomeScreen extends ConsumerWidget{

  HomeScreen({required this.interpreter});
  final TfLiteModel.Interpreter interpreter;



  Future<TfLiteModel.Interpreter> loadModel() async {
    return await TfLiteModel.Interpreter.fromAsset('assets/mobilefacenet.tflite');
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late String personName;
    final _formKey = GlobalKey<FormState>();
    final controller = ref.watch(trainFaceProvider.notifier);
    final state = ref.watch(trainFaceProvider);
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
                      controller.pickImagesAndTrain(personName,interpreter);

                    } else {
                      // Validation failed
                      print('Validation failed');
                    }
                  },


                  child: const Text('Pick and Train Images'),
                ),
                // if(imageData!=null) Image.memory(imageData),

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

}