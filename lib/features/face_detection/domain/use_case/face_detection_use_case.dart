





import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/repository/face_detection_repository_impl.dart';
import '../repository/face_detection_repository.dart';
import 'package:image/image.dart' as img;


final faceDetectionUseCaseProvider = Provider((ref) => FaceDetectionUseCase(repository: ref.read(faceDetectionRepositoryProvider)) );


class FaceDetectionUseCase {
  FaceDetectionUseCase({required this.repository});
  FaceDetectionRepository repository;

  Future<List> detectFaces(List<XFile> selectedImages, FaceDetector faceDetector)async{
    return await repository.detectFaces(selectedImages, faceDetector);
  }


  Future<List> detectFacesFromLiveFeed(List<InputImage> inputImage, List<img.Image> image,  FaceDetector faceDetector)async{
    return await repository.detectFacesFromLiveFeed(inputImage,image, faceDetector);
  }


}