import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
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


    late img.Image image;

    List images = [];
    final ImagePicker picker = ImagePicker();
    var count;
    try {
      // Selecting 10 images for training


      // for (var i = 0; i <= 4; i++) {
      //
      //   XFile? pickedImage = await picker.pickImage(
      //       source: ImageSource.gallery);
      //   if (pickedImage != null) {
      //     image = img.decodeImage(await pickedImage.readAsBytes())!;
      //   }
      //
      //   if (image != null) {
      //     images.add(image);
      //   }
      // }
      //
      // print(images.length);

      // useCase.getImagesList(name, images, interpreter);
     await useCase.getImagesList(name, resizedImageList, interpreter, nameOfJsonFile);
    }catch(e){
      rethrow;
    }

  }


}