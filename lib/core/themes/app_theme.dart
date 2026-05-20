import 'package:flutter/material.dart';
import 'package:flutter_starter/generated/fonts.dart';

import '../constants/app_colors.dart';
import '../localization/translation_manager.dart';

/// Abstract base class for defining app themes.
abstract class AppTheme {
  /// Returns the `ThemeData` instance for the theme.
  ThemeData get themeData;

  /// Returns the colors associated with this theme.
  AppColors get colors;
}

/// A helper method to build `ThemeData` with customizable options.
ThemeData buildThemeData(AppColors colors, Brightness brightness) {
  return ThemeData(
    // General Theme Properties
    // Automatically set based on light/dark mode
    brightness: brightness,
    primaryColor: colors.primary,
    scaffoldBackgroundColor: colors.scaffoldBackground,
    fontFamily: TranslationManager.isArabicLanguage
        ? AppFonts.almarai
        : AppFonts.openSans,

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: TextStyle(
        color: colors.secondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Color Scheme
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      secondary: colors.secondary,
      error: colors.error,
      onPrimary: colors.textPrimary,
      onSecondary: colors.textSecondary,
      onError: Colors.white,
      surface: colors.surface,
      onSurface: colors.textPrimary,
    ),

    // Input Field Customization
    inputDecorationTheme: InputDecorationTheme(
      fillColor: colors.fillColor,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.disabledBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.enabledBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.focusedBorderColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: colors.focusedErrorBorderColor.withValues(alpha: 0.8),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.focusedErrorBorderColor),
      ),
      hintStyle: TextStyle(color: colors.hintTextColor, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    ),

    // Elevated Button Customization
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    // App Bar Customization
    appBarTheme: AppBarTheme(
      backgroundColor: colors.primary,
      foregroundColor: colors.iconColor,
      elevation: 0,
      centerTitle: true,
    ),

    // Divider Customization
    dividerTheme: DividerThemeData(
      color: colors.divider,
      thickness: 1,
      space: 8,
    ),

    // Bottom Navigation Bar Customization
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colors.scaffoldBackground,
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.textSecondary,
      elevation: 4,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),

    // Floating Action Button Customization
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Dialog Customization
    dialogTheme: DialogThemeData(
      backgroundColor: colors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Card Customization
    cardTheme: CardThemeData(
      color: colors.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
    ),

    // SnackBar Customization
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.primary,
      actionTextColor: Colors.white,
      elevation: 4,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Progress Indicator Customization
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colors.primary,
      circularTrackColor: colors.divider,
      linearTrackColor: colors.divider,
      refreshBackgroundColor: colors.surface,
    ),

    // Slider Customization
    sliderTheme: SliderThemeData(
      activeTrackColor: colors.primary,
      inactiveTrackColor: colors.divider,
      thumbColor: colors.primary,
      overlayColor: colors.primary.withValues(alpha: 0.2),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
    ),

    // Expansion Tile Customization
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: colors.surface,
      collapsedBackgroundColor: colors.surface,
      iconColor: colors.primary,
      collapsedIconColor: colors.textSecondary,
      textColor: colors.textPrimary,
      collapsedTextColor: colors.textSecondary,
    ),
  );
}
