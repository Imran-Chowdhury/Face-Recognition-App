


abstract class TrainFaceDataSource{


  saveOrUpdateJsonInSharedPreferences(String key, dynamic listOfOutputs, String nameOfJsonFile);
  Future<Map<String, List<dynamic>>> readMapFromSharedPreferences(String nameOfJsonFile);
}


