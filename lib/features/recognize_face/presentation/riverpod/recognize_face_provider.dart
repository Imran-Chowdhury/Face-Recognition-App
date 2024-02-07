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


  // Future<void> pickImagesAndRecognize(Interpreter interpreter) async {
  //
  //   final ImagePicker _picker = ImagePicker();
  //   late img.Image image;
  //   List<XFile> selectedImages = [];
  //
  //
  //
  //
  //
  //   // Select an image for recognition
  //   XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
  //
  //   // if (pickedImage != null) {
  //   //   selectedImages.add(pickedImage);
  //   // }
  //   // detectionUseCase.detectFaces(selectedImages, faceDetector);
  //
  //   if (pickedImage != null) {
  //     image = img.decodeImage(await pickedImage.readAsBytes())!;
  //   }
  //
  //
  //
  //   if (image != null) {
  //
  //   await useCase.recognizeFace(image, interpreter);
  //
  //
  //   }
  // }



  Future<void> pickImagesAndRecognize(img.Image image, Interpreter interpreter) async {



     final name =  await useCase.recognizeFace(image, interpreter);

     if(name.isNotEmpty){
       state = SuccessState(name: name);
     }else{
       state = const ErrorState('No match!');
     }




  }


}

