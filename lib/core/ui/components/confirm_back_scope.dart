import 'package:flutter/material.dart';
import 'package:flutter_genesis/generated/locale_keys.dart';

import '../../routing/navigation_service.dart';
import '../dialogs/warning_dialog.dart';

/// Wraps a widget with a back-navigation confirmation dialog.
///
/// When the user tries to navigate back, a warning dialog is shown.
/// If confirmed, [onConfirm] is called (defaults to a simple pop).
///
/// ```dart
/// ConfirmBackScope(
///   onConfirm: () => NavigationService.clearAndPush(AppRoute.loginScreen),
///   child: MyFormScreen(),
/// )
/// ```
class ConfirmBackScope extends StatelessWidget {
  const ConfirmBackScope({
    super.key,
    required this.child,
    this.onConfirm,
  });

  final Widget child;

  /// Called after the user confirms going back.
  /// Defaults to [NavigationService.pop] if not provided.
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _showConfirmDialog(context);
        }
      },
      child: child,
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showWarningDialog(
      context,
      title: LocaleKeys.loseProgress,
      content: LocaleKeys.goingBackWillLoseYourCurrentProgressContinue,
      confirmButtonText: LocaleKeys.goBack,
      onConfirm: onConfirm ?? NavigationService.pop<void>,
    );
  }
}
