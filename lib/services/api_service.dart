import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/session_result.dart';

class ApiService {
  // ── Replace with your Railway URL after deployment ──────────
  static const String baseUrl = 'https://web-production-7fe2b.up.railway.app';

  // ─────────────────────────────────────────────────────────
  // Upload CSV and get prediction results
  // ─────────────────────────────────────────────────────────
  static Future<SessionResult> predict(File csvFile) async {
    final uri = Uri.parse('$baseUrl/predict');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        csvFile.path,
        contentType: MediaType('text', 'csv'),
      ));

    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return SessionResult.fromJson(json);
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['detail'] ?? 'Prediction failed');
    }
  }

  // ─────────────────────────────────────────────────────────
  // Ask a question about the session results
  // Stateless — no history sent or stored
  // ─────────────────────────────────────────────────────────
  static Future<String> ask(String question, SessionResult result) async {
    final uri = Uri.parse('$baseUrl/ask');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'question':       question,
        'session_result': result.toJson(),
      }),
    ).timeout(const Duration(seconds: 45));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['answer'] as String;
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['detail'] ?? 'Failed to get answer');
    }
  }

  // ─────────────────────────────────────────────────────────
  // Health check
  // ─────────────────────────────────────────────────────────
  static Future<bool> healthCheck() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
