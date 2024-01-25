


import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'train_face_data_source.dart';

final trainFaceDataSourceProvider = Provider((ref) => TrainFaceDataSourceImpl());
class TrainFaceDataSourceImpl implements TrainFaceDataSource{



  @override
  saveOrUpdateJsonInSharedPreferences(String key, listOfOutputs) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the JSON file exists in SharedPreferences
    String? existingJsonString = prefs.getString('testMap');

    if (existingJsonString == null) {
      // If the JSON file doesn't exist, create a new one with the provided key and value
      Map<String, dynamic> newJsonData = {key: listOfOutputs};
      await prefs.setString('testMap', jsonEncode(newJsonData));
    } else {
      // If the JSON file exists, update it
      Map<String, dynamic> existingJson =
      json.decode(existingJsonString) as Map<String, dynamic>;

      // Check if the key already exists in the JSON
      if (existingJson.containsKey(key)) {
        // If the key exists, update its value
        existingJson[key] = listOfOutputs;
      } else {
        // If the key doesn't exist, add a new key-value pair
        existingJson[key] = listOfOutputs;
      }

      // Save the updated JSON back to SharedPreferences
      await prefs.setString('testMap', jsonEncode(existingJson));
      dynamic printMap = await readMapFromSharedPreferences();
      print(printMap);
    }
  }
  @override
  Future<Map<String, List<dynamic>>> readMapFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = prefs.getString('testMap');
    if (jsonMap != null) {
      final decodedMap = Map<String, List<dynamic>>.from(json.decode(jsonMap));
      // final resultMap = decodedMap.map((key, value) {
      //   return MapEntry(
      //     key,
      //     value.map((str) => str.split(',').map(int.parse).toList()).toList(),
      //   );
      // });
      // return resultMap;
      return decodedMap;
    } else {
      return {};
    }
  }


}

