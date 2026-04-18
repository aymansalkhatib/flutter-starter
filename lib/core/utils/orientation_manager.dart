import 'package:flutter/services.dart';

abstract final class OrientationManager {
  /// Locks the app to portrait (up and down).
  static Future<void> allowOnlyPortrait() =>
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

  /// Locks the app to landscape (left and right).
  static Future<void> allowOnlyLandscape() =>
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

  /// Removes all orientation restrictions.
  static Future<void> allowAll() =>
      SystemChrome.setPreferredOrientations([]);
}
