import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../extensions/index.dart';
import '../../themes/app_theme_manager.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.titleStyle,
    this.titlePadding = const EdgeInsets.symmetric(horizontal: 16),
    this.centerTitle = true,
    this.leading,
    this.leadingWidth,
    this.automaticallyImplyLeading = true,
    this.actions,
    this.bottom,
    this.backgroundColor,
    this.gradient,
    this.elevation = 1.0,
    this.shadowColor,
    this.systemOverlayStyle,
  });

  /// Plain text title. Ignored if [titleWidget] is provided.
  final String? title;

  /// Replaces the default text title entirely.
  final Widget? titleWidget;

  final TextStyle? titleStyle;
  final EdgeInsets titlePadding;
  final bool centerTitle;
  final Widget? leading;
  final double? leadingWidth;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;

  /// When set, [backgroundColor] is ignored and the gradient fills the app bar.
  final Gradient? gradient;

  final double elevation;
  final Color? shadowColor;
  final SystemUiOverlayStyle? systemOverlayStyle;

  @override
  Widget build(BuildContext context) {
    final resolvedBg = gradient != null
        ? Colors.transparent
        : (backgroundColor ?? context.colors.scaffoldBackground);

    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: resolvedBg,
      elevation: elevation,
      shadowColor: shadowColor ?? Colors.black12,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      leadingWidth: leadingWidth,
      title: titleWidget ??
          (title != null
              ? Padding(
                  padding: titlePadding,
                  child: Text(
                    title!,
                    style: titleStyle ??
                        context.styles.bold20.copyWith(
                          color: context.colors.textPrimary,
                        ),
                  ),
                )
              : null),
      actions: actions,
      bottom: bottom,
      systemOverlayStyle:
          systemOverlayStyle ?? AppThemeManager.setSystemUIOverlayStyle(context),
      flexibleSpace: gradient != null
          ? Container(decoration: BoxDecoration(gradient: gradient))
          : null,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
