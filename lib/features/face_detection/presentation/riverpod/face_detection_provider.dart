








import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/base_state/base_state.dart';
import '../../domain/use_case/face_detection_use_case.dart';
import 'package:image/image.dart' as img;



final faceDetectionProvider = StateNotifierProvider<FaceDetectionNotifier,BaseState>
  ((ref) => FaceDetectionNotifier(ref: ref, useCase: ref.read(faceDetectionUseCaseProvider)));

class FaceDetectionNotifier extends StateNotifier<BaseState>{
  Ref ref;
  FaceDetectionUseCase useCase;

  FaceDetectionNotifier({
    required this.ref,
    required this.useCase
  }):super(const InitialState());


  Future<List> detectFacesFromImages(FaceDetector faceDetector, String operationType, [List<XFile>? capturedImages])async{

    final ImagePicker picker = ImagePicker();
    List<XFile> selectedImages = [];

    try {

      if(operationType == 'Train from gallery'){
        //Selecting 5 images as XFile for Face Detection
        //Training
        for (var i = 0; i <= 4; i++) {

          XFile? pickedImage = await picker.pickImage(
              source: ImageSource.gallery);
          if (pickedImage != null) {
            selectedImages.add(pickedImage);
          }
        }
        final stopwatch = Stopwatch()..start();
        final resizedImage = await useCase.detectFaces(selectedImages, faceDetector);
        state =   SuccessState(data: resizedImage);
        stopwatch.stop();
        final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;




        // Print the elapsed time in seconds
        print('The Detection Execution time: $elapsedSeconds seconds');
        return resizedImage;

      }
      else if(operationType == 'Recognize from gallery'){

        //Selecting 1 image as XFile for Face Detection
        //Recognition
        selectedImages = [];
        XFile? pickedImage = await picker.pickImage(
            source: ImageSource.gallery);
        if (pickedImage != null) {
          selectedImages.add(pickedImage);
        }
        final stopwatch = Stopwatch()..start();
        final resizedImage = await useCase.detectFaces(selectedImages, faceDetector);
        state =   SuccessState(data: resizedImage);
        stopwatch.stop();
        final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;

        // Print the elapsed time in seconds
        print('The Detection Execution time: $elapsedSeconds seconds');
        return resizedImage;
      }
      else {

        //5 XFiles captured from camera directly passed from the home screen ase capturedImages.


        final stopwatch = Stopwatch()..start();
        final resizedImage = await useCase.detectFaces(capturedImages!, faceDetector);
        state =   SuccessState(data: resizedImage);
        stopwatch.stop();
        final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;

        // Print the elapsed time in seconds
        print('The Detection Execution time: $elapsedSeconds seconds');
        return resizedImage;
      }


    }catch(e){
      rethrow;
    }
  }




 Future<List> detectFromLiveFeedForRecognition(InputImage inputImage, img.Image image,  FaceDetector faceDetector)async{

    final croppedImagesList = await useCase.detectFacesFromLiveFeed(inputImage, image, faceDetector);


   if(croppedImagesList.isEmpty){
     state = const ErrorState('No face detected');
   }else{
     state = const SuccessState();
   }
    return croppedImagesList;

  }




}