import 'app_settings.dart';

/// Environment-specific URLs.
///
/// Environment is derived automatically from [AppSettings.isProduction]
/// (which maps to [kReleaseMode]) — no manual flag needed.
abstract final class EnvironmentConfig {
  // ─── API ──────────────────────────────────────────────────────────────────
  static const String _devApiBaseUrl = 'https://fakestoreapi.com';
  static const String _prodApiBaseUrl = 'https://fakestoreapi.com';

  // ─── Assets ───────────────────────────────────────────────────────────────
  static const String _devAssetBaseUrl = 'https://fakestoreapi.com';
  static const String _prodAssetBaseUrl = 'https://fakestoreapi.com';

  // ─── Resolved URLs ────────────────────────────────────────────────────────
  static String get apiBaseUrl =>
      AppSettings.isProduction ? _prodApiBaseUrl : _devApiBaseUrl;

  static String get assetBaseUrl =>
      AppSettings.isProduction ? _prodAssetBaseUrl : _devAssetBaseUrl;
}
