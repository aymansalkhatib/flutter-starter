import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'app_theme.dart';

/// Implementation of the light theme.
class LightTheme extends AppTheme {
  /// Singleton instance of the light theme.
  static LightTheme? _instance;

  /// Factory constructor to ensure a single instance of the light theme.
  factory LightTheme() {
    _instance ??= LightTheme._internal();
    return _instance!;
  }

  /// Private constructor to enforce singleton pattern.
  LightTheme._internal();

  @override
  final AppColors colors = AppColors.light;

  @override
  ThemeData get themeData {
    return buildThemeData(colors, Brightness.light);
  }
}
