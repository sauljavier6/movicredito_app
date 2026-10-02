import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'movicredito_customer_token';

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<String?> readToken() => _storage.read(key: _tokenKey);
  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  Future<Map<String, dynamic>> getJson(String path, {bool authenticated = false}) async {
    final response = await _client.get(Uri.parse('${AppConfig.apiUrl}$path'), headers: await _headers(authenticated));
    return _decode(response);
  }

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body, {bool authenticated = false}) async {
    final response = await _client.post(Uri.parse('${AppConfig.apiUrl}$path'), headers: await _headers(authenticated), body: jsonEncode(body));
    return _decode(response);
  }

  Future<Map<String, String>> _headers(bool authenticated) async {
    final headers = <String, String>{'Content-Type': 'application/json', 'Accept': 'application/json'};
    if (authenticated) {
      final token = await readToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> data = {};
    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        (data['message'] ?? 'No fue posible completar la solicitud.').toString(),
        statusCode: response.statusCode,
      );
    }
    return data;
  }
}
