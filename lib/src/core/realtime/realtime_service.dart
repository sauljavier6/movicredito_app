import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../config/app_config.dart';
import '../refresh/auto_refresh_state.dart';

/// A single authenticated connection for the current customer session.
/// The socket only signals changes; the existing authenticated REST API
/// remains the source of truth for messages and notification counts.
class RealtimeService {
  RealtimeService._();
  static final RealtimeService instance = RealtimeService._();

  io.Socket? _socket;
  String? _token;

  void connect(String token) {
    if (token.isEmpty) return;
    if (_token == token && _socket != null) return;
    disconnect();
    _token = token;

    final socket = io.io(
      AppConfig.apiUrl,
      io.OptionBuilder()
          .setPath('/socket.io')
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setAuth({'token': token})
          .build(),
    );

    socket.on('support:changed', (_) => DataRefreshBus.instance.invalidate());
    socket.on('notifications:changed', (_) => DataRefreshBus.instance.invalidate());
    socket.onConnect((_) => DataRefreshBus.instance.invalidate());
    socket.connect();
    _socket = socket;
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _token = null;
  }
}
