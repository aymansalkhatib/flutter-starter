import 'dart:convert';
import 'dart:developer' as dev;

import 'package:dio/dio.dart';

import '../../constants/app_settings.dart';

// ═════════════════════════════════════════════════════════════════════════════
// ANSI Colors
// Works in: VS Code Debug Console ✓ | Android Studio Run Console ✓
// ═════════════════════════════════════════════════════════════════════════════
abstract final class _C {
  // ── Style ──────────────────────────────────────────────
  static const reset = '\x1B[0m';
  static const bold = '\x1B[1m';

  // ── Foreground ─────────────────────────────────────────
  static const yellow = '\x1B[33m';
  static const magenta = '\x1B[35m';
  static const cyan = '\x1B[36m';
  static const white = '\x1B[37m';
  static const brightBlack = '\x1B[90m'; // dim / dark-gray
  static const brightRed = '\x1B[91m';
  static const brightGreen = '\x1B[92m';
  static const brightYellow = '\x1B[93m';
  static const brightBlue = '\x1B[94m';
  static const brightCyan = '\x1B[96m';
  static const brightWhite = '\x1B[97m';

  // ── Background ─────────────────────────────────────────
  static const bgRed = '\x1B[41m';

  // ── Semantic aliases (mirrors old LoggerColors) ────────
  static const environment = yellow; // orange-ish
  static const url = brightGreen;
  static const duration = brightYellow;
  static const errorMsg = brightRed;
  static const stackTrace = brightGreen;
}

// ═════════════════════════════════════════════════════════════════════════════
// HTTP Method coloring
// ═════════════════════════════════════════════════════════════════════════════
extension _MethodColor on String {
  String get methodColored {
    final upper = toUpperCase();
    final color = switch (upper) {
      'GET' => _C.brightBlue,
      'POST' => _C.brightGreen,
      'PUT' => _C.brightYellow,
      'PATCH' => _C.brightCyan,
      'DELETE' => _C.brightRed,
      _ => _C.brightWhite,
    };
    return '$color${_C.bold}$upper${_C.reset}';
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// HTTP Status Code coloring
// ═════════════════════════════════════════════════════════════════════════════
extension _StatusColor on int {
  String get statusColored {
    final color = switch (this) {
      >= 200 && < 300 => _C.brightGreen,
      >= 300 && < 400 => _C.brightYellow,
      >= 400 && < 500 => _C.brightRed,
      >= 500 => '${_C.bgRed}${_C.white}',
      _ => _C.brightWhite,
    };
    return '$color${_C.bold}$this${_C.reset}';
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// JSON Formatter  (replaces AppLogger JSON utilities)
// ═════════════════════════════════════════════════════════════════════════════
abstract final class _Json {
  // Pulled from AppSettings equivalents
  static int get _maxStringLength => AppSettings.maxLogStringLength;
  static int get _maxListItems => AppSettings.maxListItems;

  static const _linePrefix = '${_C.brightBlack}│${_C.reset}   ';

  // ── Public API ──────────────────────────────────────────

  /// Pretty-prints [data] as indented, ANSI-colored JSON.
  ///
  /// Color scheme:
  ///   Keys        → cyan
  ///   Strings     → bright-green
  ///   Numbers     → magenta
  ///   bool / null → yellow
  static String pretty(dynamic data) {
    if (data == null) {
      return '$_linePrefix${_C.brightBlack}null${_C.reset}';
    }

    try {
      final truncated = _truncate(data);
      final raw = truncated is String ? truncated : jsonEncode(truncated);
      final decoded = jsonDecode(raw);
      final indented = const JsonEncoder.withIndent('  ').convert(decoded);
      return _colorize(indented);
    } catch (_) {
      return '$_linePrefix${_C.brightWhite}$data${_C.reset}';
    }
  }


  // ── Private helpers ─────────────────────────────────────

  /// Mirrors the old [AppLogger.truncateJson]:
  /// recursively truncates Maps, limits Lists, and trims long Strings.
  static dynamic _truncate(dynamic data) {
    if (data is Map) {
      return data.map((k, v) => MapEntry(k, _truncate(v)));
    } else if (data is List) {
      return data.take(_maxListItems).map(_truncate).toList();
    } else if (data is String && data.length > _maxStringLength) {
      return '${data.substring(0, _maxStringLength)}… [truncated]';
    }
    return data;
  }

  /// Applies ANSI colors to each line of an indented JSON string.
  static String _colorize(String prettyJson) {
    final lines = prettyJson.split('\n');
    final buffer = StringBuffer();

    for (var i = 0; i < lines.length; i++) {
      final colored = lines[i]
          // "key":
          .replaceAllMapped(
            RegExp(r'"([^"]+)"\s*:'),
            (m) => '${_C.cyan}"${m[1]}"${_C.reset}:',
          )
          // : "string value"
          .replaceAllMapped(
            RegExp(r'(:\s*)"([^"]*)"'),
            (m) => '${m[1]}${_C.brightGreen}"${m[2]}"${_C.reset}',
          )
          // : number
          .replaceAllMapped(
            RegExp(r'(:\s*)(-?\d+\.?\d*)'),
            (m) => '${m[1]}${_C.magenta}${m[2]}${_C.reset}',
          )
          // : true | false | null
          .replaceAllMapped(
            RegExp(r'(:\s*)(true|false|null)\b'),
            (m) => '${m[1]}${_C.yellow}${m[2]}${_C.reset}',
          );

      buffer.write('$_linePrefix$colored');
      if (i < lines.length - 1) {
        buffer.writeln();
      }
    }
    return buffer.toString();
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Log Phase definition
// ═════════════════════════════════════════════════════════════════════════════
enum _Phase {
  request('REQUEST', '📤', _C.brightBlue),
  response('RESPONSE', '📥', _C.brightGreen),
  error('ERROR', '🔴', _C.brightRed);

  const _Phase(this.label, this.emoji, this.color);
  final String label;
  final String emoji;
  final String color;

  String get devTag => 'HTTP • $label';

  /// ┌─── 📤  REQUEST  ─────────────────────────────────────
  String header() {
    final fill = '─' * (38 - label.length);
    return '$color${_C.bold}┌─── $emoji  $label  $fill${_C.reset}';
  }

  /// ├──────────────────────────────────────────────────────
  String divider() => '${_C.brightBlack}├${'─' * 47}${_C.reset}';

  /// └──────────────────────────────────────────────────────
  String footer() => '$color└${'─' * 47}${_C.reset}';
}

// ═════════════════════════════════════════════════════════════════════════════
// Row builder  ──  │ LABEL   value
// ═════════════════════════════════════════════════════════════════════════════
String _row(String label, String value) =>
    '${_C.brightBlack}│${_C.reset} ${_C.brightBlack}${_C.bold}$label${_C.reset}  $value';

// ═════════════════════════════════════════════════════════════════════════════
// ApiLoggerInterceptor
// ═════════════════════════════════════════════════════════════════════════════

/// A single Dio interceptor that replaces the three separate interceptors
/// (RequestLoggerInterceptor, ResponseLoggerInterceptor, ErrorLoggerInterceptor)
/// plus the AppLogger / LoggerColors utilities — all in one self-contained file.
///
/// Features:
///   • Full ANSI coloring (VS Code ✓ | Android Studio ✓)
///   • Pretty-printed + color-coded JSON (keys, strings, numbers, booleans)
///   • Recursive JSON truncation via AppSettings limits
///   • Elapsed-time tracking per request
///   • Per-phase enable/disable switches
///   • Stack trace preview on errors (first 8 frames)
///
/// Sample output:
/// ```
/// ┌─── 📤  REQUEST  ─────────────────────────────────────
/// │ Env     🟢 Development
/// │ Time    2025-01-01 12:00:00.000
/// │ Method  POST
/// │ URL     https://api.example.com/auth/login
/// ├───────────────────────────────────────────────────────
/// │ Headers
/// │   { "Authorization": "Bearer …" }
/// ├───────────────────────────────────────────────────────
/// │ Body
/// │   { "email": "user@example.com" }
/// └───────────────────────────────────────────────────────
/// ```
///
/// Enable / disable via [AppSettings]:
///   • [AppSettings.enableLogging]        ← master switch
///   • [AppSettings.enableRequestLogger]
///   • [AppSettings.enableResponseLogger]
///   • [AppSettings.enableErrorLogger]
///
/// Register once:
/// ```dart
/// dio.interceptors.add(ApiLoggerInterceptor());
/// ```
class ApiLoggerInterceptor extends Interceptor {
  // ── Request ─────────────────────────────────────────────────────────────

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (AppSettings.enableRequestLogger) {
      options.extra['startTime'] = DateTime.now();
      _log(_buildRequest(options), _Phase.request);
    }
    handler.next(options);
  }

  String _buildRequest(RequestOptions o) {
    const env = AppSettings.isProduction
        ? '🟠 ${_C.environment}${_C.bold}Production${_C.reset}'
        : '🟢 ${_C.brightGreen}${_C.bold}Development${_C.reset}';

    final b = StringBuffer()
      ..writeln(_Phase.request.header())
      ..writeln(_row('Env    :', env))
      ..writeln(_row('Time   :', '${_C.brightWhite}${DateTime.now()}${_C.reset}'))
      ..writeln(_row('Method :', o.method.methodColored))
      ..writeln(_row('URL    :', '${_C.url}${o.uri}${_C.reset}'));

    if (o.headers.isNotEmpty) {
      b
        ..writeln(_Phase.request.divider())
        ..writeln(_row('Headers:', ''))
        ..writeln(_Json.pretty(o.headers));
    }

    if (o.queryParameters.isNotEmpty) {
      b
        ..writeln(_Phase.request.divider())
        ..writeln(_row('Params :', ''))
        ..writeln(_Json.pretty(o.queryParameters));
    }

    b
      ..writeln(_Phase.request.divider())
      ..writeln(_row('Body   :', ''))
      ..writeln(_Json.pretty(o.data))
      ..write(_Phase.request.footer());

    return b.toString();
  }

  // ── Response ────────────────────────────────────────────────────────────

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (AppSettings.enableResponseLogger) {
      _log(_buildResponse(response), _Phase.response);
    }
    handler.next(response);
  }

  String _buildResponse(Response<dynamic> r) {
    final status = r.statusCode ?? 0;
    final ms = _elapsed(r.requestOptions);

    final b = StringBuffer()
      ..writeln(_Phase.response.header())
      ..writeln(_row('Status :', status.statusColored))
      ..writeln(_row('Time   :', '${_C.duration}${_C.bold}${ms}ms${_C.reset}'))
      ..writeln(_row('Method :', r.requestOptions.method.methodColored))
      ..writeln(_row('URL    :', '${_C.url}${r.requestOptions.uri}${_C.reset}'))
      ..writeln(_Phase.response.divider())
      ..writeln(_row('Data   :', ''))
      ..writeln(_Json.pretty(r.data))
      ..write(_Phase.response.footer());

    return b.toString();
  }

  // ── Error ────────────────────────────────────────────────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (AppSettings.enableErrorLogger) {
      _log(_buildError(err), _Phase.error);
    }
    handler.next(err);
  }

  String _buildError(DioException err) {
    final status = err.response?.statusCode;
    final ms = _elapsed(err.requestOptions);

    final b = StringBuffer()
      ..writeln(_Phase.error.header())
      ..writeln(
          _row('Status :', status != null ? status.statusColored : '${_C.brightRed}N/A${_C.reset}'))
      ..writeln(_row('Time   :', '${_C.duration}${_C.bold}${ms}ms${_C.reset}'))
      ..writeln(_row('Method :', err.requestOptions.method.methodColored))
      ..writeln(_row('URL    :', '${_C.url}${err.requestOptions.uri}${_C.reset}'))
      ..writeln(_row('Type   :', '${_C.brightYellow}${err.type.name}${_C.reset}'))
      ..writeln(_Phase.error.divider())
      ..writeln(_row('Message:', '${_C.errorMsg}${err.message ?? "No error message"}${_C.reset}'));

    if (err.response?.data != null) {
      b
        ..writeln(_Phase.error.divider())
        ..writeln(_row('Data   :', ''))
        ..writeln(_Json.pretty(err.response?.data));
    }

    // First 8 stack-trace frames — enough to locate the call site
    final trace = err.stackTrace.toString().split('\n').take(8).join('\n│   ');
    if (trace.isNotEmpty) {
      b
        ..writeln(_Phase.error.divider())
        ..writeln(_row('Trace  :', ''))
        ..writeln('${_C.stackTrace}│   $trace${_C.reset}');
    }

    b.write(_Phase.error.footer());
    return b.toString();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns elapsed milliseconds since the request started.
  int _elapsed(RequestOptions options) {
    final start = options.extra['startTime'] as DateTime?;
    return start == null ? 0 : DateTime.now().difference(start).inMilliseconds;
  }

  /// Writes [message] to the developer console under [phase.devTag].
  void _log(String message, _Phase phase) {
    if (!AppSettings.enableLogging) {
      return;
    }
    dev.log('\n$message\n', name: phase.devTag);
  }
}
