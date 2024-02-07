

import 'dart:math';
import 'package:face/core/base_state/base_state.dart';
import 'package:face/features/recognize_face/domain/repository/recognize_face_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../../core/utils/image_to_float32.dart';
import '../data_source/recognize_face_data_source.dart';
import '../data_source/recognize_face_data_source_impl.dart';
import 'package:image/image.dart' as img;

final recognizeFaceRepositoryProvider = Provider((ref) =>
    RecognizeFaceRepositoryImpl(dataSource:ref.read(recognizeFaceDataSourceProvider) ));


class RecognizeFaceRepositoryImpl implements RecognizeFaceRepository{
  RecognizeFaceRepositoryImpl({required this.dataSource});

 RecognizeFaceDataSource dataSource;



  // @override
  // Future<void> recognizeFace(img.Image image, Interpreter interpreter) async {
  //   // img.Image resizedImage = img.copyResize(image, width: 112, height: 112);
  //
  //   List input =  imageToByteListFloat32(112, 128, 128, image);
  //   input = input.reshape([1, 112, 112, 3]);
  //
  //
  //
  //
  //
  //   // Initialize an empty list for outputs
  //   List output = List.filled(1 * 192, null, growable: false).reshape([1, 192]);
  //
  //   interpreter.run(input, output);
  //   output = output.reshape([192]);
  //
  //
  //
  //   var  finalOutput = List.from(output);
  //   print(finalOutput);
  //   Map<String, List<dynamic>> trainings = await dataSource.readMapFromSharedPreferences();
  //   recognition(trainings, finalOutput, 0.8);
  // }





  @override
  Future<String> recognizeFace(img.Image image, Interpreter interpreter) async {
    // img.Image resizedImage = img.copyResize(image, width: 112, height: 112);

    List input =  imageToByteListFloat32(112, 128, 128, image);
    input = input.reshape([1, 112, 112, 3]);





    // Initialize an empty list for outputs
    List output = List.filled(1 * 192, null, growable: false).reshape([1, 192]);

    interpreter.run(input, output);
    output = output.reshape([192]);



    var  finalOutput = List.from(output);
    print(finalOutput);
    Map<String, List<dynamic>> trainings = await dataSource.readMapFromSharedPreferences();
   return recognition(trainings, finalOutput, 0.8);
  }
  //
  // @override
  // void recognition(
  //     Map<String, List<dynamic>> trainings, List<dynamic> finalOutput, double threshold) {
  //   double minDistance = double.infinity;
  //   String nearestKey = '';
  //
  //   trainings.forEach((key, value) {
  //     for (var innerList in value) {
  //       double distance = euclideanDistance(finalOutput, innerList);
  //       print('the distance is $distance');
  //
  //       if (distance <= threshold && distance < minDistance) {
  //         minDistance = distance;
  //         nearestKey = key;
  //       }
  //     }
  //   });
  //
  //   if (nearestKey != null) {
  //
  //
  //
  //
  //
  //     print('Nearest key within threshold: $nearestKey');
  //     print('Distance: $minDistance');
  //   } else {
  //     // setState(() {
  //     //   personName = 'No match found within the threshold.';
  //     // });
  //
  //     print('No match found within the threshold.');
  //   }
  // }


  @override
 String recognition(
      Map<String, List<dynamic>> trainings, List<dynamic> finalOutput, double threshold) {
    double minDistance = double.infinity;
    String matchedName = '';
    try{

      trainings.forEach((key, value) {
        for (var innerList in value) {
          double distance = euclideanDistance(finalOutput, innerList);
          print('the distance is $distance');

          if (distance <= threshold && distance < minDistance) {
            minDistance = distance;
            matchedName = key;
          }
        }
      });
      return matchedName;

      // if (nearestKey.isNotEmpty) {
      //
      //   print('Nearest key within threshold: $nearestKey');
      //   print('Distance: $minDistance');
      //   // return 'The person is $nearestKey and the min distance is $minDistance';
      //   return ' $nearestKey';
      // } else {
      //
      //
      //   print('No match found within the threshold.');
      //   // return 'No match found within the threshold.';
      //   return 'No match!';
      // }

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

}