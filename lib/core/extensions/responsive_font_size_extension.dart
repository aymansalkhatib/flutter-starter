import 'package:flutter/widgets.dart';

/// Responsive font sizing extension.
///
/// Scales font sizes linearly based on screen width relative to a 400px baseline.
///
/// | Screen width  | Scale range  |
/// |---------------|--------------|
/// | ≤ 300px       | 0.85 (min)   |
/// | 300 – 400px   | 0.85 → 1.0   |
/// | 400px         | 1.0          |
/// | 400 – 800px   | 1.0 → 1.3    |
/// | ≥ 800px       | 1.3 (max)    |
///
/// ```dart
/// Text('Hello', style: TextStyle(fontSize: 16.sp(context)))
/// ```
extension ResponsiveFontSize on num {
  double sp(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final scale = width <= 400
        ? _lerp(width.clamp(300.0, 400.0), 300.0, 400.0, 0.85, 1.0)
        : _lerp(width.clamp(400.0, 800.0), 400.0, 800.0, 1.0, 1.3);

    return toDouble() * scale;
  }
}

/// Linear interpolation: maps [value] from [inMin..inMax] to [outMin..outMax].
double _lerp(
  double value,
  double inMin,
  double inMax,
  double outMin,
  double outMax,
) {
  return outMin + (value - inMin) / (inMax - inMin) * (outMax - outMin);
}
