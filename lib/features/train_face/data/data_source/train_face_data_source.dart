


abstract class TrainFaceDataSource{


  Future<void> saveOrUpdateJsonInSharedPreferences(String key, dynamic listOfOutputs, String nameOfJsonFile);
  Future<Map<String, List<dynamic>>> readMapFromSharedPreferencesFromTrainDataSource(String nameOfJsonFile);
}


