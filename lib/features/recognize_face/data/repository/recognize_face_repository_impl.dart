

import 'dart:math';

import 'package:face/features/recognize_face/domain/repository/recognize_face_repository.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../../core/utils/image_to_float32.dart';
import '../data_source/recognize_face_data_source.dart';
import '../data_source/recognize_face_data_source_impl.dart';


final recognizeFaceRepositoryProvider = Provider((ref) =>
    RecognizeFaceRepositoryImpl(dataSource:ref.read(recognizeFaceDataSourceProvider) ));


class RecognizeFaceRepositoryImpl implements RecognizeFaceRepository{
  RecognizeFaceRepositoryImpl({required this.dataSource});

 RecognizeFaceDataSource dataSource;




  //   @override
  // Future<String> recognizeFace(img.Image image, Interpreter interpreter, String nameOfJsonFile) async {
  //
  //   final inputShape = interpreter.getInputTensor(0).shape;
  //   final outputShape = interpreter.getOutputTensor(0).shape;
  //
  //
  //   final inputShapeLength = inputShape[1];
  //   final outputShapeLength = outputShape[1];
  //
  //   // List input =  imageToByteListFloat32(112, 127.5, 127.5, image);
  //   // input = input.reshape([1, 112, 112, 3]);
  //
  //
  //   List input =  imageToByteListFloat32(inputShapeLength, 127.5, 127.5, image);
  //   // List input =  preProcess(image,160);
  //   input = input.reshape([1, inputShapeLength, inputShapeLength, 3]);
  //
  //
  //   // Initialize an empty list for outputs
  //   // List output = List.filled(1 * 192, null, growable: false).reshape([1, 192]);
  //   List output = List.filled(1 * outputShapeLength, null, growable: false).reshape([1, outputShapeLength]);
  //
  //   interpreter.run(input, output);
  //
  //   // output = output.reshape([192]);
  //   output = output.reshape([outputShapeLength]);
  //   var  finalOutput = List.from(output);
  //   print(finalOutput);
  //
  //
  //   //  final output = Float32List(1 * 192).reshape([1, 192]);
  //   // interpreter.run(input, output);
  //   //
  //   // var  finalOutput = output[0] as List<double>;
  //   // print('The final output is $finalOutput');
  //   // print('The final output[0] is ${finalOutput[0]}');
  //
  //   Map<String, List<dynamic>> trainings = await dataSource.readMapFromSharedPreferences(nameOfJsonFile);
  //
  //   // return recognition(trainings, finalOutput, 0.585);
  //   // return recognition(trainings, finalOutput, 0.8);
  //   // return recognition(trainings, finalOutput, 0.7);
  //  //  return recognition(trainings, finalOutput, 0.62);
  //  //  return recognition(trainings, finalOutput, 0.61);
  //  //  return recognition(trainings, finalOutput, 0.65);
  //  //  return recognition(trainings, finalOutput, 0.68); //seemed better
  //   return recognition(trainings, finalOutput, 15.5); //seemed better
  //  //  return recognition(trainings, finalOutput, 17.5); //seemed better
  //  //  return recognition(trainings, finalOutput, 0.75); // for burst shot trainings
  // }




  @override
  Future<String> recognizeFace(img.Image image, Interpreter interpreter,IsolateInterpreter isolateInterpreter, String nameOfJsonFile) async {


    final stopwatch = Stopwatch()..start();

    final inputShape = interpreter.getInputTensor(0).shape;
    final outputShape = interpreter.getOutputTensor(0).shape;


    final inputShapeLength = inputShape[1];
    final outputShapeLength = outputShape[1];
    // var  finalOutput;

    // List input =  imageToByteListFloat32(112, 127.5, 127.5, image);
    // input = input.reshape([1, 112, 112, 3]);


    List input =  imageToByteListFloat32(inputShapeLength, 127.5, 127.5, image);
    // List input =  preProcess(image,160);
    input = input.reshape([1, inputShapeLength, inputShapeLength, 3]);


    // Initialize an empty list for outputs
    // List output = List.filled(1 * 192, null, growable: false).reshape([1, 192]);
    List output = List.filled(1 * outputShapeLength, null, growable: false).reshape([1, outputShapeLength]);

    // interpreter.run(input, output);



    await isolateInterpreter.run(input, output);





    output = output.reshape([outputShapeLength]);
    var  finalOutput = List.from(output);
    // print(finalOutput);



    // output = output.reshape([192]);


    //  final output = Float32List(1 * 192).reshape([1, 192]);
    // interpreter.run(input, output);
    //
    // var  finalOutput = output[0] as List<double>;
    // print('The final output is $finalOutput');
    // print('The final output[0] is ${finalOutput[0]}');





    Map<String, List<dynamic>> trainings = await dataSource.readMapFromSharedPreferences(nameOfJsonFile);

    stopwatch.stop();
    final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
    print('Inference Time: $elapsedSeconds seconds');

    // return 'Testing...';

    //  return recognition(trainings, finalOutput, 15.5); //seemed better and the safest to go
    return recognition(trainings, finalOutput, 16.5); //seemed better

  }







  @override
 String recognition(
      Map<String, List<dynamic>> trainings, List<dynamic> finalOutput, double threshold) {
      // Map<String, List<List<double>>> trainings, List<double> finalOutput, double threshold) {

    final stopwatch = Stopwatch()..start();

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

      stopwatch.stop();
      final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
      print('recognize Time: $elapsedSeconds seconds');

      return matchedName+minDistance.toString();



    }catch(e){
      rethrow;

    }


  }

  @override
  double euclideanDistance(List e1, List e2) {
    // final stopwatch = Stopwatch()..start();

    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }

    // stopwatch.stop();
    // final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
    // print('Euclidean distance Time: $elapsedSeconds seconds');
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