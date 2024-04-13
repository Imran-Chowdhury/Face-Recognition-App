

import 'dart:convert';

import 'package:face/features/recognize_face/data/data_source/recognize_face_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final recognizeFaceDataSourceProvider = Provider((ref) => RecognizeFaceDataSourceImpl());

class RecognizeFaceDataSourceImpl implements RecognizeFaceDataSource{


  @override
  Future<Map<String, List<dynamic>>> readMapFromSharedPreferences(String nameOfJsonFile) async {
  // Future<Map<String, List<List<double>>>> readMapFromSharedPreferences(String nameOfJsonFile) async {
    final prefs = await SharedPreferences.getInstance();
    // final jsonMap = prefs.getString('testMap');
    // final jsonMap = prefs.getString('liveTraining');
    final jsonMap = prefs.getString(nameOfJsonFile);
    if (jsonMap != null) {
      final decodedMap = Map<String, List<dynamic>>.from(json.decode(jsonMap));
      // final decodedMap = Map<String, List<List<double>>>.from(json.decode(jsonMap));


      // final resultMap = decodedMap.map((key, value) {
      //   // Convert each value from List<dynamic> to List<double>
      //   return MapEntry(key, value.cast<double>());
      // });
      print('Reading $nameOfJsonFile file for recognition(printed from recognize_face_datasource_impl)');
      print(decodedMap);
      return decodedMap;
    } else {
      return {};
    }
  }


}


