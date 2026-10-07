import 'dart:async';

import 'package:flutter/material.dart';

mixin AutoRefreshState<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  Timer? _autoRefreshTimer;
  bool _autoRefreshRunning = false;

  Duration get autoRefreshInterval => const Duration(seconds: 15);

  Future<void> refreshData();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _autoRefreshTimer = Timer.periodic(autoRefreshInterval, (_) => _runAutoRefresh());
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _runAutoRefresh();
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
