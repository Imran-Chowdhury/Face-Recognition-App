
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';


abstract class RecognizeFaceRepository{


  // Future<void> recognizeFace(img.Image image, Interpreter interpreter);

  // void recognition(Map<String, List<dynamic>> data, List<dynamic> foundList, double threshold);

  double euclideanDistance(List e1, List e2);

  Future<String> recognizeFace(img.Image image, Interpreter interpreter, String nameOfJsonFile);

  String recognition(Map<String, List<dynamic>> data, List<dynamic> foundList, double threshold);
  // String recognition(Map<String, List<List<double>>> data, List<double> foundList, double threshold);

  double cosineSimilarity(List<double> vectorA, List<double> vectorB);


}