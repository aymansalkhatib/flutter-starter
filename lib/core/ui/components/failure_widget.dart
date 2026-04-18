import 'package:flutter/material.dart';
import 'package:flutter_genesis/generated/locale_keys.dart';

import '../../errors/failure.dart';
import '../../extensions/build_context_extensions.dart';
import 'app_button.dart';

/// Displays a [Failure] with an optional retry action.
class FailureWidget extends StatefulWidget {
  const FailureWidget({
    super.key,
    required this.failure,
    this.onRetry,
    this.padding,
  });

  final Failure failure;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry? padding;

  @override
  State<FailureWidget> createState() => _FailureWidgetState();
}

class _FailureWidgetState extends State<FailureWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.12),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: widget.padding ?? const EdgeInsets.all(32),
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colors.pureBackground.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: colors.pureBackground.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon
                  Align(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.error.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 36,
                        color: colors.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    LocaleKeys.oops.tr(context),
                    style: context.styles.semiBold18.copyWith(
                      color: colors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Message
                  Text(
                    widget.failure.message.tr(context),
                    style: context.styles.regular14.copyWith(
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  if (widget.onRetry != null) ...[
                    const SizedBox(height: 28),
                    CustomButton(
                      onPressed: widget.onRetry,
                      text: LocaleKeys.tryAgain.tr(context),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
