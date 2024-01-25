




import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:image/image.dart' as img;
import '../../../../core/base_state/base_state.dart';
import '../../domain/use_case/face_detection_use_case.dart';



final faceDetectionProvider = StateNotifierProvider<FaceDetectionNotifier,BaseState>
  ((ref) => FaceDetectionNotifier(ref: ref, useCase: ref.read(faceDetectionUseCaseProvider)));

class FaceDetectionNotifier extends StateNotifier<BaseState>{
  Ref ref;
  FaceDetectionUseCase useCase;

  FaceDetectionNotifier({
    required this.ref,
    required this.useCase
  }):super(const InitialState());


  //
  // Future<List> detectFacesFromImages(FaceDetector faceDetector)async{
  //
  //   final ImagePicker picker = ImagePicker();
  //   List<XFile> selectedImages = [];
  //
  //   try {
  //     //Selecting 5 images as XFile for face Detection
  //     for (var i = 0; i <= 4; i++) {
  //
  //       XFile? pickedImage = await picker.pickImage(
  //           source: ImageSource.gallery);
  //       if (pickedImage != null) {
  //         selectedImages.add(pickedImage);
  //       }
  //   }
  //     return useCase.detectFaces(selectedImages, faceDetector);
  //
  //
  // }catch(e){
  //     rethrow;
  //   }
  // }

  Future<List> detectFacesFromImages(FaceDetector faceDetector, String operationType)async{


    final ImagePicker picker = ImagePicker();
    List<XFile> selectedImages = [];

    try {

      if(operationType == 'Training'){
        //Selecting 5 images as XFile for Face Detection
        //Training
        for (var i = 0; i <= 4; i++) {

          XFile? pickedImage = await picker.pickImage(
              source: ImageSource.gallery);
          if (pickedImage != null) {
            selectedImages.add(pickedImage);
          }
        }
        final resizedImage = await useCase.detectFaces(selectedImages, faceDetector);
        state =   SuccessState(data: resizedImage);
        return resizedImage;
      }else{
        //Selecting 1 image as XFile for Face Detection
        //Recognition
        selectedImages = [];
        XFile? pickedImage = await picker.pickImage(
            source: ImageSource.gallery);
        if (pickedImage != null) {
          selectedImages.add(pickedImage);
        }

        final resizedImage = await useCase.detectFaces(selectedImages, faceDetector);
        state =   SuccessState(data: resizedImage);
        return resizedImage;
      }




    }catch(e){
      rethrow;
    }
  }

}