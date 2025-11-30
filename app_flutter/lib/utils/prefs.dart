import 'package:shared_preferences/shared_preferences.dart';

class Prefs {

  // -------- GUARDAR USER ID --------
  static Future<void> saveUserId(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("user_id", id);
  }

  // -------- OBTENER USER ID --------
  static Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("user_id");
  }

  // -------- BORRAR TODO (LOGOUT) --------
  static Future<void> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}