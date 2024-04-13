

import 'dart:math';
import 'dart:typed_data';
import 'package:face/core/base_state/base_state.dart';
import 'package:face/features/recognize_face/domain/repository/recognize_face_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
import '../../../../core/utils/image_to_float32.dart';
import '../data_source/recognize_face_data_source.dart';
import '../data_source/recognize_face_data_source_impl.dart';
import 'package:image/image.dart' as img;
// import 'package:tflite_flutter_plus/tflite_flutter_plus.dart' as tflitePlus;

final recognizeFaceRepositoryProvider = Provider((ref) =>
    RecognizeFaceRepositoryImpl(dataSource:ref.read(recognizeFaceDataSourceProvider) ));


class RecognizeFaceRepositoryImpl implements RecognizeFaceRepository{
  RecognizeFaceRepositoryImpl({required this.dataSource});

 RecognizeFaceDataSource dataSource;


  @override
  Future<String> recognizeFace(img.Image image, Interpreter interpreter, String nameOfJsonFile) async {

    final inputShape = interpreter.getInputTensor(0).shape;
    final outputShape = interpreter.getOutputTensor(0).shape;


    final inputShapeLength = inputShape[1];
    final outputShapeLength = outputShape[1];

    // List input =  imageToByteListFloat32(112, 127.5, 127.5, image);
    // input = input.reshape([1, 112, 112, 3]);


    List input =  imageToByteListFloat32(inputShapeLength, 127.5, 127.5, image);
    // List input =  preProcess(image,160);
    input = input.reshape([1, inputShapeLength, inputShapeLength, 3]);


    // Initialize an empty list for outputs
    // List output = List.filled(1 * 192, null, growable: false).reshape([1, 192]);
    List output = List.filled(1 * outputShapeLength, null, growable: false).reshape([1, outputShapeLength]);

    interpreter.run(input, output);

    // output = output.reshape([192]);
    output = output.reshape([outputShapeLength]);
    var  finalOutput = List.from(output);
    print(finalOutput);


    //  final output = Float32List(1 * 192).reshape([1, 192]);
    // interpreter.run(input, output);
    //
    // var  finalOutput = output[0] as List<double>;
    // print('The final output is $finalOutput');
    // print('The final output[0] is ${finalOutput[0]}');

    Map<String, List<dynamic>> trainings = await dataSource.readMapFromSharedPreferences(nameOfJsonFile);

    // return recognition(trainings, finalOutput, 0.585);
    // return recognition(trainings, finalOutput, 0.8);
    // return recognition(trainings, finalOutput, 0.7);
   //  return recognition(trainings, finalOutput, 0.62);
   //  return recognition(trainings, finalOutput, 0.61);
   //  return recognition(trainings, finalOutput, 0.65);
   //  return recognition(trainings, finalOutput, 0.68); //seemed better
    return recognition(trainings, finalOutput, 15); //seemed better
   //  return recognition(trainings, finalOutput, 0.75); // for burst shot trainings
  }


//   @override
//   Future<String> recognizeFace(img.Image image, Interpreter interpreter, String nameOfJsonFile) async {
//
//
// // Initialization code
// // Create an ImageProcessor with all ops required. For more ops, please
// // refer to the ImageProcessor Ops section in this README.
//
//     // Quantization Params of input tensor at index 0
//     QuantizationParams inputParams = interpreter.getInputTensor(0).params;
//
// // Quantization Params of output tensor at index 0
//     QuantizationParams outputParams = interpreter.getOutputTensor(0).params;
//
//
//
//
//     final inputShape = interpreter.getInputTensor(0).shape;
//     final outputShape = interpreter.getOutputTensor(0).shape;
//
//
//     final inputShapeLength = inputShape[1];
//     final outputShapeLength = outputShape[1];
//     print('The output shape is $outputShapeLength');
//     // final resizeOp = ResizeOp(shapeLength, shapeLength, ResizeMethod.bilinear);
//
//
//     ImageProcessor imageProcessor = ImageProcessorBuilder()
//         .add(ResizeOp(inputShapeLength, inputShapeLength, ResizeMethod.bilinear))
//         .add(NormalizeOp(127.5, 127.5))
//         .build();
//
//
//
//
//     final inputType = interpreter.getInputTensor(0).type;
//
//     // tflitePlus.TfLiteType.float32;
//     TensorImage tensorImage =  TensorImage(tflitePlus.TfLiteType.float32);
//     // tensorImage =  TensorImage.fromImage(trainings[0]);
//     tensorImage.loadImage(image);
//
//     tensorImage = imageProcessor.process(tensorImage);
//
//
//
//
//     // Create a container for the result and specify that this is a quantized model.
//     // Hence, the 'DataType' is defined as UINT8 (8-bit unsigned integer)
//
//     TensorBuffer probabilityBuffer = TensorBuffer.createFixedSize(<int>[1, outputShapeLength], tflitePlus.TfLiteType.float32);
//     // TensorBuffer probabilityBuffer = TensorBufferFloat([1, 512]); //alternate way
//
//
//
//
//     interpreter.run(tensorImage.buffer, probabilityBuffer.buffer);
//
//
//
//     final output =  probabilityBuffer.getDoubleList();
//     print("The output length for recognition is ${output.length}");
//
//
//
//     Map<String, List<dynamic>> trainings = await dataSource.readMapFromSharedPreferences(nameOfJsonFile);
//     // Map<String, List<List<double>>> trainings = await dataSource.readMapFromSharedPreferences(nameOfJsonFile);
//     // return recognition(trainings, finalOutput, 0.585);
//     // return recognition(trainings, finalOutput, 0.8);
//     // return recognition(trainings, finalOutput, 0.7);
//     //  return recognition(trainings, finalOutput, 0.62);
//     //  return recognition(trainings, finalOutput, 0.61);
//     //  return recognition(trainings, finalOutput, 0.65);
//     // return recognition(trainings, output, 0.68); //seemed better
//     return recognition(trainings, output, 1.2); //seemed better
//     //  return recognition(trainings, finalOutput, 0.75); // for burst shot trainings
//   }


  @override
 String recognition(
      Map<String, List<dynamic>> trainings, List<dynamic> finalOutput, double threshold) {
      // Map<String, List<List<double>>> trainings, List<double> finalOutput, double threshold) {
    double minDistance = double.infinity;
    double cosineDistance;
    // double  cosDis = double.infinity;
    String matchedName = '';
    double cosThres = 0.80;
    double maxDistance = 0.0;
    Map<String, double> avgMap = {};
    double avg = 0;
    int counter = 0;
    try{

      trainings.forEach((key, value) {
        for (var innerList in value) {
        // for (List<double> innerList in value) {

          double distance = euclideanDistance(finalOutput, innerList);
          // cosineDistance =  cosineSimilarity(finalOutput, innerList);


          // print('the Cosine distance for $key  is $cosineDistance');
          print('the Euclidean distance for $key  is $distance');


          // avg = avg + distance;
          // counter++;
          // if(counter==value.length){
          //   avg = avg/(value.length);
          //   avgMap[key] = avg;
          //   debugPrint('The counter is $counter and value length is ${value.length}');
          //   counter = 0;
          // }




          //For cosine similarity
          // if (cosineDistance >= cosThres && maxDistance<cosineDistance) {
          //   maxDistance = cosineDistance;
          //   // cosDis = cosineDistance;
          //   matchedName = key;
          // }


          // For euclidean distance
          if (distance <= threshold && distance < minDistance) {
            minDistance = distance;
            // cosDis = cosineDistance;
            matchedName = key;
          }


        }
      });
      // print('the person is $matchedName');
      // print('the minDistance is $minDistance');
       if(matchedName == ''){
         print('Sad');
         print('No match!');

       }else{
         print('Yes!');
         print('the person is $matchedName');
         print('the minDistance is $minDistance');
         // print('the Cosine distance is $maxDistance');
       }
       // print('The avgMap is $avgMap');

      return matchedName;

    }catch(e){
      rethrow;

    }


  }

  @override
  double euclideanDistance(List e1, List e2) {


    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }


  @override
  double cosineSimilarity(List<dynamic> vectorA, List<dynamic> vectorB) {
    if (vectorA.length != vectorB.length) {
      throw ArgumentError("Vectors must have the same length");
    }

    double dotProduct = 0;
    double normA = 0;
    double normB = 0;

    for (int i = 0; i < vectorA.length; i++) {
      dotProduct += vectorA[i] * vectorB[i];
      normA += vectorA[i] * vectorA[i];
      normB += vectorB[i] * vectorB[i];
    }

    normA = sqrt(normA);
    normB = sqrt(normB);

    if (normA == 0 || normB == 0) {
      return 0; // Handle division by zero
    }

    return dotProduct / (normA * normB);
  }



}