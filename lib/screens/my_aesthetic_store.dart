import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MyAestheticStore {
  static final Set<String> selectedAesthetics = {};

  static const String _aestheticsKey = 'my_aesthetics';

  static Future<void> loadAesthetics() async {
    final prefs = await SharedPreferences.getInstance();

    final savedData = prefs.getString(_aestheticsKey);

    selectedAesthetics.clear();

    if (savedData == null || savedData.isEmpty) {
      return;
    }

    final List<dynamic> decoded = jsonDecode(savedData);

    selectedAesthetics.addAll(decoded.cast<String>());
  }

  static Future<void> saveAesthetics(Set<String> aesthetics) async {
    final prefs = await SharedPreferences.getInstance();

    selectedAesthetics
      ..clear()
      ..addAll(aesthetics);

    await prefs.setString(
      _aestheticsKey,
      jsonEncode(selectedAesthetics.toList()),
    );
  }

  static Future<void> clearAesthetics() async {
    final prefs = await SharedPreferences.getInstance();

    selectedAesthetics.clear();

    await prefs.remove(_aestheticsKey);
  }
}
