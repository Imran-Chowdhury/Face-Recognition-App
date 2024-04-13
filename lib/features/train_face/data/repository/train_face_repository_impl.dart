


import 'dart:math';
import 'dart:typed_data';

import 'package:face/features/train_face/data/data_source/train_face_data_source.dart';
import 'package:face/features/train_face/data/data_source/train_face_data_source_impl.dart';
import 'package:face/features/train_face/domain/train_face_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
// import 'package:tflite_flutter_plus/tflite_flutter_plus.dart' as tflitePlus;





import '../../../../core/utils/image_to_float32.dart';

final trainFaceRepositoryProvider = Provider((ref) => TrainFaceRepositoryImpl(dataSource: ref.read(trainFaceDataSourceProvider)) );

class TrainFaceRepositoryImpl implements TrainFaceRepository {
  TrainFaceRepositoryImpl({required this.dataSource});
  TrainFaceDataSource dataSource;


@override
 Future<void> getOutputList(String name,List trainings, Interpreter interpreter,String nameOfJsonFile)async {
  final inputShape = interpreter.getInputTensor(0).shape;
  final outputShape = interpreter.getOutputTensor(0).shape;


  final inputShapeLength = inputShape[1];
  final outputShapeLength = outputShape[1];

// trainings refer to the images from which embeddings are to be extracted
  List inputs = [];
   List  finalOutputList = [];

   try {
     for (int i = 0; i < trainings.length; i++) {
       print(trainings.length);
       List input = [];



       // input = imageToByteListFloat32(112, 127.5, 127.5, trainings[i]);
       // input = input.reshape([1, 112, 112, 3]);

       input = imageToByteListFloat32(inputShapeLength, 127.5, 127.5, trainings[i]);
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


       List output = List.filled(1 * outputShapeLength, null, growable: false).reshape(
           [1, outputShapeLength]);
       interpreter.run(inputs[i], output);
       outputs[i] = output;
       // var e = List.from(outputs[i].reshape([192]));
       var e = List.from(outputs[i].reshape([outputShapeLength]));
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
  Future<void> getOutputList2(String name, List trainings, Interpreter interpreter, String nameOfJsonFile) {
    // TODO: implement getOutputList2
    throw UnimplementedError();
  }



//
//   @override
//   Future<void> getOutputList2(String name,List trainings, Interpreter interpreter,String nameOfJsonFile)async {
//
//
// // Initialization code
// // Create an ImageProcessor with all ops required. For more ops, please
// // refer to the ImageProcessor Ops section in this README.
//
//     // Quantization Params of input tensor at index 0
//
//     List  finalOutputList = [];
//     QuantizationParams inputParams = interpreter.getInputTensor(0).params;
//
// // Quantization Params of output tensor at index 0
//     QuantizationParams outputParams = interpreter.getOutputTensor(0).params;
//
//     print('The input quantization param is $inputParams');
//     print('The output quantization param is $outputParams');
//
//
//     final inputShape = interpreter.getInputTensor(0).shape;
//     final outputShape = interpreter.getOutputTensor(0).shape;
//
//
//     final inputShapeLength = inputShape[1];
//     final outputShapeLength = outputShape[1];
//     print('The shape length is $inputShapeLength');
//    // final resizeOp = ResizeOp(shapeLength, shapeLength, ResizeMethod.bilinear);
//
//
//
//
//     print('Image proecessor done');
//
//
//     final inputType = interpreter.getInputTensor(0).type;
//     print('the inputTYPE is $inputType');
//     // tflitePlus.TfLiteType.float32;
//
//     // tensorImage =  TensorImage.fromImage(trainings[0]);
//
//     for (int i = 0; i < trainings.length; i++) {
//
//       final tensorImage =  TensorImage(tflitePlus.TfLiteType.float32);
//       tensorImage.loadImage(trainings[i]);
//       // tensorImage.loadImage(trainings[0]);
//
//       ImageProcessor imageProcessor = ImageProcessorBuilder()
//         .add(ResizeOp(inputShapeLength, inputShapeLength, ResizeMethod.nearestneighbour))
//         .add(NormalizeOp(127.5, 127.5))
//         .build();
//
//        imageProcessor.process(tensorImage);
//
//
//       print('tensorimage processed');
//       print('The data type of tensor image is ${tensorImage.getDataType()}');
//
//       print('The bytes of input tensor are ${imageProcessor.process(tensorImage).buffer.lengthInBytes}');
//
//
//
//       // Create a container for the result and specify that this is a quantized model.
//       // Hence, the 'DataType' is defined as UINT8 (8-bit unsigned integer)
//
//       TensorBuffer probabilityBuffer = TensorBuffer.createFixedSize([1, outputShapeLength], tflitePlus.TfLiteType.float32);
//       // TensorBuffer probabilityBuffer = TensorBufferFloat([1, 512]); //alternate way
//       print('The probabiligtyBuffer shape is ${probabilityBuffer.getShape()}');
//       print('The probabiligtyBuffer data type is ${probabilityBuffer.getDataType()}');
//       print('the input buffer is ${tensorImage.tensorBuffer.buffer.asFloat32List()}');
//
//
//
//       interpreter.run(tensorImage.buffer, probabilityBuffer.buffer);
//
//
//
//
//
//
//       print('The probabiligtyBuffer bytes are ${ probabilityBuffer.buffer.lengthInBytes}');
//
//       print('Ran interpreter');
//       final output =  probabilityBuffer.getDoubleList();
//       print("The output length is ${output.length}");
//       print('The output from the getoutputlist2 of trainfaceimpl is $output');
//
//       finalOutputList.add(output);
//
//     }
//
//
//     await dataSource.saveOrUpdateJsonInSharedPreferences(name, finalOutputList, nameOfJsonFile );
//
//
//
//   }



  // @override
  // Future<void> getOutputList(String name, List<dynamic> trainings, Interpreter interpreter, String nameOfJsonFile) {
  //   // TODO: implement getOutputList
  //   throw UnimplementedError();
  // }




}