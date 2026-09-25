import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${AppConfig.apiUrl}$path');

  Future<Map<String, dynamic>> getJson(String path) async {
    final response = await _client.get(_uri(path));
    final body = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(body['message']?.toString() ?? 'No fue posible completar la solicitud.');
    }
    return body;
  }
}

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
