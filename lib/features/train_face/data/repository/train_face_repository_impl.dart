


import 'package:face/features/train_face/data/data_source/data_source.dart';
import 'package:face/features/train_face/data/data_source/data_source_impl.dart';
import 'package:face/features/train_face/domain/train_face_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../../core/utils/image_to_float32.dart';

final trainFaceRepositoryProvider = Provider((ref) => TrainFaceRepositoryImpl(dataSource: ref.read(trainFaceDataSourceProvider)) );

class TrainFaceRepositoryImpl implements TrainFaceRepository {
  TrainFaceRepositoryImpl({required this.dataSource});
  TrainFaceDataSource dataSource;


@override
 Future<void> getOutputList(String name,List trainings, Interpreter interpreter)async {

  List inputs = [];
   List  finalOutputList = [];

   try {
     for (int i = 0; i < trainings.length; i++) {
       print(trainings.length);
       List input = [];

       input = imageToByteListFloat32(112, 128, 128, trainings[i]);
       input = input.reshape([1, 112, 112, 3]);
       inputs.add(input);
     }



     // Initialize an empty list for outputs
     List<List> outputs = List.filled(inputs.length, [], growable: false);

     // Run inference for each input
     for (int i = 0; i < inputs.length; i++) {
       // Initialize an empty list for output of each input
       List output = List.filled(1 * 192, null, growable: false).reshape(
           [1, 192]);
       interpreter.run(inputs[i], output);
       outputs[i] = output;
       var e = List.from(outputs[i].reshape([192]));
       finalOutputList.add(e);
     }

     dataSource.saveOrUpdateJsonInSharedPreferences(name, finalOutputList);
   }catch(e){
     rethrow;
   }


  // var e1 = List.from(outputs[0].reshape([192]));
  // var e2 = List.from(outputs[1].reshape([192]));
  // var e3 = List.from(outputs[2].reshape([192]));
  // var e4 = List.from(outputs[3].reshape([192]));
  // var e5 = List.from(outputs[4].reshape([192]));
  // var e6 = List.from(outputs[5].reshape([192]));
  // var e7 = List.from(outputs[6].reshape([192]));
  // var e8 = List.from(outputs[7].reshape([192]));
  // var e9 = List.from(outputs[8].reshape([192]));
  // var e10 = List.from(outputs[9].reshape([192]));
  //
  //
  // // dynamic valuesList = [e1,e2,e3,e4,e5,];
  // dynamic valuesList = [e1,e2,e3,e4,e5,e6,e7,e8,e9,e10];


 }
}