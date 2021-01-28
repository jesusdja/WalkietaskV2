import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefe{

  SharedPreferences prefs;

  Future<void> setIntValue(String key,int value) async{
    prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }
  Future<void> setStringValue(String key,String value) async{
    prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }
  Future<void> setStringListValue(String key,List<String> value) async{
    prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, value);
  }

  Future<void> setBoolValue(String key,bool value) async{
    prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  Future<dynamic> getValue(String key) async{
    prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  Future<void> deleteValue(String key) async{
    prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}