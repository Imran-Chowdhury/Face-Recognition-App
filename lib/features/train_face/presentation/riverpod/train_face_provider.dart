import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../../core/base_state/base_state.dart';
import '../../domain/train_face_use_case.dart';



final trainFaceProvider = StateNotifierProvider<TrainFaceNotifier,BaseState>(
      (ref) {
    return TrainFaceNotifier(ref: ref, useCase: ref.read(trainFaceUseCaseProvider));
  },
);


class TrainFaceNotifier extends StateNotifier<BaseState>{
  Ref ref;
  TrainFaceUseCase useCase;


  TrainFaceNotifier({
   required this.ref,
    required this.useCase
}):super(const InitialState());

  Future<void> pickImagesAndTrain(String name, Interpreter interpreter, List resizedImageList, String nameOfJsonFile) async {




    try {
      state = const LoadingState();
      // Selecting single or multiple images for training
      if(resizedImageList.isEmpty){
        print('An error ocured from trainProvider');
        state = const ErrorState('No Face Detected');
      }else{
        await useCase.getImagesList(name, resizedImageList, interpreter, nameOfJsonFile);
        // state = SuccessState(name: name);
        Fluttertoast.showToast(msg: '$name added successfully!',toastLength: Toast.LENGTH_SHORT,);

      }
     // await useCase.getImagesList(name, resizedImageList, interpreter, nameOfJsonFile);
    }catch(e){
      rethrow;
    }

  }


}