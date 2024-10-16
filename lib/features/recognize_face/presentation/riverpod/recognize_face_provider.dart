import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../../core/base_state/base_state.dart';

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





  Future<void> pickImagesAndRecognize(img.Image image, Interpreter interpreter,IsolateInterpreter isolateInterpreter, String nameOfJsonFile) async {


    state = const LoadingState();
    final stopwatch = Stopwatch()..start();

    final name =  await useCase.recognizeFace(image, interpreter, isolateInterpreter,  nameOfJsonFile);

    stopwatch.stop();
    final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;

    // Print the elapsed time in seconds
    print('The Recognition Execution time: $elapsedSeconds seconds');

    if(name.isNotEmpty){
      // print('the name is $name');
      state = SuccessState(name: name);
    }else {
      // print('No match!');
      state = const ErrorState('No match!');
    }




  }


}

