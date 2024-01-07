





import 'dart:async';
import 'dart:convert';

import 'dart:math';
import 'dart:typed_data';

import 'package:face/features/train_face/presentation/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as TfLiteModel;



void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that Flutter is initialized

  // Load the model before running the app
  final interpreter = await loadModel();

  runApp(
    ProviderScope(
      child: MyApp(interpreter: interpreter),
    ),
  );
}

Future<TfLiteModel.Interpreter> loadModel() async {
  return await TfLiteModel.Interpreter.fromAsset('assets/mobilefacenet.tflite');
}

class MyApp extends StatelessWidget {
  final TfLiteModel.Interpreter interpreter;

  const MyApp({required this.interpreter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Your app's configuration...
      home: HomeScreen(interpreter: interpreter),
    );
  }
}
//
// void main() {
//   runApp(const ProviderScope(
//       // child: MyApp()
//       child: Home(),
//   ));
// }
//
// class Home extends StatefulWidget {
//   const Home({super.key});
//
//   @override
//   State<Home> createState() => _HomeState();
// }
//
// class _HomeState extends State<Home> {
//
//   @override
//   void initState(){
//     super.initState();
//     loadModel().then((loadedInterpreter) {
//       interpreter = loadedInterpreter;
//       // interpreter = loadedInterpreter!;
//
//     });
//
//   }
//   late TfLiteModel.Interpreter interpreter;
//   Future<TfLiteModel.Interpreter> loadModel() async {
//     return await TfLiteModel.Interpreter.fromAsset('assets/mobilefacenet.tflite');
//   }
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: HomeScreen(interpreter: interpreter,),
//     );
//   }
// }

// void main() {
//   runApp(const ProviderScope(
//      child: MyApp()
//
//   ));
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MyHomePage(),
//     );
//   }
// }


class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TfLiteModel.Interpreter interpreter;
  bool modelLoaded = false;
  late img.Image image1;
  late img.Image image2;
  late img.Image image3;
  late img.Image image4;
  late img.Image image5;
  late img.Image image6;
  late img.Image image7;
  late img.Image image8;
  late img.Image image9;
  late img.Image image10;
  String matched = '';
  double minDist = 999;
  double displayDist = 0.0;
  double threshold = 1.0;
  String? personName = '';
  late String textFieldValue;
  // late Uint8List imageData ;

  final _formKey = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
    loadModel().then((loadedInterpreter) {
      interpreter = loadedInterpreter;
      // interpreter = loadedInterpreter!;
      setState(() {
        modelLoaded = true;
      });
    });

  }

  Future<TfLiteModel.Interpreter> loadModel() async {
    return await TfLiteModel.Interpreter.fromAsset('assets/mobilefacenet.tflite');
  }


  // Future<TfLiteModel.Interpreter?> loadModel() async {
  //   try {
  //     final gpuDelegateV2 = TfLiteModel.GpuDelegateV2(
  //         options: TfLiteModel.GpuDelegateOptionsV2(
  //             isPrecisionLossAllowed: true,
  //             inferencePreference:TfLiteModel.TfLiteGpuInferenceUsage.fastSingleAnswer,
  //             inferencePriority1: TfLiteModel.TfLiteGpuInferencePriority.minLatency,
  //             inferencePriority2: TfLiteModel.TfLiteGpuInferencePriority.minMemoryUsage,
  //             inferencePriority3: TfLiteModel.TfLiteGpuInferencePriority.auto,
  //             maxDelegatePartitions: 1));
  //
  //     var interpreterOptions = TfLiteModel.InterpreterOptions()
  //       ..addDelegate(gpuDelegateV2);
  //     return await TfLiteModel.Interpreter.fromAsset('mobilefacenet.tflite',
  //         options: interpreterOptions);
  //   } on Exception {
  //
  //     print('Failed to load model.');
  //      return null;
  //   }
  // }
  //
  // Future<void> _pickImagesAndRecognize() async {
  //   final ImagePicker _picker = ImagePicker();
  //
  //   // Pick first image
  //   XFile? pickedImage1 = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedImage1 != null) {
  //     image1 = img.decodeImage(await pickedImage1.readAsBytes())!;
  //   }
  //
  //   // Pick second image
  //   XFile? pickedImage2 = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedImage2 != null) {
  //     image2 = img.decodeImage(await pickedImage2.readAsBytes())!;
  //
  //
  //   }
  //
  //   if (image1 != null && image2 != null) {
  //     // Convert both images to Float32
  //     List input1 = imageToByteListFloat32(112, 128, 128, image1);
  //     input1 = input1.reshape([1, 112, 112, 3]);
  //     List input2 = imageToByteListFloat32(112, 128, 128, image2);
  //     input2 = input2.reshape([1, 112, 112, 3]);
  //
  //
  //       var inputs = [input1, input2,input1, input2];
  //
  //     double minDist = 999;
  //     double currDist = 0.0;
  //     double threshold = 1.0;
  //
  //
  //     List output1 = List.filled(1 * 192, null, growable: false).reshape([1, 192]);
  //     List output2 = List.filled(1 * 192, null, growable: false).reshape([1, 192]);
  //
  //     var outputs = {0: output1, 1: output2};
  //     interpreter.runForMultipleInputs(inputs, outputs);
  //
  //
  //     print(outputs);
  //
  //
  //     // interpreter.run(input1, output1);
  //     // output1 = output1.reshape([192]);
  //     // var e1 = List.from(output1);
  //     // print('the e1 list is $e1');
  //     //
  //     // interpreter.run(input2, output2);
  //     // output2 = output2.reshape([192]);
  //     // var e2 = List.from(output2);
  //     // print('the e2 list is $e2');
  //
  //
  //     currDist =  euclideanDistance(e1, e2);
  //     if (currDist <= threshold && currDist < minDist) {
  //       print('the current distance is $currDist');
  //       minDist = currDist;
  //       print('same person');
  //       // _predRes = label;
  //       // if (_verify == false) {
  //       //   _verify = true;
  //       // }
  //     }else{
  //       print('the current distance is $currDist');
  //       print('different persons');
  //
  //     }
  //
  //
  //   }
  // }




  Future<void> _pickImagesAndTrain() async {
    matched = '';
    final ImagePicker _picker = ImagePicker();



    // Pick first image
    XFile? pickedImage1 = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage1 != null) {
      image1 = img.decodeImage(await pickedImage1.readAsBytes())!;
    }

    // Pick second image
    XFile? pickedImage2 = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage2 != null) {
      image2 = img.decodeImage(await pickedImage2.readAsBytes())!;
    }

    XFile? pickedImage3 = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage3 != null) {
      image3 = img.decodeImage(await pickedImage3.readAsBytes())!;
    }

    XFile? pickedImage4 = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage4 != null) {
      image4 = img.decodeImage(await pickedImage4.readAsBytes())!;
    }


    XFile? pickedImage5 = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage5 != null) {
      image5 = img.decodeImage(await pickedImage5.readAsBytes())!;
    }

    XFile? pickedImage6 = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage6 != null) {
      image6 = img.decodeImage(await pickedImage6.readAsBytes())!;
    }

    XFile? pickedImage7 = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage7 != null) {
      image7 = img.decodeImage(await pickedImage7.readAsBytes())!;
    }

    XFile? pickedImage8 = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage8 != null) {
      image8 = img.decodeImage(await pickedImage8.readAsBytes())!;
    }

    XFile? pickedImage9 = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage9 != null) {
      image9 = img.decodeImage(await pickedImage9.readAsBytes())!;
    }
    XFile? pickedImage10 = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage10 != null) {
      image10 = img.decodeImage(await pickedImage10.readAsBytes())!;
    }

    // if (image1 != null && image2 != null && image3 != null && image4 != null&& image5 != null){
    if (image1 != null && image2 != null && image3 != null && image4 != null&& image5 != null
        && image6 != null&& image7 != null&& image8 != null&& image9 != null&& image10 != null) {
      // Convert both images to Float32
      List input1 = imageToByteListFloat32(112, 128, 128, image1);
      input1 = input1.reshape([1, 112, 112, 3]);

      List input2 = imageToByteListFloat32(112, 128, 128, image2);
      input2 = input2.reshape([1, 112, 112, 3]);

      List input3 = imageToByteListFloat32(112, 128, 128, image1);
      input3 = input3.reshape([1, 112, 112, 3]);

      List input4 = imageToByteListFloat32(112, 128, 128, image2);
      input4 = input4.reshape([1, 112, 112, 3]);

      List input5 = imageToByteListFloat32(112, 128, 128, image2);
      input5 = input5.reshape([1, 112, 112, 3]);

      List input6 = imageToByteListFloat32(112, 128, 128, image2);
      input6 = input6.reshape([1, 112, 112, 3]);

      List input7 = imageToByteListFloat32(112, 128, 128, image2);
      input7 = input7.reshape([1, 112, 112, 3]);

      List input8 = imageToByteListFloat32(112, 128, 128, image2);
      input8 = input8.reshape([1, 112, 112, 3]);

      List input9 = imageToByteListFloat32(112, 128, 128, image2);
      input9 = input9.reshape([1, 112, 112, 3]);

      List input10 = imageToByteListFloat32(112, 128, 128, image2);
      input10 = input10.reshape([1, 112, 112, 3]);

      // Create a list of inputs
      var inputs = [input1, input2, input3, input4, input5,input6, input7,input8,input9,input10];

      // Initialize an empty list for outputs
      List<List> outputs = List.filled(inputs.length, [], growable: false);

      // Run inference for each input
      for (int i = 0; i < inputs.length; i++) {
        // Initialize an empty list for output of each input
        List output = List.filled(1 * 192, null, growable: false).reshape([1, 192]);
        interpreter.run(inputs[i], output);
        outputs[i] = output;
      }


      var e1 = List.from(outputs[0].reshape([192]));
      var e2 = List.from(outputs[1].reshape([192]));
      var e3 = List.from(outputs[2].reshape([192]));
      var e4 = List.from(outputs[3].reshape([192]));
      var e5 = List.from(outputs[4].reshape([192]));
      var e6 = List.from(outputs[5].reshape([192]));
      var e7 = List.from(outputs[6].reshape([192]));
      var e8 = List.from(outputs[7].reshape([192]));
      var e9 = List.from(outputs[8].reshape([192]));
      var e10 = List.from(outputs[9].reshape([192]));


      // dynamic valuesList = [e1,e2,e3,e4,e5,];
      dynamic valuesList = [e1,e2,e3,e4,e5,e6,e7,e8,e9,e10];


      // Map<String, List<List>> testMap = {
      //   'Imran' : [e1,e2,e3,e4,e5],
      // };

      // await saveMapToSharedPreferences(testMap);
      await saveOrUpdateJsonInSharedPreferences(textFieldValue, valuesList );

      dynamic printMap = await readMapFromSharedPreferences();
      print(printMap);


      // currDist =  euclideanDistance(e1, e2);
      // // if (currDist <= threshold && currDist < minDist) {
      // if (currDist <= threshold) {
      //   print('the current distance is $currDist');
      //   minDist = currDist;
      //   setState(() {
      //     matched = 'Same person';
      //   });
      //
      //   print('same person');
      //
      // }else{
      //   print('the current distance is $currDist');
      //   setState(() {
      //     matched = 'Different Person';
      //   });
      //
      //   print('different persons');
      //
      // }


    }
  }

  Future<void> _pickImagesAndRecognize() async {
    matched = '';
    final ImagePicker _picker = ImagePicker();



    // Pick first image
    XFile? pickedImage1 = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage1 != null) {
      image1 = img.decodeImage(await pickedImage1.readAsBytes())!;
    }



    if (image1 != null) {
      // Convert both images to Float32
      DateTime startTime = DateTime.now();
      List input1 = imageToByteListFloat32(112, 128, 128, image1);
      input1 = input1.reshape([1, 112, 112, 3]);





      // Initialize an empty list for outputs
      List output = List.filled(1 * 192, null, growable: false).reshape([1, 192]);

      interpreter.run(input1, output);
      output = output.reshape([192]);



     var  e1 = List.from(output);
     // print(e1);




      Map<String, List<dynamic>> printMap = await readMapFromSharedPreferences();
      // print(printMap);


      // Measure time taken by the function
      // DateTime startTime = DateTime.now();
      recognition(printMap, e1, 1.00);
      DateTime endTime = DateTime.now();

      // Calculate execution time in milliseconds
      int executionTime = endTime.difference(startTime).inMilliseconds;

      print('Execution time: $executionTime ms');
      // findKeyWithThreshold(printMap, e1, 1.0);




    }
  }
  void recognition(
      Map<String, List<dynamic>> data, List<dynamic> foundList, double threshold) {
    double minDistance = double.infinity;
    String? nearestKey;

    data.forEach((key, value) {
      for (var innerList in value) {
        double distance = euclideanDistance(foundList, innerList);
         print('the distance is $distance');

        if (distance <= threshold && distance < minDistance) {
          minDistance = distance;
          nearestKey = key;
        }
      }
    });

    if (nearestKey != null) {
      setState(() {
        personName = nearestKey;
        displayDist = minDistance;
      });

      print('Nearest key within threshold: $nearestKey');
      print('Distance: $minDistance');
    } else {
      setState(() {
        personName = 'No match found within the threshold.';
      });

      print('No match found within the threshold.');
    }
  }

  // void findKeyWithThreshold(
  //     Map<String, List<dynamic>> data, List<dynamic> foundList, double threshold) {
  //   bool found = false;
  //   // var count = 1;
  //   // for(var key in data.keys){
  //   //   print(key);
  //   //   for(var value in data.values){
  //   //     for (var list in value){
  //   //       count = count+1;
  //   //       double dis = euclideanDistance(foundList, list);
  //   //       print(dis);
  //   //
  //   //       if (dis <= threshold) {
  //   //         print('Distance between foundList and $key is $dis');
  //   //         print('Key: $key');
  //   //         found = true;
  //   //         break;
  //   //       }
  //   //     }
  //   //   }
  //   // }
  //   // print(count);
  //   // if (!found) {
  //   //   print('No match found within the threshold.');
  //   // }
  //
  //   data.forEach((key, value) {
  //     // print('Key: $key');
  //     for (var innerList in value) {
  //       // print(innerList);
  //       double dis = euclideanDistance(foundList, innerList);
  //       if (dis <= threshold) {
  //         print('Distance between foundList and $key is $dis');
  //         print('Key: $key');
  //         found = true;
  //         break;
  //       }
  //
  //
  //     }
  //
  //
  //   });
  //   if (!found) {
  //     print('No match found within the threshold.');
  //   }
  //
  // }



  Future<void> saveOrUpdateJsonInSharedPreferences(String key, dynamic listOfOutputs) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the JSON file exists in SharedPreferences
    String? existingJsonString = prefs.getString('testMap');

    if (existingJsonString == null) {
      // If the JSON file doesn't exist, create a new one with the provided key and value
      Map<String, dynamic> newJsonData = {key: listOfOutputs};
      await prefs.setString('testMap', jsonEncode(newJsonData));
    } else {
      // If the JSON file exists, update it
      Map<String, dynamic> existingJson =
      json.decode(existingJsonString) as Map<String, dynamic>;

      // Check if the key already exists in the JSON
      if (existingJson.containsKey(key)) {
        // If the key exists, update its value
        existingJson[key] = listOfOutputs;
      } else {
        // If the key doesn't exist, add a new key-value pair
        existingJson[key] = listOfOutputs;
      }

      // Save the updated JSON back to SharedPreferences
      await prefs.setString('testMap', jsonEncode(existingJson));
    }
  }


  // Future<void> saveMapToSharedPreferences(Map<String, List<List>> nameMap) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final jsonMap = nameMap.map((key, value) {
  //     return MapEntry(key, value.map((list) => list.join(',')).toList());
  //   });
  //   prefs.setString('testMap', json.encode(jsonMap));
  //   print('Map saved to SharedPreferences.');
  // }



  Future<Map<String, List<dynamic>>> readMapFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = prefs.getString('testMap');
    if (jsonMap != null) {
      final decodedMap = Map<String, List<dynamic>>.from(json.decode(jsonMap));
      // final resultMap = decodedMap.map((key, value) {
      //   return MapEntry(
      //     key,
      //     value.map((str) => str.split(',').map(int.parse).toList()).toList(),
      //   );
      // });
      // return resultMap;
      return decodedMap;
    } else {
      return {};
    }
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


  Float32List imageToByteListFloat32(
      int inputSize, double mean, double std, img.Image image) {
    // ... Your existing image processing logic remains unchanged ...

    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
  var buffer = Float32List.view(convertedBytes.buffer);
  int pixelIndex = 0;

  // Resize the image to match the inputSize
  img.Image resizedImage = img.copyResize(image, width: inputSize, height: inputSize);
    // List<int> imageBytes = img.encodePng(resizedImage); // Encoding the image

    // setState(() {
    //   imageData = Uint8List.fromList(imageBytes);
    // });


  for (var y = 0; y < inputSize; y++) {
    for (var x = 0; x < inputSize; x++) {
      
     var pixel = resizedImage.getPixel(x, y);

      buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
      buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
      buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
    }
  }
  return convertedBytes.buffer.asFloat32List();
  }







  double euclideanDistance(List e1, List e2) {


  double sum = 0.0;
  for (int i = 0; i < e1.length; i++) {
    sum += pow((e1[i] - e2[i]), 2);
  }
  return sqrt(sum);
}

  @override
  Widget build(BuildContext context) {
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
                textFieldValue = value;
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
                  _pickImagesAndTrain();

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


          const SizedBox(height: 30.0,),
          ElevatedButton(
            onPressed: _pickImagesAndRecognize,
            child: const Text('Recognize Image'),
          ),
          Text(personName!),
          Text('The euclidean distance is $displayDist'),
          const SizedBox(height: 30.0,),

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
    );
  }

  @override
  void dispose() {
    interpreter.close();
    super.dispose();
  }
}


























