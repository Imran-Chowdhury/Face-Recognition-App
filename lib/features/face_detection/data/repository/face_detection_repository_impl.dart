




import 'dart:io';


import 'package:face/features/face_detection/domain/repository/face_detection_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';


final faceDetectionRepositoryProvider = Provider((ref) => FaceDetectionRepositoryImpl() );



class FaceDetectionRepositoryImpl implements FaceDetectionRepository {



  @override
  Future<List> detectFaces(List<XFile> selectedImages, FaceDetector faceDetector)async {

    List<Face> detectedFace = [];


    try{



      for(int i = 0; i<selectedImages.length; i++){



        final inputImage = InputImage.fromFilePath(selectedImages[i].path);


        final List<Face> faces = await faceDetector.processImage(inputImage);



        if(faces.isEmpty){
          // implement the logic to remove the picture where no faces are detected
          return [];
          // print('No face detected');
        }else{
          //adding the first face found in the inputImage into a list
          detectedFace.add(faces[0]);
        }




      }
    }catch(e){
      rethrow;
    }



    return cropFace(selectedImages, detectedFace);
  }

  @override
  List cropFace(List<XFile> selectedImages, List<Face> face) {


    List croppedImageList = [];
    try{
      for(int i = 0; i<selectedImages.length;i++){

        final File file = File(selectedImages[i].path);
        img.Image decodedImg = img.decodeImage(file.readAsBytesSync())!;

        final int left = face[i].boundingBox.left.toInt();
        final int top = face[i].boundingBox.top.toInt();
        final int width = face[i].boundingBox.width.toInt();
        final int height = face[i].boundingBox.height.toInt();



        final img.Image croppedImg = img.copyCrop(decodedImg, left, top, width, height);
        // final img.Image  rotatedimage = img.copyRotate(croppedImg, rotZ as num );


        // final img.Image croppedImg = img.copyCrop(rotatedimage, left, top, width, height);


        croppedImageList.add(croppedImg);
        if(croppedImageList.isEmpty){
          return [];
        }

      }
    }catch(e) {rethrow;}

    // return resizedImageList;
    return croppedImageList;
  }



  @override
  // Future detectFacesFromLiveFeed(InputImage inputImage, img.Image image, FaceDetector faceDetector)async {
  Future detectFacesFromLiveFeed(List<InputImage> inputImage, List<img.Image> image,  FaceDetector faceDetector)async {

    final stopwatch = Stopwatch()..start();
    List<Face> detectedFaces = [];
    try{
      // final stopwatch = Stopwatch()..start();

      if(inputImage.isNotEmpty && image.isNotEmpty){
        for(int i=0; i<inputImage.length; i++){
          final List<Face> faces = await faceDetector.processImage(inputImage[i]);

          if(faces.isEmpty){
            // implement the logic to remove the picture where no faces are detected
            return [];
            print('No face detected');
            return [];
          }else{
            //adding the first face found in the inputImage into a list
            detectedFaces.add(faces[0]);

          }
        }
      }


    }catch(e){
      rethrow;
    }
    stopwatch.stop();
    final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
    print('Live Feed detection Time: $elapsedSeconds seconds');
//If wanted to detect and crop as much as faces possible then use cropFacesFromLiveFeed(image, faces)
//     return cropFacesFromLiveFeed(image, detectedFaces);
    return cropFacesFromLiveFeed(image, detectedFaces);


  }


  @override
  List cropFacesFromLiveFeed(List<img.Image> image, List<Face> faces) {

    List croppedImageList = [];
    try{
      final stopwatch = Stopwatch()..start();
      for(int i = 0; i<faces.length;i++){



        final int left = faces[i].boundingBox.left.toInt();
        final int top = faces[i].boundingBox.top.toInt();
        final int width = faces[i].boundingBox.width.toInt();
        final int height = faces[i].boundingBox.height.toInt();


        final img.Image croppedImg = img.copyCrop(image[i], left, top, width, height);
        // final img.Image resizedImage = img.copyResize(croppedImg, width: 112, height: 112);
        // resizedImageList.add(resizedImage);
        croppedImageList.add(croppedImg);
        if(croppedImageList.isEmpty){
          return [];
        }

        stopwatch.stop();
        final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
        print('Cropping Time: $elapsedSeconds seconds');
      }
    }catch(e) {rethrow;}

    // return resizedImageList;
    return croppedImageList;


  }






}



//
// Uint8List cropFace(XFile image, Face face) {
//   final File file = File(image.path);
//   final img.Image decodedImg = img.decodeImage(file.readAsBytesSync())!;
//
//   print('The Image width is ${decodedImg.width}');
//   print('The Image height is ${decodedImg.height}');
//
//
//   final int left = face.boundingBox.left.toInt();
//   final int top = face.boundingBox.top.toInt();
//   final int width = face.boundingBox.width.toInt();
//   final int height = face.boundingBox.height.toInt();
//   final int right = face.boundingBox.right.toInt();
//   final int bottom = face.boundingBox.bottom.toInt();

//   double l = left / decodedImg.width;
//   double t = top / decodedImg.height;
//   double r = right / decodedImg.width;
//   double b = bottom / decodedImg.height;
//
//   int w = right-left;
//   int h = bottom-top;
//   print('the calculated width is $w and the heioght is $h');
//
//
//
//   //  print('the left is $left');
//   //  print('the top is $top');
//   //   print('the right is $right');
//   //    print('the bottom is $bottom');
//   //  print('the width is $width');
//   //  print('the height is $height');
//   print('the l is $l');
//   print('the t is $t');
//   print('the r is $r');
//   print('the b is $b');
//
  // final img.Image croppedImg = img.copyCrop(decodedImg, left, top, width, height);
  // final img.Image croppedImg = img.copyCrop(decodedImg, left, top, width, height);
//   img.Image resizedImage = img.copyResize(croppedImg, width: 112, height: 112);
//   print('the cropped image width is ${croppedImg.width}');
//   print('the cropped image height is ${croppedImg.height}');
//   // print('the resized image width is ${resizedImage.width}');
//
//
//
//
//
//   // return Uint8List.fromList(img.encodeJpg(croppedImg));
//   return Uint8List.fromList(img.encodeJpg(resizedImage));
// }