import 'package:shared_preferences/shared_preferences.dart';



void spSet(String key,value) async{
  final prefs = await SharedPreferences.getInstance();
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is num) {
        await prefs.setInt(key, value.toInt());
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is List) {
        await prefs.setStringList(key, value.cast<String>());
      }

}

Future spget(String key, [dynamic replace]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(key);
    return data ?? replace;
  }

void spremove(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
}

void spremoveAll() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}