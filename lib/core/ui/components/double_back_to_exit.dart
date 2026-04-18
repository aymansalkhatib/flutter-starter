import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_genesis/generated/locale_keys.dart';

import '../../extensions/build_context_extensions.dart';

const _kDoubleBackDuration = Duration(seconds: 2);

/// Wraps a screen so that the back button must be pressed twice within
/// [_kDoubleBackDuration] to exit the app.
class DoubleBackToExit extends StatefulWidget {
  const DoubleBackToExit({super.key, required this.child});

  final Widget child;

  @override
  State<DoubleBackToExit> createState() => _DoubleBackToExitState();
}

class _DoubleBackToExitState extends State<DoubleBackToExit> {
  DateTime? _lastBackPressedTime;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        final now = DateTime.now();

        if (_lastBackPressedTime == null ||
            now.difference(_lastBackPressedTime!) > _kDoubleBackDuration) {
          _lastBackPressedTime = now;
          _showSnackBar(context);
          return;
        }

        SystemNavigator.pop();
      },
      child: widget.child,
    );
  }

  void _showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.exit_to_app, color: context.colors.iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                LocaleKeys.pressBackTwiceQuicklyToExitTheApp.tr(context),
                style: TextStyle(color: context.colors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: context.colors.primary,
        duration: _kDoubleBackDuration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
