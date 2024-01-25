



import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

abstract class FaceDetectionRepository{

  Future<List> detectFaces(List<XFile> selectedImages, FaceDetector faceDetector);

  List cropFace(List<XFile> selectedImages, List<Face> face);


}