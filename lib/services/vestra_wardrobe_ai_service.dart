import 'dart:convert';

import 'package:http/http.dart' as http;

class VestraWardrobeAIService {
  VestraWardrobeAIService._();

  // ============================================================
  // BACKEND
  // ============================================================

  static const String _baseUrl = String.fromEnvironment(
    'VESTRA_BACKEND_URL',
    defaultValue: 'http://localhost:3000',
  );

  // ============================================================
  // ANALYZE SINGLE CLOTHING PHOTO
  // ============================================================

  static Future<Map<String, String>> analyzeClothingPhoto({
    required String imageBase64,
  }) async {
    if (imageBase64.trim().isEmpty) {
      throw const VestraWardrobeAIException('No clothing photo was provided.');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/wardrobe/analyze'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'imageBase64': imageBase64}),
          )
          .timeout(const Duration(seconds: 60));

      // ========================================================
      // SERVER ERROR
      // ========================================================

      if (response.statusCode < 200 || response.statusCode >= 300) {
        String message = 'Vestra could not analyze this clothing photo.';

        try {
          final errorData = jsonDecode(response.body);

          if (errorData is Map && errorData['error'] != null) {
            message = errorData['error'].toString();
          }
        } catch (_) {
          // Keep default message.
        }

        throw VestraWardrobeAIException(
          '$message\n\nServer response: ${response.statusCode}',
        );
      }

      // ========================================================
      // DECODE RESPONSE
      // ========================================================

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw const VestraWardrobeAIException(
          'Vestra received an invalid recognition response.',
        );
      }

      if (decoded['success'] != true) {
        throw VestraWardrobeAIException(
          decoded['error']?.toString() ??
              'Vestra could not identify the clothing item.',
        );
      }

      final item = decoded['item'];

      if (item is! Map) {
        throw const VestraWardrobeAIException(
          'Vestra did not receive clothing information.',
        );
      }

      // ========================================================
      // NORMALIZE RESULT
      // ========================================================

      return {
        'name': _value(item['name'], fallback: 'Clothing item'),
        'category': _value(item['category'], fallback: 'Tops'),
        'color': _value(item['color']),
        'style': _value(item['style']),
        'fit': _value(item['fit']),
        'length': _value(item['length']),
        'material': _value(item['material']),
        'pattern': _value(item['pattern']),
        'notes': _value(item['notes']),
      };
    } on VestraWardrobeAIException {
      rethrow;
    } on http.ClientException catch (error) {
      throw VestraWardrobeAIException(
        'Vestra could not reach the backend.\n\n$error',
      );
    } catch (error) {
      throw VestraWardrobeAIException(
        'Something went wrong while analyzing the photo.\n\n$error',
      );
    }
  }

  // ============================================================
  // VALUE HELPER
  // ============================================================

  static String _value(dynamic value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }

    final text = value.toString().trim();

    return text.isEmpty ? fallback : text;
  }
}

// ================================================================
// EXCEPTION
// ================================================================

class VestraWardrobeAIException implements Exception {
  final String message;

  const VestraWardrobeAIException(this.message);

  @override
  String toString() => message;
}
