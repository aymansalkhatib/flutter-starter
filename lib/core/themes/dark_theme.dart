import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'app_theme.dart';

/// Implementation of the dark theme.
class DarkTheme extends AppTheme {
  /// Singleton instance of the dark theme.
  static DarkTheme? _instance;

  /// Factory constructor to ensure a single instance of the dark theme.
  factory DarkTheme() {
    _instance ??= DarkTheme._internal();
    return _instance!;
  }

  /// Private constructor to enforce singleton pattern.
  DarkTheme._internal();

  @override
  final AppColors colors = AppColors.dark;

  @override
  ThemeData get themeData {
    return buildThemeData(colors, Brightness.dark);
  }
}
