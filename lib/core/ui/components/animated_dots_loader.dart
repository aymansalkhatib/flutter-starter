import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../extensions/index.dart';
import '../../routing/navigation_service.dart';

/// Customization parameters for [AnimatedDotsLoader].
class LoaderParams {
  final Color backgroundColor;
  final Color? dotColor;
  final String? loadingText;
  final double dotSize;
  final double bounceHeight;
  final double spacing;
  final TextStyle? textStyle;

  const LoaderParams({
    this.backgroundColor = Colors.black38,
    this.dotColor,
    this.loadingText,
    this.dotSize = 16.0,
    this.bounceHeight = 20.0,
    this.spacing = 8.0,
    this.textStyle,
  });
}

/// Full-screen bouncing dots loader.
///
/// Use [AnimatedDotsLoader.show] / [AnimatedDotsLoader.dismiss] to
/// display it as a non-dismissible dialog overlay.
class AnimatedDotsLoader extends StatefulWidget {
  const AnimatedDotsLoader({super.key, required this.params});

  final LoaderParams params;

  static Future<void> show(BuildContext context, [LoaderParams? params]) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AnimatedDotsLoader(params: params ?? const LoaderParams()),
    );
  }

  static void dismiss() => NavigationService.pop<void>();

  @override
  State<AnimatedDotsLoader> createState() => _AnimatedDotsLoaderState();
}

class _AnimatedDotsLoaderState extends State<AnimatedDotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _dotAnimations;

  static const int _dotCount = 3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _dotAnimations = List.generate(_dotCount, (index) {
      final start = index * 0.2;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = widget.params;
    final dotColor = params.dotColor ?? context.colors.primary;

    return PopScope(
      canPop: false,
      child: Material(
        color: params.backgroundColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (_, __) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_dotCount, (index) {
                    final bounce = math.sin(_dotAnimations[index].value * math.pi);
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: params.spacing / 2),
                      child: Transform.translate(
                        offset: Offset(0, -bounce * params.bounceHeight),
                        child: Transform.scale(
                          scale: 0.8 + bounce * 0.4,
                          child: Container(
                            width: params.dotSize,
                            height: params.dotSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dotColor,
                              boxShadow: [
                                BoxShadow(
                                  color: dotColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: bounce * 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              if (params.loadingText != null) ...[
                const SizedBox(height: 40),
                Text(
                  params.loadingText!,
                  style: params.textStyle ??
                      TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: dotColor,
                        letterSpacing: 1.2,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
