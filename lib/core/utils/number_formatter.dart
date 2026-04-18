import 'dart:math' as math;

import 'package:intl/intl.dart';

import 'app_logger.dart';

abstract final class NumberFormatter {
  // ─── Currency ─────────────────────────────────────────────────────────────

  /// e.g. `10002.5` → `"$10,002.50"`
  static String formatCurrency(
    double amount, {
    String locale = 'en_US',
    String? symbol,
    int decimalDigits = 2,
  }) {
    return NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    ).format(amount);
  }

  /// Parses a currency string back to a double. Returns null on failure.
  static double? parseCurrency(
    String value, {
    String locale = 'en_US',
  }) {
    try {
      return NumberFormat.currency(locale: locale).parse(value).toDouble();
    } catch (e) {
      AppLogger.error('parseCurrency failed for "$value"', error: e);
      return null;
    }
  }

  // ─── General formatting ───────────────────────────────────────────────────

  /// e.g. `1000000` → `"1,000,000"`
  static String formatWithCommas(num number) =>
      NumberFormat.decimalPattern().format(number);

  /// e.g. `1200000` → `"1.2M"`
  static String formatCompact(double number) =>
      NumberFormat.compact().format(number);

  /// e.g. `0.175` → `"17.50%"`
  static String formatPercentage(double value, {int decimalPlaces = 2}) =>
      (NumberFormat.percentPattern()..maximumFractionDigits = decimalPlaces)
          .format(value);

  static String formatFixedDecimal(double number, int decimalPlaces) =>
      number.toStringAsFixed(decimalPlaces);

  /// Formats without scientific notation. Integer values show no decimal part.
  static String toPlainString(double number) => number.toStringAsFixed(
        number.truncateToDouble() == number ? 0 : 2,
      );

  // ─── Range & list ─────────────────────────────────────────────────────────

  /// e.g. `(1000, 2000)` → `"1,000 - 2,000"`
  static String formatRange(num start, num end) {
    final fmt = NumberFormat.decimalPattern();
    return '${fmt.format(start)} - ${fmt.format(end)}';
  }

  /// e.g. `[1000, 2000]` → `"1,000, 2,000"`
  static String formatList(List<num> numbers) {
    final fmt = NumberFormat.decimalPattern();
    return numbers.map(fmt.format).join(', ');
  }

  // ─── Math helpers ─────────────────────────────────────────────────────────

  static double roundToDecimalPlaces(double number, int decimalPlaces) {
    final mod = math.pow(10.0, decimalPlaces);
    return (number * mod).round().toDouble() / mod;
  }

  static bool isInteger(num value) =>
      value is int || value == value.roundToDouble();

  /// e.g. `0.5` → `"1/2"`. Limited to 2-decimal precision.
  static String formatFraction(double value) {
    if (value == 0) {
      return '0';
    }
    final numerator = (value * 100).round();
    const denominator = 100;
    final gcd = _gcd(numerator.abs(), denominator);
    final n = numerator ~/ gcd;
    final d = denominator ~/ gcd;
    return d == 1 ? '$n' : '$n/$d';
  }

  /// English-only ordinal (1st, 2nd, 3rd…). Not locale-aware.
  static String formatOrdinal(int number) {
    if (number <= 0) {
      return number.toString();
    }
    final mod100 = number % 100;
    final mod10 = number % 10;
    final suffix = (mod100 >= 11 && mod100 <= 13)
        ? 'th'
        : mod10 == 1
            ? 'st'
            : mod10 == 2
                ? 'nd'
                : mod10 == 3
                    ? 'rd'
                    : 'th';
    return '$number$suffix';
  }

  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }
}
