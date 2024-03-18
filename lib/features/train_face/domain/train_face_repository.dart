

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

abstract class TrainFaceRepository{
 Future<void> getOutputList(String name, List trainings, Interpreter interpreter, String nameOfJsonFile);
 Future<TensorImage> getOutputList2(String name,List trainings, Interpreter interpreter,String nameOfJsonFile);
}