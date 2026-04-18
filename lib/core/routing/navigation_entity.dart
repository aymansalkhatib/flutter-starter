import 'package:flutter/material.dart';

/// Represents a single item in the bottom navigation bar.
class NavigationEntity {
  final int index;
  final IconData icon;
  final String label;
  final Widget screen;
  final bool displayAppBar;

  const NavigationEntity({
    required this.index,
    required this.icon,
    required this.label,
    required this.screen,
    this.displayAppBar = true,
  });
}
