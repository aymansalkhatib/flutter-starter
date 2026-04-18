/// Hive storage keys used across the app.
abstract final class StorageKeys {
  // ─── App Settings ─────────────────────────────────────────────────────────
  static const String themeModePreference = 'themeModePreference';
  static const String languagePreference = 'languagePreference';

  // ─── Auth ─────────────────────────────────────────────────────────────────
  static const String authToken = 'authToken';
  static const String userData = 'userData';

  // ─── Notifications ────────────────────────────────────────────────────────
  static const String fcmToken = 'fcmToken';
}
