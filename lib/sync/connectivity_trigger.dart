import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ramp_check/sync/sync_service.dart';

class ConnectivityTrigger {
  ConnectivityTrigger(this._syncService);

  final SyncService _syncService;
  StreamSubscription? _sub;

  void start() {
    _sub = Connectivity().onConnectivityChanged.listen((results) async {
      final connected = results.any((r) => r != ConnectivityResult.none);
      if (connected) {
        await _syncService.runSync();
      }
    });
  }

  Future<void> stop() async {
    await _sub?.cancel();
  }
}
