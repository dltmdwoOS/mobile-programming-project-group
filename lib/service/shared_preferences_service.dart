import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefUtil {
  static Future<List<String>> getPlanNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPlanNames = prefs.getString('planNames');
    if (savedPlanNames != null) {
      return List<String>.from(json.decode(savedPlanNames));
    }
    return [];
  }

  static Future<void> savePlanNames(List<String> planNames) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('planNames', json.encode(planNames));
  }
}
