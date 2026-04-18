import 'package:flutter/material.dart';

class AppColors {
  /// Whether this palette belongs to the dark theme.
  final bool isDarkColor;

  /// Primary brand color (buttons, highlights).
  final Color primary;

  /// Secondary brand color.
  final Color secondary;

  /// Primary text color.
  final Color textPrimary;

  /// Secondary text color (hints, captions).
  final Color textSecondary;

  /// Text color on buttons.
  final Color textButtons;

  /// Pure background extreme — white in light mode, black in dark mode.
  final Color pureBackground;

  /// Pure foreground extreme — black in light mode, white in dark mode.
  final Color pureForeground;

  /// Scaffold background color.
  final Color scaffoldBackground;

  /// Error color for validation and error states.
  final Color error;

  /// Success color for confirmation states.
  final Color success;

  /// Warning color for alerts and notifications.
  final Color warning;

  /// Divider and border color.
  final Color divider;

  /// Color for inactive / disabled UI elements.
  final Color disabled;

  /// Surface color for cards, dialogs, and elevated components.
  final Color surface;

  /// Card surface color (slightly distinct from surface).
  final Color cardSurface;

  /// Icon color.
  final Color iconColor;

  /// Button background color.
  final Color buttonColor;

  /// Loader / progress indicator color.
  final Color loaderColor;

  /// General-purpose gray (separators, backgrounds).
  final Color gray;

  // ─── Input field colors ───────────────────────────────────────────────────

  final Color defaultBorderColor;
  final Color focusedBorderColor;
  final Color enabledBorderColor;
  final Color errorBorderColor;
  final Color disabledBorderColor;
  final Color focusedErrorBorderColor;
  final Color cursorColor;
  final Color selectionHighlightColor;
  final Color fillColor;
  final Color hintTextColor;

  // ─── Static constants ─────────────────────────────────────────────────────

  /// Selection handle color — primary with high transparency.
  Color get selectionHandleColor => primary.withValues(alpha: 0.35);

  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // ─── Constructor ──────────────────────────────────────────────────────────

  const AppColors._({
    required this.isDarkColor,
    required this.primary,
    required this.secondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textButtons,
    required this.pureBackground,
    required this.pureForeground,
    required this.scaffoldBackground,
    required this.error,
    required this.success,
    required this.warning,
    required this.divider,
    required this.disabled,
    required this.surface,
    required this.cardSurface,
    required this.iconColor,
    required this.buttonColor,
    required this.loaderColor,
    required this.gray,
    required this.defaultBorderColor,
    required this.focusedBorderColor,
    required this.enabledBorderColor,
    required this.errorBorderColor,
    required this.disabledBorderColor,
    required this.focusedErrorBorderColor,
    required this.cursorColor,
    required this.selectionHighlightColor,
    required this.fillColor,
    required this.hintTextColor,
  });

  // ─── Palettes ─────────────────────────────────────────────────────────────

  /// Light theme palette.
  static const AppColors light = AppColors._(
    isDarkColor: false,
    primary: Color(0xFF006C35),
    secondary: Color(0xFF1A7F4A),

    // Text
    textPrimary: Color(0xFF0B1F14),
    textSecondary: Color(0xFF4A5A4F),
    textButtons: Color(0xFFFFFFFF),
    hintTextColor: Color(0xFF8A968D),

    // Surfaces
    pureBackground: Colors.white,
    pureForeground: Colors.black,
    scaffoldBackground: Color(0xFFFAFBF9),
    surface: Color(0xFFFFFFFF),
    cardSurface: Color(0xFFF3F6F2),

    // Semantic
    error: Color(0xFFC2181A),
    success: Color(0xFF059669),
    warning: Color(0xFFCA8A04),

    // Neutrals
    divider: Color(0xFFE3E8E1),
    disabled: Color(0xFFC6CDC3),
    gray: Color(0xFFEDF1EC),

    // Action
    iconColor: Color(0xFF0B1F14),
    buttonColor: Color(0xFF006C35),
    loaderColor: Color(0xFF006C35),

    // Inputs
    defaultBorderColor: Color(0xFFE3E8E1),
    focusedBorderColor: Color(0xFF006C35),
    enabledBorderColor: Color(0xFFE3E8E1),
    errorBorderColor: Color(0xFFC2181A),
    disabledBorderColor: Color(0xFFE3E8E1),
    focusedErrorBorderColor: Color(0xFFC2181A),
    cursorColor: Color(0xFF006C35),
    selectionHighlightColor: Color(0x33006C35),
    fillColor: Color(0xFFFFFFFF),
  );

  /// Dark theme palette.
  static const AppColors dark = AppColors._(
    isDarkColor: true,
    primary: Color(0xFF2DB572),
    secondary: Color(0xFF1A4A2E),

    // Text
    textPrimary: Color(0xFFF5F7F4),
    textSecondary: Color(0xFF9BA89E),
    textButtons: Color(0xFF0A0F0C),
    hintTextColor: Color(0xFF6B7870),

    // Surfaces
    pureBackground: Colors.black,
    pureForeground: Colors.white,
    scaffoldBackground: Color(0xFF0A0F0C),
    surface: Color(0xFF101814),
    cardSurface: Color(0xFF142019),

    // Semantic
    error: Color(0xFFF56B6B),
    success: Color(0xFF10B981),
    warning: Color(0xFFFBBF24),

    // Neutrals
    divider: Color(0xFF1F2A23),
    disabled: Color(0xFF3A4A40),
    gray: Color(0xFF283329),

    // Action
    iconColor: Color(0xFFF5F7F4),
    buttonColor: Color(0xFF2DB572),
    loaderColor: Color(0xFF2DB572),

    // Inputs
    defaultBorderColor: Color(0xFF1F2A23),
    focusedBorderColor: Color(0xFF2DB572),
    enabledBorderColor: Color(0xFF1F2A23),
    errorBorderColor: Color(0xFFF56B6B),
    disabledBorderColor: Color(0xFF1F2A23),
    focusedErrorBorderColor: Color(0xFFF56B6B),
    cursorColor: Color(0xFF2DB572),
    selectionHighlightColor: Color(0x4D2DB572),
    fillColor: Color(0xFF101814),
  );
}
