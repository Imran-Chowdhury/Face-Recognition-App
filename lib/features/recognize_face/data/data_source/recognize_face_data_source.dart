
abstract class RecognizeFaceDataSource{
  Future<Map<String, List<dynamic>>> readMapFromSharedPreferences(String nameOfJsonFile);
  // Future<Map<String, List<List<double>>>> readMapFromSharedPreferences(String nameOfJsonFile);
}
