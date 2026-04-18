import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../extensions/build_context_extensions.dart';

enum ButtonState { idle, loading, success, error }

// ─── Controller ───────────────────────────────────────────────────────────────

/// Controls the state of a [RoundedLoadingButton] from outside.
///
/// Must be disposed by the owner:
/// ```dart
/// final _btn = RoundedLoadingButtonController();
///
/// @override
/// void dispose() {
///   _btn.dispose();
///   super.dispose();
/// }
/// ```
class RoundedLoadingButtonController extends ChangeNotifier {
  ButtonState _state = ButtonState.idle;

  ButtonState get state => _state;

  void start() => _update(ButtonState.loading);
  void success() => _update(ButtonState.success);
  void error() => _update(ButtonState.error);
  void reset() => _update(ButtonState.idle);

  void _update(ButtonState state) {
    if (_state == state) {
      return;
    }
    _state = state;
    notifyListeners();
  }
}

// ─── Widget ───────────────────────────────────────────────────────────────────

/// An animated button that shrinks into a circle and shows success/error state.
///
/// Typical usage:
/// ```dart
/// RoundedLoadingButton(
///   controller: _controller,
///   onPressed: () async {
///     final ok = await submit();
///     ok ? _controller.success() : _controller.error();
///   },
///   child: Text('Submit'),
/// )
/// ```
class RoundedLoadingButton extends StatefulWidget {
  const RoundedLoadingButton({
    super.key,
    required this.controller,
    required this.child,
    this.onPressed,
    this.buttonColor,
    this.loaderColor,
    this.iconColor,
    this.successColor,
    this.errorColor,
    this.disabledColor,
    this.height = 50,
    this.width = 300,
    this.loaderSize = 24,
    this.loaderStrokeWidth = 2,
    this.borderRadius = 35,
    this.elevation = 2,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOutCirc,
    this.completionDuration = const Duration(milliseconds: 1000),
    this.completionCurve = Curves.elasticOut,
    this.resetDuration = const Duration(seconds: 15),
    this.animateOnTap = true,
    this.autoResetAfterDuration = false,
    this.successIcon = Icons.check,
    this.errorIcon = Icons.close,
  });

  final RoundedLoadingButtonController controller;
  final VoidCallback? onPressed;
  final Widget child;

  // ─── Colors ───────────────────────────────────────────────────────────────
  final Color? buttonColor;

  /// Color of the spinner during loading.
  final Color? loaderColor;

  /// Color of success/error icons. Defaults to white.
  final Color? iconColor;
  final Color? successColor;
  final Color? errorColor;
  final Color? disabledColor;

  // ─── Layout ───────────────────────────────────────────────────────────────
  final double height;
  final double width;
  final double loaderSize;
  final double loaderStrokeWidth;
  final double borderRadius;
  final double elevation;

  // ─── Animation ────────────────────────────────────────────────────────────
  final Duration animationDuration;
  final Curve animationCurve;
  final Duration completionDuration;
  final Curve completionCurve;

  /// How long to wait before auto-resetting (requires [autoResetAfterDuration]).
  final Duration resetDuration;

  /// If true, button auto-starts animation on tap and calls [onPressed].
  final bool animateOnTap;

  /// If true, resets automatically after [resetDuration] following success/error.
  final bool autoResetAfterDuration;

  final IconData successIcon;
  final IconData errorIcon;

  @override
  State<RoundedLoadingButton> createState() => _RoundedLoadingButtonState();
}

class _RoundedLoadingButtonState extends State<RoundedLoadingButton>
    with TickerProviderStateMixin {
  late final AnimationController _buttonController;
  late final AnimationController _borderController;
  late final AnimationController _completionController;

  late final Animation<double> _squeezeAnimation;
  late final Animation<double> _bounceAnimation;
  late final Animation<BorderRadius?> _borderAnimation;

  @override
  void initState() {
    super.initState();

    _buttonController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _borderController = AnimationController(
      duration: Duration(
        milliseconds: (widget.animationDuration.inMilliseconds / 2).round(),
      ),
      vsync: this,
    );
    _completionController = AnimationController(
      duration: widget.completionDuration,
      vsync: this,
    );

    _squeezeAnimation =
        Tween<double>(begin: widget.width, end: widget.height).animate(
          CurvedAnimation(
            parent: _buttonController,
            curve: widget.animationCurve,
          ),
        )..addListener(_rebuild);

    _bounceAnimation =
        Tween<double>(begin: 0, end: widget.height).animate(
          CurvedAnimation(
            parent: _completionController,
            curve: widget.completionCurve,
          ),
        )..addListener(_rebuild);

    _borderAnimation = BorderRadiusTween(
      begin: BorderRadius.circular(widget.borderRadius),
      end: BorderRadius.circular(widget.height / 2),
    ).animate(_borderController)..addListener(_rebuild);

    widget.controller.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onStateChanged);
    _buttonController.dispose();
    _borderController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _onStateChanged() {
    if (!mounted) {
      return;
    }
    switch (widget.controller.state) {
      case ButtonState.loading:
        _onLoading();
      case ButtonState.success:
        _onCompletion();
      case ButtonState.error:
        _onCompletion();
      case ButtonState.idle:
        _onReset();
    }
  }

  void _onLoading() {
    _borderController.forward();
    _buttonController.forward();
  }

  void _onCompletion() {
    _completionController.forward();
    if (widget.autoResetAfterDuration) {
      Future.delayed(widget.resetDuration, () {
        if (mounted) {
          widget.controller.reset();
        }
      });
    }
  }

  Future<void> _onReset() async {
    await Future.wait([
      _buttonController.reverse(),
      _borderController.reverse(),
    ]);
    if (mounted) {
      _completionController.reset();
    }
  }

  void _handlePress() {
    if (widget.controller.state != ButtonState.idle) {
      return;
    }
    if (widget.animateOnTap) {
      widget.controller.start();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = widget.controller.state;

    if (state == ButtonState.success || state == ButtonState.error) {
      return SizedBox(
        height: widget.height,
        child: Center(child: _buildCompletionCircle(state, colors)),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(_squeezeAnimation.value, widget.height),
            shape: RoundedRectangleBorder(
              borderRadius: _borderAnimation.value!,
            ),
            backgroundColor: widget.buttonColor ?? colors.buttonColor,
            elevation: widget.elevation,
            padding: EdgeInsets.zero,
            disabledBackgroundColor: widget.disabledColor,
          ),
          onPressed: widget.onPressed == null ? null : _handlePress,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: state == ButtonState.loading
                ? SizedBox(
                    key: const ValueKey('loader'),
                    width: widget.loaderSize,
                    height: widget.loaderSize,
                    child: CircularProgressIndicator(
                      strokeWidth: widget.loaderStrokeWidth,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.loaderColor ?? colors.secondary,
                      ),
                    ),
                  )
                : KeyedSubtree(
                    key: const ValueKey('child'),
                    child: widget.child,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionCircle(ButtonState state, AppColors colors) {
    final isSuccess = state == ButtonState.success;
    final size = _bounceAnimation.value;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSuccess
            ? (widget.successColor ?? colors.primary)
            : (widget.errorColor ?? colors.error),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: size > 20
          ? Icon(
              isSuccess ? widget.successIcon : widget.errorIcon,
              color: widget.iconColor ?? Colors.white,
              size: widget.loaderSize,
            )
          : null,
    );
  }
}
