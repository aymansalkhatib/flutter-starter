// core/models/theme_option.dart
import 'package:flutter/material.dart';
import 'package:flutter_genesis/generated/locale_keys.dart';

class ThemeOption {
  final String label;
  final ThemeMode value;
  final IconData icon;

  const ThemeOption({
    required this.label,
    required this.value,
    required this.icon,
  });

  static List<ThemeOption> get all => [
        const ThemeOption(
          label: LocaleKeys.systemDefault,
          value: ThemeMode.system,
          icon: Icons.settings_suggest,
        ),
        const ThemeOption(
          label: LocaleKeys.light,
          value: ThemeMode.light,
          icon: Icons.wb_sunny,
        ),
        const ThemeOption(
          label: LocaleKeys.dark,
          value: ThemeMode.dark,
          icon: Icons.nights_stay,
        ),
      ];
}
