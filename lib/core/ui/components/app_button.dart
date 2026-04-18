import 'package:flutter/material.dart';

import '../../extensions/index.dart';

enum ButtonIconAlignment { start, end }

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.onPressed,
    this.text,
    this.child,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height = 50,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.color,
    this.disabledColor,
    this.foregroundColor,
    this.disabledForegroundColor,
    this.textStyle,
    this.side = BorderSide.none,
    this.elevation = 0,
    this.shadowColor,
    this.icon,
    this.iconAlignment = ButtonIconAlignment.start,
    this.iconSpacing = 8,
    this.overlayColor,
  });

  final VoidCallback? onPressed;

  /// Plain text label. Ignored if [child] is provided.
  final String? text;

  /// Fully replaces the default text+icon content.
  final Widget? child;

  final bool isLoading;
  final bool isEnabled;

  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  /// Button background color.
  final Color? color;

  /// Background color when disabled.
  final Color? disabledColor;

  /// Text / icon / ripple color.
  final Color? foregroundColor;

  /// Foreground color when disabled.
  final Color? disabledForegroundColor;

  final TextStyle? textStyle;
  final BorderSide side;
  final double elevation;
  final Color? shadowColor;

  final Widget? icon;
  final ButtonIconAlignment iconAlignment;
  final double iconSpacing;
  final Color? overlayColor;

  bool get _interactive => isEnabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final fg = foregroundColor ?? context.colors.textButtons;
    final disabledFg = disabledForegroundColor ??
        context.colors.textButtons.withValues(alpha: 0.5);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: _interactive ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? context.colors.buttonColor,
          disabledBackgroundColor: disabledColor ?? context.colors.disabled,
          foregroundColor: fg,
          disabledForegroundColor: disabledFg,
          overlayColor: overlayColor,
          shadowColor: shadowColor ?? Colors.transparent,
          padding: padding,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            side: side,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading ? _loader(fg) : _content(context, fg),
      ),
    );
  }

  Widget _loader(Color color) => SizedBox(
        width: height * 0.4,
        height: height * 0.4,
        child: CircularProgressIndicator(
          color: color,
          strokeWidth: 2,
        ),
      );

  Widget _content(BuildContext context, Color fg) {
    if (child != null) {
      return child!;
    }

    final label = text != null
        ? Text(
            text!,
            style: textStyle ?? context.styles.bold16.copyWith(color: fg),
          )
        : null;

    if (icon == null) {
      return label ?? const SizedBox.shrink();
    }

    final gap = SizedBox(width: iconSpacing);
    final items = iconAlignment == ButtonIconAlignment.start
        ? [icon!, gap, if (label != null) label]
        : [if (label != null) label, gap, icon!];

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: items,
    );
  }
}
