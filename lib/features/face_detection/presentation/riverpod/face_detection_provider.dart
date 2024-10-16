








import 'dart:async';



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

        selectedImages = await picker.pickMultiImage();


        final stopwatch = Stopwatch()..start();

        state = const LoadingState();
        final resizedImage = await useCase.detectFaces(selectedImages, faceDetector);

        if(resizedImage.isEmpty){
          print('No face Detected');
          state = const ErrorState('No face detected');

        }
        else{
          state =   SuccessState(data: resizedImage);
        }

        stopwatch.stop();
        final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;




        // Print the elapsed time in seconds
        print('The Detection Execution time: $elapsedSeconds seconds');
        return resizedImage;

      }
      else if(operationType == 'Recognize from gallery'){






        //Selecting 1 image as XFile for Face Detection

        selectedImages = [];



        // selecting multiple pictures for testing and collecting data
        selectedImages = await picker.pickMultiImage();



        final stopwatch = Stopwatch()..start();
        state = const LoadingState();
        final resizedImage = await useCase.detectFaces(selectedImages, faceDetector);
        if(resizedImage.isNotEmpty){
          state =   SuccessState(data: resizedImage);
        }else {
          print('An error occured');
          state = const ErrorState('No face detected');
        }

        stopwatch.stop();
        final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;

        // Print the elapsed time in seconds
        print('The Detection Execution time: $elapsedSeconds seconds');
        return resizedImage;
      }
      else {

        //Number of  XFiles captured from camera directly passed from the home screen ase capturedImages.


        final stopwatch = Stopwatch()..start();
        final resizedImage = await useCase.detectFaces(capturedImages!, faceDetector);
        if(resizedImage.isNotEmpty){
          state =   SuccessState(data: resizedImage);
        }else{
          state  = const ErrorState('No face detected');

        }
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





  Future<List> detectFromLiveFeedForRecognition(List<InputImage> inputImage, List<img.Image> image,  FaceDetector faceDetector)async{
    final stopwatch = Stopwatch()..start();

    state = const LoadingState();
    final croppedImagesList = await useCase.detectFacesFromLiveFeed(inputImage, image, faceDetector);


    stopwatch.stop();
    final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;

    // Print the elapsed time in seconds
    print('The Detection Execution time: $elapsedSeconds seconds');

   if(croppedImagesList.isEmpty){

     state = const ErrorState('No face detected');
   }else{
     state = SuccessState(data: croppedImagesList);
   }
    return croppedImagesList;

  }




}