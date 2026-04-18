import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

import 'sdk_version.dart';

abstract final class StoragePermission {
  /// Requests storage permission appropriate for the Android SDK version.
  ///
  /// - Android 13+ (API 33+): requests [Permission.manageExternalStorage]
  /// - Android < 13          : requests [Permission.storage]
  /// - Non-Android           : returns true (no permission needed)
  ///
  /// Opens app settings automatically if permanently denied.
  static Future<bool> request() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final permission = await _isAndroid13OrAbove()
        ? Permission.manageExternalStorage
        : Permission.storage;

    final status = await permission.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }

  static Future<bool> _isAndroid13OrAbove() async {
    final sdk = await SdkVersion.get();
    return sdk >= 33;
  }
}
