

import 'package:tflite_flutter/tflite_flutter.dart';


abstract class TrainFaceRepository{
 Future<void> getOutputList(String name, List trainings, Interpreter interpreter, String nameOfJsonFile);

}