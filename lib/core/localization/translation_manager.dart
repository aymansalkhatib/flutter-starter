import 'dart:ui';

import '../constants/hive/storage_keys.dart';
import '../storage/hive/hive_boxes.dart';
import 'app_localizations.dart';

abstract final class TranslationManager {
  /// Get the current language code (e.g., "en" or "ar").
  static String fetchCurrentLanguageCode() => fetchPreferredLanguage().languageCode;

  /// Check if the current language is Arabic.
  static bool get isArabicLanguage => fetchCurrentLanguageCode() == 'ar';

  /// Check if the current language is English.
  static bool get isEnglishLanguage => fetchCurrentLanguageCode() == 'en';

  /// Returns the user's preferred locale.
  ///
  /// Priority: saved preference → supported system locale → fallback (en).
  static Locale fetchPreferredLanguage() {
    final appBox = HiveBoxes.appBox;
    final String? savedLanguage =
        appBox.get(StorageKeys.languagePreference) as String?;

    if (savedLanguage != null && _isSupported(savedLanguage)) {
      return Locale(savedLanguage);
    }

    final systemCode = PlatformDispatcher.instance.locale.languageCode;
    if (_isSupported(systemCode)) {
      return Locale(systemCode);
    }

    return AppLocalizations.fallbackLocale;
  }

  static bool _isSupported(String languageCode) => AppLocalizations.supportedLocales
      .any((l) => l.languageCode == languageCode);
}
