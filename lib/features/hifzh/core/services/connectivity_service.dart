import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Exposes a [Stream<bool>] of internet connectivity and a synchronous getter.
///
/// Used by the Shell scaffold to show/hide the [OfflineBanner] and by
/// repositories to choose between remote and local data sources.
class HifzhConnectivityService {
  HifzhConnectivityService(this._connectivity) {
    // Retrieve initial connectivity state synchronously on startup
    _connectivity.checkConnectivity().then((results) {
      _isConnectedSync = _isOnline(results);
    });

    // Keep the cached state updated reactively
    _sub = _connectivity.onConnectivityChanged.listen((results) {
      _isConnectedSync = _isOnline(results);
    });
  }

  final Connectivity _connectivity;
  bool _isConnectedSync = true; // Safe default until checked
  StreamSubscription<List<ConnectivityResult>>? _sub;

  void dispose() {
    _sub?.cancel();
  }

  /// Synchronous getter to check if internet is available instantly.
  bool get isConnectedSync => _isConnectedSync;

  /// Stream that emits [true] when online, [false] when offline.
  Stream<bool> get isConnected =>
      _connectivity.onConnectivityChanged.map((results) => _isOnline(results));

  /// One-shot check for current connectivity.
  Future<bool> get currentlyConnected async {
    final results = await _connectivity.checkConnectivity();
    return _isOnline(results);
  }

  static bool _isOnline(List<ConnectivityResult> results) => results.any(
    (r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet,
  );
}
