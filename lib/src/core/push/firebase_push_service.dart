import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../api/api_client.dart';
import '../refresh/auto_refresh_state.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class FirebasePushService {
  FirebasePushService._();
  static final FirebasePushService instance = FirebasePushService._();

  bool _ready = false;
  bool _bound = false;
  String? _registeredToken;
  StreamSubscription<String>? _tokenSubscription;

  /// Firebase requires Android google-services.json and Gradle setup first.
  /// Until configured, the app continues working without push notifications.
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen((_) => DataRefreshBus.instance.invalidate());
      FirebaseMessaging.onMessageOpenedApp.listen((_) => DataRefreshBus.instance.invalidate());
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) DataRefreshBus.instance.invalidate();
      _tokenSubscription = FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        if (_bound) unawaited(_registerToken(token));
      });
      _ready = true;
    } catch (error) {
      // Firebase is optional in local development until configured.
      // Do not block login, support chat or credit payments.
      // ignore: avoid_print
      print('FCM no configurado: $error');
    }
  }

  Future<void> bindSession() async {
    if (!_ready) return;
    _bound = true;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _registerToken(token);
    } catch (error) {
      // ignore: avoid_print
      print('FCM registro pendiente: $error');
    }
  }

  Future<void> _registerToken(String token) async {
    if (!_bound || token.isEmpty || token == _registeredToken) return;
    try {
      await ApiClient().postJson(
        '/api/customer-auth/push-tokens',
        {'token': token, 'platform': 'android'},
        authenticated: true,
      );
      _registeredToken = token;
    } catch (error) {
      // ignore: avoid_print
      print('FCM no pudo registrar token en API: $error');
    }
  }

  Future<void> unbindSession() async {
    _bound = false;
    final token = _registeredToken;
    _registeredToken = null;
    if (!_ready) return;
    try {
      if (token != null) await ApiClient().deleteJsonWithBody(
        '/api/customer-auth/push-tokens',
        {'token': token},
        authenticated: true,
      );
    } catch (error) {
      // ignore: avoid_print
      print('FCM no pudo desvincular token: $error');
    } finally {
      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (_) {
        // No impedir el cierre de sesión si Firebase no está disponible.
      }
    }
  }
}
