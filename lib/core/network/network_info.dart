import 'package:connectivity_plus/connectivity_plus.dart';

// ── Abstract contract ─────────────────────────────────────────────────────────

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

// ── Implementation ────────────────────────────────────────────────────────────

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  const NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any(
      (result) => result != ConnectivityResult.none,
    );
  }
}
