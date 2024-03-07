import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../../core/base_state/base_state.dart';
import '../../../face_detection/domain/use_case/face_detection_use_case.dart';
import '../../domain/use_case/recognize_face_use_case.dart';



final recognizefaceProvider = StateNotifierProvider<RecognizeFaceNotifier,BaseState>(
      (ref) {
    return RecognizeFaceNotifier(ref: ref, useCase: ref.read(recognizeFaceUseCaseProvider));
  },
);


class RecognizeFaceNotifier extends StateNotifier<BaseState>{
  RecognizeFaceNotifier({required this.ref,required this.useCase}):super(const InitialState());

  Ref ref;
  RecognizeFaceUseCase useCase;



  Future<void> pickImagesAndRecognize(img.Image image, Interpreter interpreter, String nameOfJsonFile) async {



     final name =  await useCase.recognizeFace(image, interpreter, nameOfJsonFile);

     if(name.isNotEmpty){
       // print('the name is $name');
       state = SuccessState(name: name);
     }else{
        // print('No match!');
       state = const ErrorState('No match!');
     }




  }


}

