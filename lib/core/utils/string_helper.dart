abstract final class StringUtils {
  // ─── Cached patterns ──────────────────────────────────────────────────────

  static final _numericPattern = RegExp(r'^-?[0-9]+$');
  static final _emailPattern = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final _alphabeticPattern = RegExp(r'^[a-zA-Z]+$');
  static final _alphanumericPattern = RegExp(r'^[a-zA-Z0-9]+$');
  static final _whitespacePattern = RegExp(r'\s+');
  static final _nonDigitsPattern = RegExp(r'[^0-9]');
  static final _nonLettersPattern = RegExp(r'[^a-zA-Z]');
  static final _nonWordPattern = RegExp(r'\W+');
  static final _camelCasePattern = RegExp('([a-z])([A-Z])');

  // ─── Checks ───────────────────────────────────────────────────────────────

  static bool isNullOrEmpty(String? text) =>
      text == null || text.trim().isEmpty;

  static bool isNumeric(String text) =>
      text.isNotEmpty && _numericPattern.hasMatch(text);

  static bool isValidEmail(String email) =>
      email.isNotEmpty && _emailPattern.hasMatch(email);

  static bool isAlphabetic(String text) =>
      text.isNotEmpty && _alphabeticPattern.hasMatch(text);

  static bool isAlphanumeric(String text) =>
      text.isNotEmpty && _alphanumericPattern.hasMatch(text);

  static bool isPalindrome(String text) {
    if (text.isEmpty) {
      return false;
    }
    final clean = text.toLowerCase().replaceAll(_nonWordPattern, '');
    return clean == String.fromCharCodes(clean.runes.toList().reversed);
  }

  // ─── Transformation ───────────────────────────────────────────────────────

  /// e.g. `"hello world"` → `"Hello World"`
  static String capitalizeEachWord(String text) {
    if (text.isEmpty) {
      return '';
    }
    return text.split(' ').map((word) {
      if (word.isEmpty) {
        return '';
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// e.g. `"hello"` → `"Hello"`
  static String capitalizeFirst(String text) {
    if (text.isEmpty) {
      return '';
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Handles Unicode/emoji correctly via runes.
  static String reverse(String text) {
    if (text.isEmpty) {
      return '';
    }
    return String.fromCharCodes(text.runes.toList().reversed);
  }

  /// e.g. `truncate("hello world", 5)` → `"hello..."`
  static String truncate(
    String text,
    int maxLength, {
    String ellipsis = '...',
  }) {
    if (text.isEmpty || maxLength <= 0 || text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}$ellipsis';
  }

  static String removeWhitespace(String text) =>
      text.replaceAll(_whitespacePattern, '');

  static String extractNumbers(String text) =>
      text.replaceAll(_nonDigitsPattern, '');

  static String extractLetters(String text) =>
      text.replaceAll(_nonLettersPattern, '');

  /// e.g. `"helloWorld"` → `"hello_world"`
  static String camelToSnakeCase(String text) {
    if (text.isEmpty) {
      return '';
    }
    return text
        .replaceAllMapped(_camelCasePattern, (m) => '${m[1]}_${m[2]}')
        .toLowerCase();
  }

  /// e.g. `"hello_world"` → `"helloWorld"`
  static String snakeToCamelCase(String text) {
    if (text.isEmpty) {
      return '';
    }
    final parts = text.split('_');
    return parts.first +
        parts.skip(1).map((w) {
          if (w.isEmpty) {
            return '';
          }
          return w[0].toUpperCase() + w.substring(1).toLowerCase();
        }).join();
  }

  /// e.g. `maskString("1234567890", start: 3, end: 3)` → `"123****890"`
  static String maskString(String text, {int start = 0, int end = 0}) {
    if (text.isEmpty || start + end >= text.length) {
      return text;
    }
    final maskLength = text.length - start - end;
    return text.substring(0, start) +
        '*' * maskLength +
        (end > 0 ? text.substring(text.length - end) : '');
  }

  // ─── Metrics ──────────────────────────────────────────────────────────────

  static int countWords(String text) {
    if (text.trim().isEmpty) {
      return 0;
    }
    return text.trim().split(_whitespacePattern).length;
  }
}
