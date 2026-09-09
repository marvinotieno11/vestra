import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class WardrobeStore {
  static final List<Map<String, String>> items = [];

  static const String _wardrobeKey = 'user_wardrobe';

  // ================================================================
  // LOAD
  // ================================================================

  static Future<void> loadItems() async {
    final prefs = await SharedPreferences.getInstance();

    final savedData = prefs.getString(_wardrobeKey);

    items.clear();

    if (savedData == null || savedData.isEmpty) {
      return;
    }

    try {
      final List<dynamic> decoded = jsonDecode(savedData);

      items.addAll(decoded.map((item) => Map<String, String>.from(item)));
    } catch (_) {
      // If old/corrupted data cannot be decoded,
      // start with an empty wardrobe instead of crashing.
      items.clear();
    }
  }

  // ================================================================
  // ADD
  // ================================================================

  static Future<void> addItem(Map<String, String> item) async {
    final prefs = await SharedPreferences.getInstance();

    items.add(Map<String, String>.from(item));

    await _save(prefs);
  }

  // ================================================================
  // REMOVE
  // ================================================================

  static Future<void> removeItem(Map<String, String> item) async {
    final prefs = await SharedPreferences.getInstance();

    items.remove(item);

    await _save(prefs);
  }

  // ================================================================
  // CLEAR
  // ================================================================

  static Future<void> clearWardrobe() async {
    final prefs = await SharedPreferences.getInstance();

    items.clear();

    await prefs.remove(_wardrobeKey);
  }

  // ================================================================
  // SAVE
  // ================================================================

  static Future<void> _save(SharedPreferences prefs) async {
    await prefs.setString(_wardrobeKey, jsonEncode(items));
  }
}
