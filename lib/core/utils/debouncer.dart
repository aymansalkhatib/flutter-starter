import 'dart:async';

import 'package:flutter/foundation.dart';

/// Delays execution of an action until [duration] has passed without a new call.
///
/// Usage:
/// ```dart
/// final _debouncer = Debouncer(duration: const Duration(milliseconds: 500));
///
/// void onSearchChanged(String query) {
///   _debouncer(() => search(query));
/// }
///
/// @override
/// void dispose() {
///   _debouncer.dispose();
///   super.dispose();
/// }
/// ```
class Debouncer {
  Debouncer({this.duration = const Duration(milliseconds: 500)});

  final Duration duration;

  Timer? _timer;

  bool get isActive => _timer?.isActive ?? false;

  /// Schedules [action] after [duration]. Cancels any pending call.
  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancels any pending call.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Cancels any pending call and releases resources.
  void dispose() => cancel();
}
