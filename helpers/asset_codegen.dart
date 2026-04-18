// ignore_for_file: avoid_print

import 'dart:io';

// ---------------------------------------------------------------------------
// Config
// ---------------------------------------------------------------------------

class GeneratorConfig {
  const GeneratorConfig({
    this.assetsDir = 'assets',
    this.outputDir = 'lib/generated',
    this.ignoredFolders = const {'translations', 'locales'},
  });

  final String assetsDir;
  final String outputDir;
  final Set<String> ignoredFolders;
}

// ---------------------------------------------------------------------------
// Result types
// ---------------------------------------------------------------------------

class GeneratorStats {
  int directoriesScanned = 0;
  int filesProcessed = 0;
  int classesGenerated = 0;
  final List<String> errors = [];
}

// ---------------------------------------------------------------------------
// String helpers
// ---------------------------------------------------------------------------

String _dirName(String path) => path.split(Platform.pathSeparator).last;

String _toPascalCase(String input) {
  final words = input
      .replaceAll(RegExp(r'\.[^.]+$'), '')
      .replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ')
      .split(' ')
      .where((w) => w.isNotEmpty);
  return words
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join();
}

String _toSnakeCase(String input) {
  final result = input.replaceAll(RegExp(r'[ \-]'), '_').toLowerCase();
  return RegExp(r'^\d').hasMatch(result) ? '\$$result' : result;
}

/// Returns null if [input] contains no ASCII letters or digits.
String? _toCamelCase(String input) {
  final pascal = _toPascalCase(input);
  if (pascal.isEmpty) {
    return null;
  }
  return pascal[0].toLowerCase() + pascal.substring(1);
}

String _extensionOf(File file) {
  final parts = file.path.split('.');
  return parts.length > 1 ? parts.last.toLowerCase() : '';
}

// ---------------------------------------------------------------------------
// Variable name resolver
// ---------------------------------------------------------------------------

/// Returns a map of file path → Dart variable name.
///
/// Base rule: strip the extension and use camelCase.
/// Conflict rule: if two files in the same directory share the same base name
/// (e.g. icon.svg and icon.png), append the extension in camelCase to both
/// (iconSvg, iconPng) so neither shadows the other.
Map<File, String> _resolveVariableNames(List<File> files) {
  // Group files by their base camelCase name.
  final groups = <String, List<File>>{};
  for (final file in files) {
    final base = _toCamelCase(_dirName(file.path));
    if (base == null) {
      throw FormatException(
        "[ERROR] File '${file.path}' has a non-ASCII name. "
        'Rename it using English letters only.',
      );
    }
    groups.putIfAbsent(base, () => []).add(file);
  }

  final result = <File, String>{};
  for (final entry in groups.entries) {
    final base = entry.key;
    final group = entry.value;

    if (group.length == 1) {
      // No conflict — clean name.
      result[group.first] = base;
    } else {
      // Conflict — disambiguate with extension suffix in camelCase.
      for (final file in group) {
        final ext = _extensionOf(file);
        final suffix =
            ext.isNotEmpty ? ext[0].toUpperCase() + ext.substring(1) : '';
        result[file] = '$base$suffix';
      }
    }
  }

  return result;
}

// ---------------------------------------------------------------------------
// Content builders
// ---------------------------------------------------------------------------

/// Returns true when [dir] contains no direct files (only subdirectories).
/// Such directories are treated as font-family containers.
bool _isFamiliesDirectory(Directory dir) {
  final entries = dir.listSync();
  return entries.isNotEmpty &&
      entries.every((e) => e is Directory) &&
      entries.whereType<File>().isEmpty;
}

/// Builds a class with `static const String` entries for each subfolder name.
/// Used for directories like `fonts/` that contain one sub-folder per family.
///
/// Example output:
/// ```dart
/// class AppFontFamilies {
///   const AppFontFamilies._();
///   static const String almarai = 'Almarai';
/// }
/// ```
String _buildFamiliesClass(Directory dir, String className) {
  final subdirs = dir
      .listSync()
      .whereType<Directory>()
      .where((d) => !_dirName(d.path).startsWith('.'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final familiesClassName = 'App$className';

  final buffer = StringBuffer()
    ..writeln('class $familiesClassName {')
    ..writeln(
        '  static final $familiesClassName _instance = $familiesClassName._();')
    ..writeln('  factory $familiesClassName() => _instance;')
    ..writeln('  $familiesClassName._();');

  if (subdirs.isNotEmpty) {
    buffer.writeln();
  }

  for (final subdir in subdirs) {
    final name = _dirName(subdir.path);
    final fieldName = _toCamelCase(name);
    if (fieldName == null) {
      throw FormatException(
        "[ERROR] Subfolder '$name' in '${dir.path}' has a non-ASCII name. "
        'Rename it using English letters only.',
      );
    }
    final value = _toPascalCase(name);
    buffer.writeln("  static const String $fieldName = '$value';");
  }

  buffer.writeln('}');
  return buffer.toString();
}

String _buildDirectoryClass(Directory dir, String className) {
  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => !_dirName(f.path).startsWith('.'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final varNames = _resolveVariableNames(files);

  final buffer = StringBuffer()
    ..writeln('class $className {')
    ..writeln('  static final $className _instance = $className._();')
    ..writeln('  factory $className() => _instance;')
    ..writeln('  $className._();');

  if (files.isNotEmpty) {
    buffer.writeln();
  }

  for (var i = 0; i < files.length; i++) {
    final file = files[i];
    final varName = varNames[file]!;
    final path = file.path.replaceAll(r'\', '/');
    buffer.writeln("  final String $varName = '$path';");
  }

  buffer.writeln('}');
  return buffer.toString();
}

String _buildMainAssetsClass(
  List<Directory> dirs,
  List<String> imports,
) {
  final buffer = StringBuffer();

  for (final import in imports) {
    buffer.writeln("import '$import.dart';");
  }

  buffer
    ..writeln()
    ..writeln('class AppAssets {')
    ..writeln('  static final AppAssets _instance = AppAssets._();')
    ..writeln('  factory AppAssets() => _instance;')
    ..writeln('  AppAssets._();')
    ..writeln();

  for (final dir in dirs) {
    final baseName = _toPascalCase(_dirName(dir.path));
    final fieldName = _toCamelCase(_dirName(dir.path));
    if (!_isFamiliesDirectory(dir)) {
      buffer.writeln(
        '  static final $baseName $fieldName = $baseName();',
      );
    }
  }

  buffer.writeln('}');
  return buffer.toString();
}

// ---------------------------------------------------------------------------
// Orchestrator
// ---------------------------------------------------------------------------

Future<GeneratorStats> generate([
  GeneratorConfig config = const GeneratorConfig(),
]) async {
  final stats = GeneratorStats();

  final assetsDir = Directory(config.assetsDir);
  if (!assetsDir.existsSync()) {
    stats.errors.add("Assets directory '${config.assetsDir}' does not exist.");
    return stats;
  }

  final outputDir = Directory(config.outputDir);
  outputDir.createSync(recursive: true);

  final directories = assetsDir
      .listSync()
      .whereType<Directory>()
      .where((d) => !config.ignoredFolders.contains(_dirName(d.path)))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final imports = <String>[];

  for (final dir in directories) {
    stats.directoriesScanned++;

    final className = _toPascalCase(_dirName(dir.path));
    final fileName = _toSnakeCase(_dirName(dir.path));

    final String content;
    if (_isFamiliesDirectory(dir)) {
      content = _buildFamiliesClass(dir, className);
    } else {
      final files = dir.listSync().whereType<File>().toList();
      stats.filesProcessed += files.length;
      content = _buildDirectoryClass(dir, className);
    }

    File('${outputDir.path}/$fileName.dart').writeAsStringSync(content);
    if (!_isFamiliesDirectory(dir)) {
      imports.add(fileName);
    }
    stats.classesGenerated++;

    print('[OK] Generated ${outputDir.path}/$fileName.dart');
  }

  final mainContent = _buildMainAssetsClass(directories, imports);
  File('${outputDir.path}/assets.dart').writeAsStringSync(mainContent);
  stats.classesGenerated++;

  print('[OK] Generated ${outputDir.path}/assets.dart');

  return stats;
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

Future<void> main() async {
  final startTime = DateTime.now();
  GeneratorStats stats;

  try {
    stats = await generate();
  } catch (e) {
    print('[ERROR] Generation failed: $e');
    exit(1);
  }

  if (stats.errors.isNotEmpty) {
    for (final e in stats.errors) {
      print('[ERROR] $e');
    }
    exit(1);
  }

  final duration = DateTime.now().difference(startTime);
  print(
    '\nDone in ${duration.inMilliseconds}ms — '
    '${stats.directoriesScanned} directories, '
    '${stats.filesProcessed} files, '
    '${stats.classesGenerated} classes generated.',
  );
}
