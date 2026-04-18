// ignore_for_file: avoid_print

import 'dart:io';

// ---------------------------------------------------------------------------
// Config
// ---------------------------------------------------------------------------

class CheckerConfig {
  const CheckerConfig({
    this.assetsPath = 'lib/generated',
    this.searchPath = 'lib/',
    this.fileExtensions = const {'.dart'},
    this.ignoredFiles = const {'assets.dart'},
    this.ignoredDirectories = const {'ignore_this_folder'},
  });

  final String assetsPath;
  final String searchPath;
  final Set<String> fileExtensions;
  final Set<String> ignoredFiles;
  final Set<String> ignoredDirectories;
}

// ---------------------------------------------------------------------------
// Result types
// ---------------------------------------------------------------------------

class CheckerStats {
  int variablesFound = 0;
  int usedCount = 0;
  int unusedCount = 0;
  final List<String> ioErrors = [];
  final List<String> warnings = [];
}

class CheckerResult {
  CheckerResult({
    required this.used,
    required this.unused,
    required this.stats,
    required this.duration,
  });

  final List<String> used;
  final List<String> unused;
  final CheckerStats stats;
  final Duration duration;

  bool get hasIoErrors => stats.ioErrors.isNotEmpty;
}

// ---------------------------------------------------------------------------
// File helpers
// ---------------------------------------------------------------------------

bool _isIncluded(File file, CheckerConfig config) {
  final name = file.uri.pathSegments.last;
  final ext = '.${name.split('.').last}';

  if (config.ignoredFiles.contains(name)) {
    return false;
  }
  if (!config.fileExtensions.contains(ext)) {
    return false;
  }
  if (config.ignoredDirectories.any((d) => file.path.contains('/$d/'))) {
    return false;
  }
  return true;
}

/// Reads all eligible files into memory in one pass.
/// Returns a map of path → content. IO errors are recorded in [stats].
Future<Map<String, String>> _readFiles(
  String directoryPath,
  CheckerConfig config,
  CheckerStats stats,
) async {
  final dir = Directory(directoryPath);
  final result = <String, String>{};

  await for (final entity in dir.list(recursive: true)) {
    if (entity is! File) {
      continue;
    }
    if (!_isIncluded(entity, config)) {
      continue;
    }

    try {
      result[entity.path] = await entity.readAsString();
    } catch (e) {
      stats.ioErrors.add('Could not read ${entity.path}: $e');
    }
  }

  return result;
}

// ---------------------------------------------------------------------------
// Variable extraction
// ---------------------------------------------------------------------------

/// Extracts `ClassName.variableName` pairs from asset files.
/// Handles multiple classes per file correctly.
List<String> _extractVariables(
  Map<String, String> fileContents,
  CheckerStats stats,
) {
  final variables = <String>[];

  // Matches: static const String varName = '...'  OR  final String varName = '...'
  final varPattern = RegExp(
    r"""(?:static\s+const|final)\s+String\s+(\w+)\s*=\s*'[^']+'""",
  );

  // Matches: class ClassName { ... }  (captures class name and its body start)
  final classPattern = RegExp(r'class\s+(\w+)\s*\{');

  for (final entry in fileContents.entries) {
    final content = entry.value;

    // Find all class declarations in the file.
    final classMatches = classPattern.allMatches(content).toList();
    if (classMatches.isEmpty) {
      continue;
    }

    // For each class, determine its span: from its opening brace to the start
    // of the next class (or end of file). This avoids mixing variables from
    // different classes.
    for (var i = 0; i < classMatches.length; i++) {
      final classMatch = classMatches[i];
      final className = classMatch.group(1)!;
      final bodyStart = classMatch.end;
      final bodyEnd = i + 1 < classMatches.length
          ? classMatches[i + 1].start
          : content.length;

      final classBody = content.substring(bodyStart, bodyEnd);

      for (final varMatch in varPattern.allMatches(classBody)) {
        final varName = varMatch.group(1)!;
        variables.add('$className.$varName');
        stats.variablesFound++;
      }
    }
  }

  return variables;
}

// ---------------------------------------------------------------------------
// Usage check — single pass over all files
// ---------------------------------------------------------------------------

/// Checks which variables are used across the project.
///
/// Reads each source file exactly once and checks all variables against it.
/// Complexity: O(files + variables × average-file-length) which in practice
/// is dramatically faster than the naive O(files × variables) approach.
Map<String, bool> _checkVariableUsage(
  List<String> variables,
  Map<String, String> sourceContents,
  CheckerStats stats,
) {
  // Start with all variables marked unused.
  final results = {for (final v in variables) v: false};

  // Track which variables are still unresolved to avoid re-checking resolved
  // ones in subsequent files.
  final unresolved = Set<String>.from(variables);

  for (final content in sourceContents.values) {
    if (unresolved.isEmpty) {
      break;
    }

    final resolved = <String>{};
    for (final variable in unresolved) {
      // Only match the exact full reference: ClassName.variableName
      if (content.contains(variable)) {
        results[variable] = true;
        resolved.add(variable);
        stats.usedCount++;
      }
    }
    unresolved.removeAll(resolved);
  }

  stats.unusedCount = unresolved.length;
  return results;
}

// ---------------------------------------------------------------------------
// Orchestrator
// ---------------------------------------------------------------------------

Future<CheckerResult> runCheck(
    [CheckerConfig config = const CheckerConfig()]) async {
  final stats = CheckerStats();
  final startTime = DateTime.now();

  // 1. Validate directories.
  final assetsDir = Directory(config.assetsPath);
  if (!assetsDir.existsSync()) {
    stats.ioErrors
        .add("Assets directory '${config.assetsPath}' does not exist.");
    return CheckerResult(
      used: [],
      unused: [],
      stats: stats,
      duration: DateTime.now().difference(startTime),
    );
  }

  final searchDir = Directory(config.searchPath);
  if (!searchDir.existsSync()) {
    stats.ioErrors
        .add("Search directory '${config.searchPath}' does not exist.");
    return CheckerResult(
      used: [],
      unused: [],
      stats: stats,
      duration: DateTime.now().difference(startTime),
    );
  }

  // 2. Read all relevant files once — assets for extraction, sources for search.
  final assetContents = await _readFiles(config.assetsPath, config, stats);
  final sourceContents = await _readFiles(config.searchPath, config, stats);

  // 3. Extract variable references from asset files.
  final variables = _extractVariables(assetContents, stats);

  // 4. Check usage across the entire source tree in a single pass.
  final results = _checkVariableUsage(variables, sourceContents, stats);

  final used = results.entries.where((e) => e.value).map((e) => e.key).toList()
    ..sort();

  final unused =
      results.entries.where((e) => !e.value).map((e) => e.key).toList()..sort();

  return CheckerResult(
    used: used,
    unused: unused,
    stats: stats,
    duration: DateTime.now().difference(startTime),
  );
}

// ---------------------------------------------------------------------------
// Reporting
// ---------------------------------------------------------------------------

void _printReport(CheckerResult result) {
  final s = result.stats;

  if (result.used.isNotEmpty) {
    print('\nUsed (${result.used.length}):');
    for (final v in result.used) {
      print('  + $v');
    }
  }

  if (result.unused.isNotEmpty) {
    print('\nUnused (${result.unused.length}):');
    for (final v in result.unused) {
      print('  - $v');
    }
  }

  if (s.ioErrors.isNotEmpty) {
    print('\nI/O errors (${s.ioErrors.length}):');
    for (final e in s.ioErrors) {
      print('  [error] $e');
    }
  }

  if (s.warnings.isNotEmpty) {
    print('\nWarnings (${s.warnings.length}):');
    for (final w in s.warnings) {
      print('  [warn] $w');
    }
  }

  print(
    '\nDone in ${result.duration.inMilliseconds}ms — '
    '${s.variablesFound} variables found, '
    '${s.usedCount} used, '
    '${s.unusedCount} unused.',
  );
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

Future<void> main() async {
  CheckerResult result;

  try {
    result = await runCheck();
  } catch (e) {
    print('[ERROR] Unexpected failure: $e');
    exit(1);
  }

  _printReport(result);

  if (result.hasIoErrors) {
    exit(1);
  }
}
