import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// High-level UI signal for connection / sync health (global SnackBar).
enum ConnectionSurface {
  normal,

  /// Device reports no usable network (best-effort).
  offlineDevice,

  /// Remote Firestore or local DB write failed during sync.
  syncDegraded,
}

class ConnectionSurfaceNotifier extends Notifier<ConnectionSurface> {
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  @override
  ConnectionSurface build() {
    final connectivity = Connectivity();

    Future.microtask(() async {
      try {
        final initial = await connectivity.checkConnectivity();
        _applyConnectivity(initial);
      } catch (_) {
        // Ignore; stream may still deliver later.
      }
    });

    _connSub = connectivity.onConnectivityChanged.listen(_applyConnectivity);
    ref.onDispose(() async {
      await _connSub?.cancel();
    });

    return ConnectionSurface.normal;
  }

  void _applyConnectivity(List<ConnectivityResult> results) {
    final hasPath = results.any(
      (r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.vpn,
    );
    final noneOnly =
        results.isEmpty ||
        (results.length == 1 && results.single == ConnectivityResult.none);

    if (noneOnly || !hasPath) {
      state = ConnectionSurface.offlineDevice;
    } else if (state == ConnectionSurface.offlineDevice) {
      state = ConnectionSurface.normal;
    }
  }

  void reportSyncFailure() {
    state = ConnectionSurface.syncDegraded;
  }

  void acknowledge() {
    state = ConnectionSurface.normal;
  }
}

final connectionSurfaceProvider =
    NotifierProvider<ConnectionSurfaceNotifier, ConnectionSurface>(
      ConnectionSurfaceNotifier.new,
    );

typedef SyncFailureReporter = void Function();
