import 'dart:async';

import 'package:flutter/material.dart';

import '../../di/service_locator.dart';
import '../../extensions/build_context_extensions.dart';
import '../../extensions/string_translation_extension.dart';
import '../../utils/app_logger.dart';

enum OverlaySnackbarType { success, error, warning, info }

enum OverlaySnackbarPosition { top, bottom }

/// Shows a floating overlay snackbar outside the Scaffold context.
///
/// Use [OverlaySnackbarType] to control the style.
/// Use [OverlaySnackbarPosition] to control placement (top/bottom).
///
/// Example:
/// ```dart
/// showOverlaySnackbar('Operation successful', type: OverlaySnackbarType.success);
/// ```
void showOverlaySnackbar(
  String message, {
  OverlaySnackbarType type = OverlaySnackbarType.info,
  OverlaySnackbarPosition position = OverlaySnackbarPosition.top,
  Duration duration = const Duration(seconds: 3),
  String? actionLabel,
  VoidCallback? onAction,
  double horizontalMargin = 16.0,
  double verticalOffset = 16.0,
  double elevation = 6,
  bool isFloating = true,
}) {
  final navigatorKey = sl<GlobalKey<NavigatorState>>();
  final context = navigatorKey.currentContext;

  final overlay = context != null
      ? (Navigator.of(context, rootNavigator: true).overlay ?? Overlay.of(context))
      : null;

  if (overlay != null) {
    _insertOverlayEntry(
      overlay,
      message,
      type: type,
      position: position,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      horizontalMargin: horizontalMargin,
      verticalOffset: verticalOffset,
      elevation: elevation,
      isFloating: isFloating,
    );
    return;
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final deferredContext = navigatorKey.currentContext;
    final deferredOverlay = deferredContext != null
        ? (Navigator.of(deferredContext, rootNavigator: true).overlay ??
            Overlay.of(deferredContext))
        : null;

    if (deferredOverlay != null) {
      _insertOverlayEntry(
        deferredOverlay,
        message,
        type: type,
        position: position,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
        horizontalMargin: horizontalMargin,
        verticalOffset: verticalOffset,
        elevation: elevation,
        isFloating: isFloating,
      );
    } else {
      AppLogger.info(
        'showOverlaySnackbar: No overlay found',
        tag: 'OverlaySnackbar',
      );
    }
  });
}

// ─────────────────────────────────────────────
// Internal
// ─────────────────────────────────────────────

void _insertOverlayEntry(
  OverlayState overlay,
  String message, {
  required OverlaySnackbarType type,
  required OverlaySnackbarPosition position,
  required Duration duration,
  required double horizontalMargin,
  required double verticalOffset,
  required double elevation,
  required bool isFloating,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final appColors = overlay.context.colors;

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

  final isTop = position == OverlaySnackbarPosition.top;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      final padding = MediaQuery.paddingOf(context);
      final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

      return Positioned(
        top: isTop ? verticalOffset + padding.top : null,
        bottom: isTop ? null : verticalOffset + (keyboardHeight > 0 ? keyboardHeight : padding.bottom),
        left: horizontalMargin,
        right: horizontalMargin,
        child: _SnackbarAnimation(
          isTop: isTop,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(isFloating ? 8 : 0),
                boxShadow: [
                  if (elevation > 0)
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: elevation,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
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
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        onAction();
                        if (entry.mounted) {
                          entry.remove();
                        }
                      },
                      child: Text(
                        actionLabel,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: textColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(entry);

  Timer(duration, () {
    if (entry.mounted) {
      entry.remove();
    }
  });
}

// ─────────────────────────────────────────────
// Animation Widget
// ─────────────────────────────────────────────

class _SnackbarAnimation extends StatefulWidget {
  final Widget child;
  final bool isTop;

  const _SnackbarAnimation({required this.child, required this.isTop});

  @override
  State<_SnackbarAnimation> createState() => _SnackbarAnimationState();
}

class _SnackbarAnimationState extends State<_SnackbarAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.isTop ? -1.0 : 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _slideAnimation, child: widget.child);
  }
}
