import 'package:intl/intl.dart';

abstract final class DateFormatter {
  // ─── Formatting ───────────────────────────────────────────────────────────

  static String format(DateTime date, {String pattern = 'yyyy-MM-dd'}) {
    try {
      return DateFormat(pattern).format(date);
    } catch (_) {
      return '';
    }
  }

  static String formatTime(DateTime time, {String pattern = 'HH:mm'}) {
    try {
      return DateFormat(pattern).format(time);
    } catch (_) {
      return '';
    }
  }

  /// Returns a relative string like "2 hours ago".
  /// Note: strings are in English — pass [locale] for other languages.
  static String formatRelative(DateTime date, {String locale = 'en'}) {
    final diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return format(date);
  }

  static String toUtcString(DateTime date) => date.toUtc().toIso8601String();

  // ─── Parsing ──────────────────────────────────────────────────────────────

  static DateTime? parse(String value, {String pattern = 'yyyy-MM-dd'}) {
    try {
      return DateFormat(pattern).parse(value);
    } catch (_) {
      return null;
    }
  }

  static DateTime? fromUtcString(String value) {
    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      return null;
    }
  }

  // ─── Comparison ───────────────────────────────────────────────────────────

  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isPast(DateTime date) => date.isBefore(DateTime.now());

  static bool isFuture(DateTime date) => date.isAfter(DateTime.now());

  /// Returns the number of whole days between [start] and [end],
  /// ignoring the time component.
  static int daysBetween(DateTime start, DateTime end) =>
      startOfDay(end).difference(startOfDay(start)).inDays;

  // ─── Manipulation ─────────────────────────────────────────────────────────

  static DateTime addDays(DateTime date, int days) =>
      date.add(Duration(days: days));

  static DateTime subtractDays(DateTime date, int days) =>
      addDays(date, -days);

  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  static DateTime firstDayOfWeek(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  static DateTime lastDayOfWeek(DateTime date) =>
      date.add(Duration(days: DateTime.daysPerWeek - date.weekday));

  // ─── Calendar ─────────────────────────────────────────────────────────────

  static bool isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

  /// Uses `DateTime(year, month + 1, 0)` which handles leap years automatically.
  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;
}
