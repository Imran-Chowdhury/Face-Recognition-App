



import 'package:face/features/recognize_face/domain/repository/recognize_face_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../data/repository/recognize_face_repository_impl.dart';

final recognizeFaceUseCaseProvider = Provider((ref) => RecognizeFaceUseCase(repository: ref.read(recognizeFaceRepositoryProvider)));



class RecognizeFaceUseCase{
  RecognizeFaceUseCase({required this.repository});

  RecognizeFaceRepository repository;

  Future<void> recognizeFace (img.Image image,Interpreter interpreter)async{

    await repository.recognizeFace(image, interpreter);


  }


}