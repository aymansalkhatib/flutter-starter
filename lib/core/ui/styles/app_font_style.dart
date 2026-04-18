import 'package:flutter/material.dart';

import '../../extensions/build_context_extensions.dart';
import '../../extensions/responsive_font_size_extension.dart';

/// A centralized class for managing app-wide text styles with responsive scaling.
class AppFontStyle {
  final BuildContext context;

  AppFontStyle(this.context);

  /// Returns a responsive text style with customizable parameters.
  TextStyle textStyle({
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
    TextDecoration? decoration,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontSize: fontSize.sp(context),
      fontWeight: fontWeight,
      color: color ?? context.colors.textPrimary,
      decoration: decoration,
      fontStyle: fontStyle,
    );
  }

  /// Light weight styles.
  TextStyle light(double fontSize) =>
      textStyle(fontSize: fontSize, fontWeight: FontWeight.w300);

  /// Regular weight styles.
  TextStyle regular(double fontSize) =>
      textStyle(fontSize: fontSize, fontWeight: FontWeight.w400);

  /// Medium weight styles.
  TextStyle medium(double fontSize) =>
      textStyle(fontSize: fontSize, fontWeight: FontWeight.w500);

  /// Semi-bold weight styles.
  TextStyle semiBold(double fontSize) =>
      textStyle(fontSize: fontSize, fontWeight: FontWeight.w600);

  /// Bold weight styles.
  TextStyle bold(double fontSize) =>
      textStyle(fontSize: fontSize, fontWeight: FontWeight.w700);

  /// Extra-bold weight styles.
  TextStyle extraBold(double fontSize) =>
      textStyle(fontSize: fontSize, fontWeight: FontWeight.w800);

  // Light
  TextStyle get light12 => light(12);
  TextStyle get light14 => light(14);

  // Regular
  TextStyle get regular8 => regular(8);
  TextStyle get regular10 => regular(10);
  TextStyle get regular11 => regular(11);
  TextStyle get regular12 => regular(12);
  TextStyle get regular13 => regular(13);
  TextStyle get regular14 => regular(14);
  TextStyle get regular15 => regular(15);
  TextStyle get regular16 => regular(16);
  TextStyle get regular17 => regular(17);
  TextStyle get regular18 => regular(18);
  TextStyle get regular20 => regular(20);

  // Medium
  TextStyle get medium10 => medium(10);
  TextStyle get medium11 => medium(11);
  TextStyle get medium12 => medium(12);
  TextStyle get medium13 => medium(13);
  TextStyle get medium14 => medium(14);
  TextStyle get medium15 => medium(15);
  TextStyle get medium16 => medium(16);
  TextStyle get medium18 => medium(18);
  TextStyle get medium20 => medium(20);

  // SemiBold
  TextStyle get semiBold12 => semiBold(12);
  TextStyle get semiBold13 => semiBold(13);
  TextStyle get semiBold14 => semiBold(14);
  TextStyle get semiBold15 => semiBold(15);
  TextStyle get semiBold16 => semiBold(16);
  TextStyle get semiBold17 => semiBold(17);
  TextStyle get semiBold18 => semiBold(18);
  TextStyle get semiBold19 => semiBold(19);
  TextStyle get semiBold20 => semiBold(20);
  TextStyle get semiBold22 => semiBold(22);
  TextStyle get semiBold24 => semiBold(24);

  // Bold
  TextStyle get bold10 => bold(10);
  TextStyle get bold12 => bold(12);
  TextStyle get bold14 => bold(14);
  TextStyle get bold15 => bold(15);
  TextStyle get bold16 => bold(16);
  TextStyle get bold18 => bold(18);
  TextStyle get bold20 => bold(20);
  TextStyle get bold22 => bold(22);
  TextStyle get bold24 => bold(24);
  TextStyle get bold26 => bold(26);
  TextStyle get bold28 => bold(28);

  // ExtraBold
  TextStyle get extraBold16 => extraBold(16);
  TextStyle get extraBold20 => extraBold(20);
  TextStyle get extraBold24 => extraBold(24);
}
