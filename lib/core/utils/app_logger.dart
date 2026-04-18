import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

import '../constants/app_settings.dart';

abstract final class AppLogger {
  static void info(String message, {String tag = 'log'}) {
    if (!AppSettings.enableLogging) {
      return;
    }
    if (AppSettings.usePrintForLogging) {
      debugPrint('[$tag] $message');
    } else {
      dev.log(message, name: tag);
    }
  }

  static void error(
    String message, {
    String tag = 'error',
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!AppSettings.enableLogging) {
      return;
    }
    if (AppSettings.usePrintForLogging) {
      debugPrint('[$tag] $message${error != null ? '\n$error' : ''}');
    } else {
      dev.log(message, name: tag, error: error, stackTrace: stackTrace);
    }
  }
}
