import 'package:flutter/material.dart';
import 'package:flutter_starter/generated/locale_keys.dart';

import '../../extensions/build_context_extensions.dart';

/// Shows an empty-state message when [isEmpty] is true, otherwise shows [child].
class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    required this.child,
    required this.isEmpty,
    this.message,
    this.subtitle,
    this.padding,
    this.messageStyle,
    this.subtitleStyle,
  });

  final Widget child;
  final bool isEmpty;
  final String? message;
  final String? subtitle;
  final EdgeInsetsGeometry? padding;
  final TextStyle? messageStyle;
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    if (!isEmpty) {
      return child;
    }

    final colors = context.colors;

    return Padding(
      padding: padding ?? const EdgeInsets.all(32),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message ?? LocaleKeys.noItemsYet.tr(context),
              style: messageStyle ??
                  context.styles.semiBold18.copyWith(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle ?? LocaleKeys.itemsYouAddWillAppearHere.tr(context),
              style: subtitleStyle ??
                  context.styles.regular14.copyWith(
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
