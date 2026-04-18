import 'package:flutter/material.dart';

import '../../di/service_locator.dart';
import '../../extensions/build_context_extensions.dart';
import '../../extensions/string_translation_extension.dart';
import '../../utils/app_logger.dart';
import 'overlay_snackbar.dart';

/// Shows a snackbar using [ScaffoldMessenger].
///
/// Requires a [Scaffold] ancestor in the widget tree.
/// For snackbars outside Scaffold context, use [showOverlaySnackbar] instead.
///
/// Example:
/// ```dart
/// showSnackbar('Saved successfully', type: OverlaySnackbarType.success);
/// ```
void showSnackbar(
  String message, {
  OverlaySnackbarType type = OverlaySnackbarType.info,
  Duration duration = const Duration(seconds: 3),
  String? actionLabel,
  VoidCallback? onAction,
  bool isFloating = true,
  double elevation = 6,
}) {
  final context = sl<GlobalKey<NavigatorState>>().currentContext;

  if (context == null) {
    AppLogger.info(
      'showSnackbar: context is not available',
      tag: 'Snackbar',
    );
    return;
  }

  final messenger = ScaffoldMessenger.maybeOf(context);

  if (messenger == null) {
    AppLogger.info(
      'showSnackbar: No Scaffold found — use showOverlaySnackbar instead',
      tag: 'Snackbar',
    );
    return;
  }

  final appColors = context.colors;

  final backgroundColor = switch (type) {
    OverlaySnackbarType.success => appColors.success,
    OverlaySnackbarType.error   => appColors.error,
    OverlaySnackbarType.warning => appColors.warning,
    OverlaySnackbarType.info    => appColors.primary,
  };

  final icon = switch (type) {
    OverlaySnackbarType.success => Icons.check_circle_rounded,
    OverlaySnackbarType.error   => Icons.error_rounded,
    OverlaySnackbarType.warning => Icons.warning_amber_rounded,
    OverlaySnackbarType.info    => Icons.info_rounded,
  };

  final textColor =
      backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: isFloating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
        margin: isFloating ? const EdgeInsets.all(16) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isFloating ? 8 : 0),
        ),
        backgroundColor: backgroundColor,
        elevation: elevation,
        duration: duration,
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message.tr(context),
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                onPressed: onAction,
                textColor: textColor,
              )
            : null,
      ),
    );
}
