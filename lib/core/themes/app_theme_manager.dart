import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/hive/storage_keys.dart';
import '../extensions/build_context_extensions.dart';
import '../storage/hive/hive_boxes.dart';

/// Helper class for managing application themes.
abstract class AppThemeManager {
  /// Retrieves the current [ThemeMode] from local storage.
  static ThemeMode getCurrentThemeMode() {
    final appBox = HiveBoxes.appBox;
    final themeString = appBox.get(StorageKeys.themeModePreference) as String?;
    return _parseThemeMode(themeString);
  }

  /// Parses the [ThemeMode] from a string value.
  static ThemeMode _parseThemeMode(String? themeString) {
    switch (themeString) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Retrieves the color scheme based on the current theme.
  static AppColors getActiveColors(BuildContext context) {
    return isDarkMode(context) ? AppColors.dark : AppColors.light;
  }

  static AppColors getReverseColors(BuildContext context) {
    return isDarkMode(context) ? AppColors.light : AppColors.dark;
  }

  /// Checks if the current theme is dark.
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Updates the status bar (top bar) appearance based on the current theme.
  ///
  /// This method dynamically creates and returns a `SystemUiOverlayStyle` object
  /// tailored for the current theme (light or dark mode). It ensures that the
  /// status bar and navigation bar colors, as well as icon brightness, adapt
  /// seamlessly to the app's theme.
  static SystemUiOverlayStyle setSystemUIOverlayStyle(BuildContext context) {
    // Check if the current theme is dark mode.
    final isDark = isDarkMode(context);

    // Create and return the SystemUiOverlayStyle object.
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent background for the status bar.
      statusBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark, // Icon brightness for Android.
      statusBarBrightness:
          isDark ? Brightness.dark : Brightness.light, // Status bar brightness for iOS.
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark, // Bottom navigation bar icons.
      systemNavigationBarColor:
          context.colors.scaffoldBackground, // Bottom navigation bar background color.
    );
  }

  /// Applies the updated status bar appearance based on the current theme.
  ///
  /// This method retrieves the appropriate `SystemUiOverlayStyle` using
  /// `setSystemUIOverlayStyle` and applies it to the system UI using
  /// `SystemChrome.setSystemUIOverlayStyle`.
  static void updateStatusBar(BuildContext context) {
    // Retrieve the SystemUiOverlayStyle for the current theme.
    final systemUIStyle = AppThemeManager.setSystemUIOverlayStyle(context);

    // Apply the retrieved style to the system UI.
    SystemChrome.setSystemUIOverlayStyle(systemUIStyle);
  }
}
