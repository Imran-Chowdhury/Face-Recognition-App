



import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

abstract class FaceDetectionRepository{

  Future<List> detectFaces(List<XFile> selectedImages, FaceDetector faceDetector);


  Future detectFacesFromLiveFeed(List<InputImage> inputImage, List<img.Image> image,  FaceDetector faceDetector);

  List cropFace(List<XFile> selectedImages, List<Face> face);


  List cropFacesFromLiveFeed(List<img.Image> image, List<Face> face);


}