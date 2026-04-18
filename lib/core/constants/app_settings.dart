// ignore_for_file: dead_code

import 'package:flutter/foundation.dart';

abstract final class AppSettings {
  // ─── App ──────────────────────────────────────────────────────────────────
  static const String appName = 'Flutter';
  static const bool isProduction = kReleaseMode;
  static const bool isDevicePreviewActive = false && !isProduction;

  // ─── Logging — master switch ───────────────────────────────────────────────
  static const bool enableLogging = true && !isProduction;

  // ─── Logging — per channel (change true→false to disable individually) ────
  static const bool enableRequestLogger = true && enableLogging;
  static const bool enableResponseLogger = true && enableLogging;
  static const bool enableErrorLogger = true && enableLogging;
  static const bool enableRouteLogger = true && enableLogging;
  static const bool enableBlocObserverLogger = true && enableLogging;

  // ─── Logging — output ─────────────────────────────────────────────────────
  static const bool usePrintForLogging = false;
  static const int maxLogStringLength = 60;
  static const int maxListItems = 5;
}
