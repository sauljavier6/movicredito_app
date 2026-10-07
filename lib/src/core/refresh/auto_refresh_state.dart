import 'dart:async';

import 'package:flutter/material.dart';

class DataRefreshBus {
  DataRefreshBus._();
  static final DataRefreshBus instance = DataRefreshBus._();

  final StreamController<void> _controller = StreamController<void>.broadcast();

  Stream<void> get changes => _controller.stream;

  void invalidate() => _controller.add(null);
}

mixin AutoRefreshState<T extends StatefulWidget> on State<T> {
  Timer? _autoRefreshTimer;
  StreamSubscription<void>? _refreshSubscription;
  AppLifecycleListener? _lifecycleListener;
  bool _autoRefreshRunning = false;

  Duration get autoRefreshInterval => const Duration(seconds: 15);

  Future<void> refreshData();

  @override
  void initState() {
    super.initState();

    _refreshSubscription =
        DataRefreshBus.instance.changes.listen((_) => _runAutoRefresh());

    _autoRefreshTimer =
        Timer.periodic(autoRefreshInterval, (_) => _runAutoRefresh());

    _lifecycleListener = AppLifecycleListener(
      onResume: () => _runAutoRefresh(),
    );
  }

  Future<void> _runAutoRefresh() async {
    if (!mounted || _autoRefreshRunning) return;

    _autoRefreshRunning = true;
    try {
      await refreshData();
    } finally {
      _autoRefreshRunning = false;
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _refreshSubscription?.cancel();
    _lifecycleListener?.dispose();
    super.dispose();
  }
}
