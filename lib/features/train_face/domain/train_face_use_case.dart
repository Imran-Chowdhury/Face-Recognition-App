


import 'package:face/features/train_face/domain/train_face_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../data/repository/train_face_repository_impl.dart';

final trainFaceUseCaseProvider = Provider((ref) {
  return TrainFaceUseCase(repository: ref.read(trainFaceRepositoryProvider));
});


class TrainFaceUseCase{
  TrainFaceUseCase({required this.repository});
  TrainFaceRepository repository;

  Future<void> getImagesList(String name, List trainings,Interpreter interpreter,String nameOfJsonFile)async {
    try {
      await repository.getOutputList(name, trainings, interpreter, nameOfJsonFile);
      // await repository.getOutputList2(name, trainings, interpreter, nameOfJsonFile);
    }catch(e){
      rethrow;
    }
  }

}

