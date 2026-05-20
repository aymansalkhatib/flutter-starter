import 'package:flutter/material.dart';
import 'package:flutter_starter/generated/locale_keys.dart';

class LanguageOption {
  final String label;

  final Locale? value;

  const LanguageOption({required this.label, this.value});

  /// Returns a list of all available language options.
  static List<LanguageOption> get all => [
        const LanguageOption(label: LocaleKeys.systemDefault),
        const LanguageOption(label: 'العربية', value: Locale('ar')),
        const LanguageOption(label: 'English', value: Locale('en')),
      ];
}
