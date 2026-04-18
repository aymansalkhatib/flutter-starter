import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../localization/translation_manager.dart';
import '../themes/app_theme_manager.dart';
import '../ui/styles/app_font_style.dart';

extension ContextExtensions on BuildContext {
  // ─── Theme ────────────────────────────────────────────────────────────────

  AppColors get colors => AppThemeManager.getActiveColors(this);
  AppColors get reverseColors => AppThemeManager.getReverseColors(this);
  AppFontStyle get styles => AppFontStyle(this);
  ThemeData get theme => Theme.of(this);
  bool get isDarkMode => AppThemeManager.isDarkMode(this);

  // ─── Localization ─────────────────────────────────────────────────────────

  Locale get currentLocale => TranslationManager.fetchPreferredLanguage();
  String get currentLanguageCode =>
      TranslationManager.fetchCurrentLanguageCode();
  bool get isArabic => TranslationManager.isArabicLanguage;
  bool get isEnglish => TranslationManager.isEnglishLanguage;

  // ─── Screen ───────────────────────────────────────────────────────────────

  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  double get pixelRatio => MediaQuery.devicePixelRatioOf(this);
  double get shortestSide => screenSize.shortestSide;
  double get longestSide => screenSize.longestSide;
  bool get isPortrait => MediaQuery.orientationOf(this) == Orientation.portrait;
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  // ─── Safe Area ────────────────────────────────────────────────────────────

  EdgeInsets get safePadding => MediaQuery.paddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  double get topPadding => safePadding.top;
  double get bottomPadding => safePadding.bottom;

  // ─── Platform ─────────────────────────────────────────────────────────────

  bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
  bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  bool get isWeb => kIsWeb;
  bool get isDesktop => const {
        TargetPlatform.windows,
        TargetPlatform.macOS,
        TargetPlatform.linux,
      }.contains(defaultTargetPlatform);

  // ─── Keyboard & Focus ─────────────────────────────────────────────────────

  bool get isKeyboardVisible => viewInsets.bottom > 0;
  void unfocus() => FocusManager.instance.primaryFocus?.unfocus();
  void requestFocus(FocusNode node) => FocusScope.of(this).requestFocus(node);

  // ─── Route ────────────────────────────────────────────────────────────────

  String? get currentRouteName => ModalRoute.of(this)?.settings.name;
  Object? get routeArguments => ModalRoute.of(this)?.settings.arguments;
}
