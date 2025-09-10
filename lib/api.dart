import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class Api {
  // Backend URL can be overridden at build/run time with:
  // flutter run --dart-define=RSI_BACKEND_URL=http://192.168.1.23:8000
  // Otherwise it defaults to production Render backend.

  static const String baseUrl = String.fromEnvironment(
    'RSI_BACKEND_URL',
    defaultValue: 'https://rsipulse-backend.onrender.com',
  );

  static Future<ScanResponse> scan({required String mode, int test = 0}) async {
    final uri = Uri.parse('$baseUrl/scan').replace(queryParameters: {
      'mode': mode,
      if (test == 1) 'test': '1',
    });
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final jsonMap = json.decode(res.body) as Map<String, dynamic>;
    return ScanResponse.fromJson(jsonMap);
  }
}