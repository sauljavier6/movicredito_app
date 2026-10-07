import '../../core/api/api_client.dart';

class AuthService {
  AuthService({ApiClient? api}) : api = api ?? ApiClient();
  final ApiClient api;

  Future<Map<String, dynamic>> login(String login, String password) async {
    final data = await api.postJson('/api/customer-auth/login', {'login': login.trim(), 'password': password});
    final token = data['token'];
    if (token is String) await api.saveToken(token);
    return data;
  }

  Future<Map<String, dynamic>> startRegistration(String customerNumber, String contact) =>
      api.postJson('/api/customer-auth/register/start', {'customerNumber': customerNumber.trim(), 'contact': contact.trim()});

  Future<Map<String, dynamic>> completeRegistration(String challengeId, String code, String password) async {
    final data = await api.postJson('/api/customer-auth/register/complete', {'challengeId': challengeId, 'code': code.trim(), 'password': password});
    final token = data['token'];
    if (token is String) await api.saveToken(token);
    return data;
  }

  Future<Map<String, dynamic>> startReset(String login) =>
      api.postJson('/api/customer-auth/password/reset/start', {'login': login.trim()});

  Future<Map<String, dynamic>> me() => api.getJson('/api/customer-auth/me', authenticated: true);
  Future<Map<String, dynamic>> summary() => api.getJson('/api/customer-auth/summary', authenticated: true);
  Future<Map<String, dynamic>> credit() => api.getJson('/api/customer-auth/credit', authenticated: true);
  Future<Map<String, dynamic>> payments() => api.getJson('/api/customer-auth/payments', authenticated: true);
  Future<Map<String, dynamic>> documents() => api.getJson('/api/customer-auth/documents', authenticated: true);

  Future<bool> hasSession() async {
    final token = await api.readToken();
    if (token == null || token.isEmpty) return false;
    try {
      await me();
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) await api.clearToken();
      return false;
    } catch (_) {
      return true;
    }
  }

  Future<void> logout() => api.clearToken();
}
