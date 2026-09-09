import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OutfitStore {
  static final List<Map<String, dynamic>> savedOutfits = [];

  static const String _savedOutfitsKey = 'saved_outfits';

  // ============================================================
  // LOAD
  // ============================================================

  static Future<void> loadOutfits() async {
    final prefs = await SharedPreferences.getInstance();

    final savedData = prefs.getString(_savedOutfitsKey);

    savedOutfits.clear();

    if (savedData == null || savedData.isEmpty) {
      return;
    }

    final List<dynamic> decoded = jsonDecode(savedData);

    savedOutfits.addAll(
      decoded.map((outfit) {
        return {
          'occasion': outfit['occasion']?.toString() ?? 'Personal Look',

          'outfitName': outfit['outfitName']?.toString() ?? 'Saved Look',

          'description': outfit['description']?.toString() ?? '',

          'reasoning': outfit['reasoning']?.toString() ?? '',

          'items': List<Map<String, String>>.from(
            (outfit['items'] ?? []).map((item) {
              return Map<String, String>.from(item);
            }),
          ),
        };
      }),
    );
  }

  // ============================================================
  // ADD COMPLETE OUTFIT
  // ============================================================

  static Future<void> addOutfit({
    required String occasion,
    required String outfitName,
    required String description,
    required String reasoning,
    required List<Map<String, String>> items,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    savedOutfits.add({
      'occasion': occasion,
      'outfitName': outfitName,
      'description': description,
      'reasoning': reasoning,
      'items': List<Map<String, String>>.from(items),
    });

    await _save(prefs);
  }

  // ============================================================
  // REMOVE
  // ============================================================

  static Future<void> removeOutfit(int index) async {
    if (index < 0 || index >= savedOutfits.length) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    savedOutfits.removeAt(index);

    await _save(prefs);
  }

  // ============================================================
  // SAVE
  // ============================================================

  static Future<void> _save(SharedPreferences prefs) async {
    await prefs.setString(_savedOutfitsKey, jsonEncode(savedOutfits));
  }

  // ============================================================
  // CLEAR
  // ============================================================

  static Future<void> clearOutfits() async {
    final prefs = await SharedPreferences.getInstance();

    savedOutfits.clear();

    await prefs.remove(_savedOutfitsKey);
  }
}
