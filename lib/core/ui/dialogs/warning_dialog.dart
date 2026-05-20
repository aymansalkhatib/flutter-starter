import 'package:flutter/material.dart';
import 'package:flutter_starter/generated/locale_keys.dart';

import '../../extensions/index.dart';
import '../../routing/navigation_service.dart';

/// Shows a warning dialog that requires explicit user action.
///
/// The dialog cannot be dismissed by tapping outside — the user must
/// either confirm or cancel.
///
/// ```dart
/// showWarningDialog(
///   context,
///   title: LocaleKeys.deleteAccount,
///   content: LocaleKeys.deleteAccountConfirmation,
///   confirmButtonText: LocaleKeys.delete,
///   onConfirm: () => cubit.deleteAccount(),
/// );
/// ```
void showWarningDialog(
  BuildContext context, {
  required String title,
  required String content,
  required String confirmButtonText,
  required VoidCallback onConfirm,
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _WarningDialog(
      title: title,
      content: content,
      confirmButtonText: confirmButtonText,
      onConfirm: onConfirm,
    ),
  );
}

class _WarningDialog extends StatelessWidget {
  const _WarningDialog({
    required this.title,
    required this.content,
    required this.confirmButtonText,
    required this.onConfirm,
  });

  final String title;
  final String content;
  final String confirmButtonText;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: context.colors.warning, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title.tr(context),
              style: context.styles.semiBold16.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        content.tr(context),
        style: context.styles.regular14.copyWith(
          color: context.colors.textSecondary,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: NavigationService.pop<void>,
          child: Text(
            LocaleKeys.cancel.tr(context),
            style: context.styles.medium14.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            NavigationService.pop<void>();
            onConfirm();
          },
          child: Text(
            confirmButtonText.tr(context),
            style: context.styles.medium14.copyWith(
              color: context.colors.error,
            ),
          ),
        ),
      ],
    );
  }
}
