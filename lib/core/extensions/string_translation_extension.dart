import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

/// Adds `.tr(context)` shorthand for translating localization keys.
///
/// ```dart
/// 'welcome'.tr(context)
/// 'greeting'.tr(context, args: {'name': 'Ayman'})  // replaces {{name}}
/// ```
extension TranslationExtension on String {
  String tr(BuildContext context, {Map<String, dynamic>? args}) {
    final localizations = AppLocalizations.of(context);

    if (localizations == null) {
      throw StateError(
        'AppLocalizations not found. '
        'Ensure the widget tree includes a localization provider.',
      );
    }

    var translated = localizations.translate(this);

    if (args != null && args.isNotEmpty) {
      args.forEach((key, value) {
        translated = translated.replaceAll(
          '{{${key.trim()}}}',
          value?.toString().trim() ?? '',
        );
      });
    }

    return translated;
  }
}
