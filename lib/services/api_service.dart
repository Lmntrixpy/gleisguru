import 'dart:convert';
import 'package:gleisguru/models/api.dart';
import 'package:gleisguru/services/settings.dart';
import 'package:http/http.dart' as http;


class ApiService {
  Future<ApiData> getData() async {
    final baseUrl = await SettingsService.getBaseUrl();
    final url = Uri.parse('$baseUrl/data');

    final response = await http.get(url).timeout(const Duration(seconds: 1));

    if (response.statusCode != 200) {
      throw Exception('Fehler beim Laden der Daten: ${response.statusCode}');
    }

    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
    return ApiData.fromJson(jsonData);
  }

  Future<void> resetValue(String key) async {
    final baseUrl = await SettingsService.getBaseUrl();
    final url = Uri.parse('$baseUrl/command');

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'reset_$key': true}),
        )
        .timeout(const Duration(seconds: 1));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Reset fehlgeschlagen');
    }
  }

  Future<void> resetAll() async {
    final baseUrl = await SettingsService.getBaseUrl();
    final url = Uri.parse('$baseUrl/command');

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'reset_v_max': true,
            'reset_v_average': true,
            'reset_distance': true,
          }),
        )
        .timeout(const Duration(seconds: 1));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Reset All fehlgeschlagen');
    }
  }
}