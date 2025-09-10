import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class Api {
  static const String baseUrl = 'https://rsipulse-backend.onrender.com';

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