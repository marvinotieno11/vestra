import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StylePreferencesStore {
  static final Set<String> selectedStyles = {};
  static final Set<String> selectedFits = {};
  static final Set<String> selectedColors = {};

  static const String _stylesKey = 'style_preferences_styles';
  static const String _fitsKey = 'style_preferences_fits';
  static const String _colorsKey = 'style_preferences_colors';

  static Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    selectedStyles
      ..clear()
      ..addAll(_decodeList(prefs.getString(_stylesKey)));

    selectedFits
      ..clear()
      ..addAll(_decodeList(prefs.getString(_fitsKey)));

    selectedColors
      ..clear()
      ..addAll(_decodeList(prefs.getString(_colorsKey)));
  }

  static List<String> _decodeList(String? data) {
    if (data == null || data.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(data);

      if (decoded is List) {
        return decoded.map((item) => item.toString()).toList();
      }
    } catch (_) {
      return [];
    }

    return [];
  }

  static Future<void> savePreferences({
    required Set<String> styles,
    required Set<String> fits,
    required Set<String> colors,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    selectedStyles
      ..clear()
      ..addAll(styles);

    selectedFits
      ..clear()
      ..addAll(fits);

    selectedColors
      ..clear()
      ..addAll(colors);

    await prefs.setString(_stylesKey, jsonEncode(selectedStyles.toList()));

    await prefs.setString(_fitsKey, jsonEncode(selectedFits.toList()));

    await prefs.setString(_colorsKey, jsonEncode(selectedColors.toList()));
  }

  static Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    selectedStyles.clear();
    selectedFits.clear();
    selectedColors.clear();

    await prefs.remove(_stylesKey);
    await prefs.remove(_fitsKey);
    await prefs.remove(_colorsKey);
  }
}
