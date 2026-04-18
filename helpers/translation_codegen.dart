// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

// ---------------------------------------------------------------------------
// Config
// ---------------------------------------------------------------------------

class ScriptConfig {
  const ScriptConfig({
    this.translationsDirectory = 'assets/locales/',
    this.masterTranslationsFile = 'assets/translations/translations.json',
    this.localeKeysFile = 'lib/generated/locale_keys.dart',
    this.exportStatement =
        "export '../core/extensions/string_translation_extension.dart';",
  });

  final String translationsDirectory;
  final String masterTranslationsFile;
  final String localeKeysFile;
  final String exportStatement;
}

// ---------------------------------------------------------------------------
// Result types
// ---------------------------------------------------------------------------

class ValidationResult {
  ValidationResult({
    required this.cleanedKeys,
    required this.errors,
    required this.warnings,
    required this.availableLanguages,
  });

  final Map<String, String> cleanedKeys;
  final List<String> errors;
  final List<String> warnings;
  final List<String> availableLanguages;

  bool get hasErrors => errors.isNotEmpty;
}

// ---------------------------------------------------------------------------
// Key validators
// ---------------------------------------------------------------------------

bool _isValidKey(String key) {
  if (RegExp(r'^\d+$').hasMatch(key)) {
    return true;
  }
  if (RegExp(r'^[a-zA-Z][a-zA-Z0-9_\s\-]*$').hasMatch(key)) {
    return true;
  }
  return false;
}

// ---------------------------------------------------------------------------
// Key cleaning
// ---------------------------------------------------------------------------

const _reservedWords = <String>{
  'if',
  'else',
  'for',
  'while',
  'class',
  'return',
  'void',
  'int',
  'double',
  'var',
  'final',
  'const',
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'break',
  'case',
  'catch',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'enum',
  'export',
  'extension',
  'external',
  'factory',
  'false',
  'get',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'on',
  'operator',
  'part',
  'rethrow',
  'set',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'with',
  'yield',
};

String? tryCleanKey(String key, String value) {
  String result;

  if (RegExp(r'^\d+$').hasMatch(key)) {
    final sanitized = value
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (sanitized.isEmpty) {
      return null;
    }

    final words = sanitized.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) {
      return null;
    }

    final pascal = words
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join();

    if (pascal.isEmpty) {
      return null;
    }
    result = pascal[0].toLowerCase() + pascal.substring(1);
  } else {
    if (key.isEmpty) {
      return null;
    }
    result = key[0].toLowerCase() + key.substring(1);
  }

  if (_reservedWords.contains(result)) {
    result = '${result}_';
  } else if (result.isNotEmpty && RegExp(r'^\d').hasMatch(result[0])) {
    result = 'sn_$result';
  }

  return result.isEmpty ? null : result;
}

// ---------------------------------------------------------------------------
// Validation pass
// ---------------------------------------------------------------------------

ValidationResult validateTranslations(Map<String, dynamic> json) {
  final cleanedKeys = <String, String>{};
  final seenCleaned = <String, String>{};
  final errors = <String>[];
  final warnings = <String>[];

  if (json.isEmpty) {
    errors.add('Translations file is empty.');
    return ValidationResult(
      cleanedKeys: cleanedKeys,
      errors: errors,
      warnings: warnings,
      availableLanguages: [],
    );
  }

  final firstEntry = json.values.first;
  if (firstEntry is! Map<String, dynamic>) {
    errors.add('First entry value is not a JSON object.');
    return ValidationResult(
      cleanedKeys: cleanedKeys,
      errors: errors,
      warnings: warnings,
      availableLanguages: [],
    );
  }

  final expectedLanguages = firstEntry.keys.toSet();

  if (!expectedLanguages.contains('en')) {
    errors.add(
      "Language 'en' is required as the base for key generation but was not found. "
      "Found languages: ${expectedLanguages.join(', ')}.",
    );
    return ValidationResult(
      cleanedKeys: cleanedKeys,
      errors: errors,
      warnings: warnings,
      availableLanguages: [],
    );
  }

  for (final entry in json.entries) {
    final key = entry.key;
    final value = entry.value;

    if (!_isValidKey(key)) {
      errors.add(
        "[key: '$key'] Invalid key format — must be digits only, or start with "
        r'an ASCII letter and contain only [a-zA-Z0-9_\s-]. '
        'Arabic or mixed-language keys are not allowed.',
      );
      continue;
    }

    if (value is! Map<String, dynamic>) {
      errors.add(
        "[key: '$key'] Value is not a JSON object, got: ${value.runtimeType}.",
      );
      continue;
    }

    final actualLanguages = value.keys.toSet();
    if (actualLanguages.length != expectedLanguages.length ||
        !actualLanguages.containsAll(expectedLanguages)) {
      final missing = expectedLanguages.difference(actualLanguages);
      final extra = actualLanguages.difference(expectedLanguages);
      final detail = [
        if (missing.isNotEmpty) 'missing languages: [${missing.join(', ')}]',
        if (extra.isNotEmpty) 'extra languages: [${extra.join(', ')}]',
      ].join(' | ');
      errors.add(
        "[key: '$key'] Language set mismatch — "
        "expected [${expectedLanguages.join(', ')}]. $detail.",
      );
      continue;
    }

    var hasEmptyField = false;
    for (final lang in expectedLanguages) {
      final translation = value[lang];
      if (translation == null) {
        errors.add("[key: '$key'] [$lang] Translation is null.");
        hasEmptyField = true;
      } else if (translation is! String) {
        errors.add(
          "[key: '$key'] [$lang] Translation must be a String, "
          'got: ${translation.runtimeType}.',
        );
        hasEmptyField = true;
      } else if (translation.trim().isEmpty) {
        errors.add(
          "[key: '$key'] [$lang] Translation is empty or whitespace only.",
        );
        hasEmptyField = true;
      }
    }
    if (hasEmptyField) {
      continue;
    }

    final enValue = value['en'] as String;
    final cleaned = tryCleanKey(key, enValue);
    if (cleaned == null) {
      errors.add(
        "[key: '$key'] Could not generate a valid Dart identifier from "
        "English value '$enValue'. "
        'The value may be empty or contain only special characters.',
      );
      continue;
    }

    if (seenCleaned.containsKey(cleaned)) {
      warnings.add(
        "[key: '$key'] Produces duplicate Dart identifier '$cleaned' "
        "(already produced by key '${seenCleaned[cleaned]}').",
      );
    } else {
      seenCleaned[cleaned] = key;
    }

    cleanedKeys[key] = cleaned;
  }

  return ValidationResult(
    cleanedKeys: cleanedKeys,
    errors: errors,
    warnings: warnings,
    availableLanguages: expectedLanguages.toList(),
  );
}

// ---------------------------------------------------------------------------
// Content builders
// ---------------------------------------------------------------------------

String buildLanguageFileContent(
  String languageCode,
  Map<String, String> cleanedKeys,
  Map<String, dynamic> json,
) {
  final map = <String, String>{};
  for (final entry in json.entries) {
    final originalKey = entry.key;
    final value = entry.value as Map<String, dynamic>;
    final cleanedKey = cleanedKeys[originalKey];
    if (cleanedKey == null) {
      continue;
    }

    final translation = value[languageCode];
    if (translation is String) {
      map[cleanedKey] = translation;
    }
  }
  return jsonEncode(map);
}

String buildLocaleKeysFile(
  Map<String, String> cleanedKeys,
  String exportStatement,
) {
  final buffer = StringBuffer()
    ..write('$exportStatement\n\n')
    ..write('abstract class LocaleKeys {\n  //\n');

  for (final cleaned in cleanedKeys.values) {
    buffer.write("  static const String $cleaned = '$cleaned';\n\n");
  }

  buffer.write('}\n');
  return buffer.toString();
}

// ---------------------------------------------------------------------------
// File writing with atomic rollback
// ---------------------------------------------------------------------------

Future<void> ensureDirectory(String path) async {
  final dir = Directory(path);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
}

Future<void> writeFilesAtomically({
  required Map<String, String> tmpToFinal,
  required Map<String, String> contents,
}) async {
  final writtenTmp = <File>[];

  try {
    for (final entry in tmpToFinal.entries) {
      final tmpPath = entry.key;
      final finalPath = entry.value;
      final content = contents[finalPath]!;

      await ensureDirectory(File(tmpPath).parent.path);

      final tmpFile = File(tmpPath);
      final sink = tmpFile.openWrite();
      try {
        sink.write(content);
      } finally {
        await sink.close();
      }

      writtenTmp.add(tmpFile);
    }

    for (final entry in tmpToFinal.entries) {
      await File(entry.key).rename(entry.value);
    }
  } catch (e) {
    for (final tmp in writtenTmp) {
      if (tmp.existsSync()) {
        tmp.deleteSync();
      }
    }
    rethrow;
  }
}

// ---------------------------------------------------------------------------
// Orchestrator
// ---------------------------------------------------------------------------

Future<bool> generateLanguageFiles(
  Map<String, dynamic> json,
  ScriptConfig config,
) async {
  final validation = validateTranslations(json);

  if (validation.warnings.isNotEmpty) {
    print('\nWarnings (${validation.warnings.length}):');
    for (final w in validation.warnings) {
      print('  [WARN]  $w');
    }
  }

  if (validation.hasErrors) {
    print('\nValidation errors (${validation.errors.length}):');
    for (final e in validation.errors) {
      print('  [ERROR] $e');
    }
    return false;
  }

  final finalToContent = <String, String>{};

  for (final lang in validation.availableLanguages) {
    final path = '${config.translationsDirectory}$lang.json';
    finalToContent[path] = buildLanguageFileContent(
      lang,
      validation.cleanedKeys,
      json,
    );
  }

  finalToContent[config.localeKeysFile] = buildLocaleKeysFile(
    validation.cleanedKeys,
    config.exportStatement,
  );

  final tmpToFinal = {
    for (final path in finalToContent.keys) '$path.tmp': path,
  };

  await writeFilesAtomically(
    tmpToFinal: tmpToFinal,
    contents: finalToContent,
  );

  return true;
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

Future<void> main() async {
  const config = ScriptConfig();
  Map<String, dynamic> json;

  try {
    final raw = await File(config.masterTranslationsFile).readAsString();
    json = jsonDecode(raw) as Map<String, dynamic>;
  } catch (e) {
    print(
      '[ERROR] Could not read translations file: ${config.masterTranslationsFile}\n'
      '        Reason: $e',
    );
    exit(1);
  }

  bool success;
  try {
    success = await generateLanguageFiles(json, config);
  } catch (e) {
    print(
      '[ERROR] File generation failed — all changes rolled back.\n'
      '        Reason: $e',
    );
    exit(1);
  }

  if (!success) {
    print(
        '\n[FAILED] No files were written. Fix the errors above and try again.');
    exit(1);
  }

  print('\n[OK] Translation files generated successfully.');
}
