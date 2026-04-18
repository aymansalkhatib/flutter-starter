import 'environment_config.dart';

/// All API endpoint paths and URL builders.
abstract final class ApiEndpoints {
  // ─── URL Builders ─────────────────────────────────────────────────────────

  static String apiUrl(String endpoint) =>
      '${EnvironmentConfig.apiBaseUrl}$endpoint';

  static String assetUrl(String path) =>
      '${EnvironmentConfig.assetBaseUrl}/$path';

  // ─── Products ─────────────────────────────────────────────────────────────
  static const String products = '/products';

  // ─── Auth ─────────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String reSendCode = '/auth/re-send-code';
  static const String passwordRequestReset = '/auth/password/request-reset';
  static const String passwordConfirmReset = '/auth/password/confirm-reset';
}
