


abstract class TrainFaceDataSource{


  saveOrUpdateJsonInSharedPreferences(String key, dynamic listOfOutputs);
  Future<Map<String, List<dynamic>>> readMapFromSharedPreferences();
}


