import '../../core/api/api_client.dart';
import '../../core/refresh/auto_refresh_state.dart';
import '../../core/realtime/realtime_service.dart';

class AuthService {
  AuthService({ApiClient? api}) : api = api ?? ApiClient();
  final ApiClient api;

  Future<Map<String, dynamic>> login(String login, String password) async {
    final data = await api.postJson('/api/customer-auth/login', {'login': login.trim(), 'password': password});
    final token = data['token'];
    if (token is String) {
      await api.saveToken(token);
      RealtimeService.instance.connect(token);
    }
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
  Future<Map<String, dynamic>> createPaymentCheckout() => api.postJson('/api/customer-auth/payment-checkout', {}, authenticated: true);
  Future<Map<String, dynamic>> syncPaymentCheckout(String id) async {
    final data = await api.postJson('/api/customer-auth/payment-checkout/$id/sync', {}, authenticated: true);
    DataRefreshBus.instance.invalidate();
    return data;
  }
  Future<Map<String, dynamic>> supportTickets() => api.getJson('/api/customer-auth/support', authenticated: true);
  Future<Map<String, dynamic>> createSupportTicket(String subject, String category, String message) async {
    final data = await api.postJson('/api/customer-auth/support', {'subject': subject, 'category': category, 'message': message}, authenticated: true);
    DataRefreshBus.instance.invalidate();
    return data;
  }
  Future<Map<String, dynamic>> supportMessages(String id) => api.getJson('/api/customer-auth/support/$id/messages', authenticated: true);
  Future<Map<String, dynamic>> replySupport(String id, String message) async {
    final data = await api.postJson('/api/customer-auth/support/$id/messages', {'message': message}, authenticated: true);
    DataRefreshBus.instance.invalidate();
    return data;
  }
  Future<Map<String, dynamic>> notifications() => api.getJson('/api/customer-auth/notifications', authenticated: true);
  Future<Map<String, dynamic>> readNotification(String id) async {
    final data = await api.patchJson('/api/customer-auth/notifications/$id/read', {}, authenticated: true);
    DataRefreshBus.instance.invalidate();
    return data;
  }
  Future<Map<String, dynamic>> dismissNotification(String id) async {
    final data = await api.deleteJson('/api/customer-auth/notifications/$id', authenticated: true);
    DataRefreshBus.instance.invalidate();
    return data;
  }
  Future<Map<String, dynamic>> reminders() => api.getJson('/api/customer-auth/reminders', authenticated: true);
  Future<Map<String, dynamic>> setReminder(String installmentId, int daysBefore) async {
    final data = await api.postJson('/api/customer-auth/reminders', {'installmentId': installmentId, 'daysBefore': daysBefore}, authenticated: true);
    DataRefreshBus.instance.invalidate();
    return data;
  }

  Future<bool> hasSession() async {
    final token = await api.readToken();
    if (token == null || token.isEmpty) return false;
    try {
      await me();
      RealtimeService.instance.connect(token);
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) await logout();
      return false;
    } catch (_) {
      RealtimeService.instance.connect(token);
      return true;
    }
  }

  Future<void> logout() async {
    RealtimeService.instance.disconnect();
    await api.clearToken();
  }
}
