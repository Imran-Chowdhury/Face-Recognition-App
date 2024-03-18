


import 'dart:math';

import 'package:face/features/train_face/data/data_source/train_face_data_source.dart';
import 'package:face/features/train_face/data/data_source/train_face_data_source_impl.dart';
import 'package:face/features/train_face/domain/train_face_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';





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

     // final lalalaImage = await getOutputList2( name, trainings,  interpreter, nameOfJsonFile);
     //
     // debugPrint(
     //   'Pre-processed image: ${lalalaImage.width}x${lalalaImage.height}, '
     //       'size: ${lalalaImage.buffer.lengthInBytes} bytes',
     // );


     await dataSource.saveOrUpdateJsonInSharedPreferences(name, finalOutputList, nameOfJsonFile );
   //   await dataSource.saveOrUpdateJsonInSharedPreferences(name, finalOutputList, 'testMap');
     // await dataSource.saveOrUpdateJsonInSharedPreferences(name, finalOutputList,'galleryData' );
   }catch(e){
     rethrow;
   }



 }


  @override
  Future<TensorImage> getOutputList2(String name,List trainings, Interpreter interpreter,String nameOfJsonFile)async {



    final inputShape = interpreter.getInputTensor(0).shape;
    final outputShape = interpreter.getOutputTensor(0).shape;

    debugPrint('Input shape: $inputShape');
    debugPrint('Output shape: $outputShape');

    // #3
     final inputType = interpreter.getInputTensor(0).type ;
     final outputType = interpreter.getOutputTensor(0).type;


    debugPrint('Input type: $inputType');
    debugPrint('Output type: $outputType');




    final inputTensor = TensorImage();
    inputTensor.loadImage(trainings[0]);


    final minLength = min(inputTensor.height, inputTensor.width);
    final cropOp = ResizeWithCropOrPadOp(minLength, minLength);



    final shapeLength = inputShape[1];
    final resizeOp = ResizeOp(shapeLength, shapeLength, ResizeMethod.bilinear);

    // #4
    final normalizeOp = NormalizeOp(127.5, 127.5);

    // #5
    final imageProcessor = ImageProcessorBuilder()
        .add(cropOp)
        .add(resizeOp)
        .add(normalizeOp)
        .build();

    imageProcessor.process(inputTensor);
    // print('The inputTensor is $inputTensor');



    // final outputBuffer = TensorBuffer.createFixedSize(
    //   outputShape,
    //     TfLiteType.float32,
    //
    // );
    List output = List.filled(1 * 192, null, growable: false).reshape(
        [1, 192]);


    print('The output tensorBUfferFloat is ${TensorBufferFloat(outputShape).getDataType()}');

// #2
    interpreter.run(inputTensor.buffer, output);
    debugPrint('OutputBuffer: $output');

    // #6
    return inputTensor;











  }


}