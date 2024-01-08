import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
  RecognizeFaceNotifier({required this.ref,required this.useCase}):super(BaseState.initial());

  Ref ref;
  RecognizeFaceUseCase useCase;

  Future<void> pickImagesAndRecognize(Interpreter interpreter) async {

    final ImagePicker _picker = ImagePicker();
    late img.Image image;



    // Select an image for recognition
    XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      image = img.decodeImage(await pickedImage.readAsBytes())!;
    }



    if (image != null) {

      useCase.recognizeFace(image, interpreter);

    }
  }


}

