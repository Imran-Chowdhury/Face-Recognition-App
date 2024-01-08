
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';


abstract class RecognizeFaceRepository{


  Future<void> recognizeFace(img.Image image, Interpreter interpreter);

  void recognition(Map<String, List<dynamic>> data, List<dynamic> foundList, double threshold);

  double euclideanDistance(List e1, List e2);


}