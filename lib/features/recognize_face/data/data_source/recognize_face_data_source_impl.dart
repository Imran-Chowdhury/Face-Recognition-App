

import 'dart:convert';

import 'package:face/features/recognize_face/data/data_source/recognize_face_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final recognizeFaceDataSourceProvider = Provider((ref) => RecognizeFaceDataSourceImpl());

class RecognizeFaceDataSourceImpl implements RecognizeFaceDataSource{


  @override
  Future<Map<String, List<dynamic>>> readMapFromSharedPreferences(String nameOfJsonFile) async {
    final prefs = await SharedPreferences.getInstance();
    // final jsonMap = prefs.getString('testMap');
    // final jsonMap = prefs.getString('liveTraining');
    final jsonMap = prefs.getString(nameOfJsonFile);
    if (jsonMap != null) {
      final decodedMap = Map<String, List<dynamic>>.from(json.decode(jsonMap));
      print('Reading $nameOfJsonFile file for recognition(printed from recognize_face_datasource_impl)');
      return decodedMap;
    } else {
      return {};
    }
  }


}


