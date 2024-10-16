



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
  Future<void> getOutputList(String name, List trainings,
      Interpreter interpreter, String nameOfJsonFile) async {
    final inputShape = interpreter
        .getInputTensor(0)
        .shape;
    final outputShape = interpreter
        .getOutputTensor(0)
        .shape;


    final inputShapeLength = inputShape[1];
    final outputShapeLength = outputShape[1];

// trainings refer to the images from which embeddings are to be extracted
    List inputs = [];
    List finalOutputList = [];

    try {
      for (int i = 0; i < trainings.length; i++) {
        print(trainings.length);
        List input = [];


        // input = imageToByteListFloat32(112, 127.5, 127.5, trainings[i]);
        // input = input.reshape([1, 112, 112, 3]);

        input = imageToByteListFloat32(
            inputShapeLength, 127.5, 127.5, trainings[i]);
        // input =  preProcess(trainings[i],160);
        input = input.reshape([1, inputShapeLength, inputShapeLength, 3]);
        inputs.add(input);
      }


      // Initialize an empty list for outputs
      List<List> outputs = List.filled(inputs.length, [], growable: false);

      // Run inference for each input
      for (int i = 0; i < inputs.length; i++) {
        // Initialize an empty list for output of each input


        // List output = List.filled(1 * 192, null, growable: false).reshape(
        //     [1, 192]);


        List output = List.filled(1 * outputShapeLength, null, growable: false)
            .reshape(
            [1, outputShapeLength]);
        interpreter.run(inputs[i], output);
        outputs[i] = output;
        // var e = List.from(outputs[i].reshape([192]));
        var e = List.from(outputs[i].reshape([outputShapeLength]));
        finalOutputList.add(e);
      }


      await dataSource.saveOrUpdateJsonInSharedPreferences(
          name, finalOutputList, nameOfJsonFile);
    } catch (e) {
      rethrow;
    }
  }

}