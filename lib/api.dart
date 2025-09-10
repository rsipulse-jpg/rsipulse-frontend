// lib/api.dart
import 'dart:convert';
import 'dart:io';
import 'models/candidate.dart';

/// Uses --dart-define BACKEND_BASE_URL (HTTPS required on iOS)
/// flutter run --dart-define=BACKEND_BASE_URL=https://rsipulse-backend.onrender.com
class ApiClient {
  final String baseUrl;
  ApiClient({String? base})
      : baseUrl = base ??
            const String.fromEnvironment(
              'BACKEND_BASE_URL',
              defaultValue: 'https://rsipulse-backend.onrender.com',
            );

  Future<List<Candidate>> scan({required bool demo}) async {
    final uri = Uri.parse('$baseUrl/scan${demo ? '?test=1' : ''}');
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);

    try {
      final req = await client.getUrl(uri);
      final res = await req.close();
      final text = await res.transform(utf8.decoder).join();

      if (res.statusCode != 200) {
        try {
          final err = jsonDecode(text);
          if (err is Map && err['detail'] != null) {
            throw HttpException('HTTP ${res.statusCode}: ${err['detail']}');
          }
        } catch (_) {}
        throw HttpException('HTTP ${res.statusCode}: $text');
      }

      final decoded = _safeJson(text);
      final list = _extractList(decoded);
      if (list == null) {
        final preview = text.length > 240 ? '${text.substring(0, 240)}…' : text;
        throw FormatException('Unexpected response shape (preview): $preview');
      }

      return list.map((e) => Candidate.flex(e)).toList();
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Parse error: ${e.message}');
    } finally {
      client.close(force: true);
    }
  }

  dynamic _safeJson(String text) {
    try {
      return jsonDecode(text);
    } catch (_) {
      return text;
    }
  }

  List<dynamic>? _extractList(dynamic root) {
    if (root is List) return root;

    if (root is Map) {
      for (final k in const ['data', 'results', 'candidates', 'items', 'pairs', 'tickers']) {
        final v = root[k];
        if (v is List) return v;
      }
      final data = root['data'];
      if (data is Map) {
        for (final k in const ['items', 'results', 'candidates', 'list']) {
          final v = data[k];
          if (v is List) return v;
        }
      }
      for (final v in root.values) {
        if (v is List) return v;
        if (v is Map) {
          for (final vv in v.values) {
            if (vv is List) return vv;
          }
        }
      }
    }
    return null;
  }
}
