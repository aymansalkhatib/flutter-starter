import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Monitors device network connectivity.
///
/// Usage:
/// ```dart
/// final isOnline = await NetworkMonitor().isOnline;
///
/// NetworkMonitor().statusStream.listen((online) {
///   print(online ? 'Connected' : 'Disconnected');
/// });
/// ```
class NetworkMonitor {
  factory NetworkMonitor() => _instance;
  NetworkMonitor._internal();
  static final NetworkMonitor _instance = NetworkMonitor._internal();

  final Connectivity _connectivity = Connectivity();

  StreamController<bool>? _statusController;

  /// Broadcast stream of connectivity changes (`true` = online).
  ///
  /// Lazily initialized on first access.
  Stream<bool> get statusStream {
    if (_statusController == null) {
      _statusController = StreamController<bool>.broadcast();
      _connectivity.checkConnectivity().then(_update);
      _connectivity.onConnectivityChanged.listen(_update);
    }
    return _statusController!.stream;
  }

  /// Returns `true` if the device currently has a network connection.
  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  bool _isConnected(List<ConnectivityResult> results) => results.any(
        (r) => r != ConnectivityResult.none && r != ConnectivityResult.other,
      );

  void _update(List<ConnectivityResult> results) {
    _statusController?.add(_isConnected(results));
  }

  void dispose() {
    _statusController?.close();
    _statusController = null;
  }
}
