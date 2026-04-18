import 'dart:io';

import 'package:flutter/services.dart';

import '../utils/app_logger.dart';

abstract final class SdkVersion {
  static const _channel = MethodChannel('flutter_genesis/device_info');

  /// Returns the Android SDK version (e.g. 33 for Android 13).
  /// Returns -1 on non-Android platforms or on error.
  static Future<int> get() async {
    if (!Platform.isAndroid) {
      return -1;
    }
    try {
      final version = await _channel.invokeMethod<int>('getSdkVersion');
      return version ?? -1;
    } catch (e) {
      AppLogger.error('SdkVersion.get failed', tag: 'SdkVersion', error: e);
      return -1;
    }
  }
}
