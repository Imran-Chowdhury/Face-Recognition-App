


import 'package:face/features/train_face/data/data_source/train_face_data_source.dart';
import 'package:face/features/train_face/data/data_source/train_face_data_source_impl.dart';
import 'package:face/features/train_face/domain/train_face_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../../core/utils/image_to_float32.dart';

final trainFaceRepositoryProvider = Provider((ref) => TrainFaceRepositoryImpl(dataSource: ref.read(trainFaceDataSourceProvider)) );

class TrainFaceRepositoryImpl implements TrainFaceRepository {
  TrainFaceRepositoryImpl({required this.dataSource});
  TrainFaceDataSource dataSource;


@override
 Future<void> getOutputList(String name,List trainings, Interpreter interpreter,String nameOfJsonFile)async {

  List inputs = [];
   List  finalOutputList = [];

   try {
     for (int i = 0; i < trainings.length; i++) {
       print(trainings.length);
       List input = [];


       // input = imageToByteListFloat32(112, 128, 128, trainings[i]);
       input = imageToByteListFloat32(112, 127.5, 127.5, trainings[i]);
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


     await dataSource.saveOrUpdateJsonInSharedPreferences(name, finalOutputList, nameOfJsonFile );
   //   await dataSource.saveOrUpdateJsonInSharedPreferences(name, finalOutputList, 'testMap');
     // await dataSource.saveOrUpdateJsonInSharedPreferences(name, finalOutputList,'galleryData' );
   }catch(e){
     rethrow;
   }



 }
}