import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EventsStore {
  static final List<Map<String, dynamic>> events = [];

  static const String _eventsKey = 'vestra_events';

  static Future<void> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();

    final savedData = prefs.getString(_eventsKey);

    events.clear();

    if (savedData == null || savedData.isEmpty) {
      return;
    }

    final List<dynamic> decoded = jsonDecode(savedData);

    events.addAll(
      decoded.map(
        (event) => {
          'title': event['title']?.toString() ?? 'Untitled Event',
          'date': event['date']?.toString() ?? '',
          'time': event['time']?.toString() ?? '',
          'occasion': event['occasion']?.toString() ?? 'Other',
          'dressCode': event['dressCode']?.toString() ?? 'Not specified',
          'location': event['location']?.toString() ?? '',
        },
      ),
    );
  }

  static Future<void> addEvent({
    required String title,
    required DateTime date,
    required String time,
    required String occasion,
    required String dressCode,
    String location = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();

    events.add({
      'title': title.trim(),
      'date': date.toIso8601String(),
      'time': time,
      'occasion': occasion,
      'dressCode': dressCode,
      'location': location.trim(),
    });

    _sortEvents();

    await _save(prefs);
  }

  static Future<void> removeEvent(int index) async {
    if (index < 0 || index >= events.length) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    events.removeAt(index);

    await _save(prefs);
  }

  static void _sortEvents() {
    events.sort((a, b) {
      final dateA = DateTime.tryParse(a['date']?.toString() ?? '');
      final dateB = DateTime.tryParse(b['date']?.toString() ?? '');

      if (dateA == null && dateB == null) {
        return 0;
      }

      if (dateA == null) {
        return 1;
      }

      if (dateB == null) {
        return -1;
      }

      return dateA.compareTo(dateB);
    });
  }

  static Future<void> _save(SharedPreferences prefs) async {
    await prefs.setString(_eventsKey, jsonEncode(events));
  }

  static Future<void> clearEvents() async {
    final prefs = await SharedPreferences.getInstance();

    events.clear();

    await prefs.remove(_eventsKey);
  }
}
