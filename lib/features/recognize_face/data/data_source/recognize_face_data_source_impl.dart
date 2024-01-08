

import 'dart:convert';

import 'package:face/features/recognize_face/data/data_source/recognize_face_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final recognizeFaceDataSourceProvider = Provider((ref) => RecognizeFaceDataSourceImpl());

class RecognizeFaceDataSourceImpl implements RecognizeFaceDataSource{


  @override
  Future<Map<String, List<dynamic>>> readMapFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = prefs.getString('testMap');
    if (jsonMap != null) {
      final decodedMap = Map<String, List<dynamic>>.from(json.decode(jsonMap));
      return decodedMap;
    } else {
      return {};
    }
  }


}


