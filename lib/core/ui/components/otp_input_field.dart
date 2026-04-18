import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../extensions/build_context_extensions.dart';
import '../../utils/validator.dart';

// ─── OTP Manager ──────────────────────────────────────────────────────────────

/// Manages state and logic for [OTPInputField].
///
/// Must be disposed by the owner (usually the parent widget/page):
/// ```dart
/// final _otpManager = OTPManager(6);
///
/// @override
/// void dispose() {
///   _otpManager.dispose();
///   super.dispose();
/// }
/// ```
class OTPManager {
  OTPManager(this.length)
      : focusNodes = List.generate(length, (_) => FocusNode()),
        controllers = List.generate(length, (_) => TextEditingController()),
        parentFocusNode = FocusNode(),
        formKey = GlobalKey<FormState>();

  final int length;
  final List<FocusNode> focusNodes;
  final List<TextEditingController> controllers;
  final FocusNode parentFocusNode;
  final GlobalKey<FormState> formKey;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  /// The current OTP code assembled from all fields.
  String get otpCode => controllers.map((c) => c.text).join();

  bool get isComplete => otpCode.length == length;

  String valueAt(int index) => controllers[index].text;

  void handleFocusChange(int index, FocusNode node) {
    if (node.hasFocus) {
      _currentIndex = index;
      controllers[index].selection = TextSelection.collapsed(
        offset: controllers[index].text.length,
      );
    }
  }

  void handleKeyEvent(KeyEvent event, BuildContext context) {
    if (event is! KeyDownEvent) {
      return;
    }
    if (!HardwareKeyboard.instance.isLogicalKeyPressed(
      LogicalKeyboardKey.backspace,
    )) {
      return;
    }

    final scope = FocusScope.of(context);
    if (scope.focusedChild != null &&
        controllers[_currentIndex].text.isEmpty &&
        _currentIndex != 0) {
      scope.previousFocus();
    }
  }

  void dispose() {
    for (final node in focusNodes) {
      node.dispose();
    }
    for (final controller in controllers) {
      controller.dispose();
    }
    parentFocusNode.dispose();
  }
}

// ─── OTP Input Field ──────────────────────────────────────────────────────────

/// A row of single-digit fields for OTP entry.
///
/// The [otpManager] must be created and disposed by the caller.
class OTPInputField extends StatefulWidget {
  const OTPInputField({
    super.key,
    required this.otpManager,
    this.onOtpChanged,
    this.fieldWidth = 55,
    this.fieldHeight = 55,
    this.spacing = 10,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.borderWidth = 1,
    this.borderStyle = BorderStyle.solid,
    this.textStyle,
    this.cursorColor,
    this.fillColor,
    this.isFilled = false,
    this.focusedBorderColor,
    this.enabledBorderColor,
    this.defaultBorderColor,
    this.errorBorderColor,
    this.disabledBorderColor,
    this.focusedErrorBorderColor,
    this.selectionHighlightColor,
    this.selectionHandleColor,
    this.keyboardType = TextInputType.number,
    this.isReadOnly = false,
    this.showCursor = true,
    this.obscureText = false,
    this.contentPadding,
  });

  final OTPManager otpManager;
  final void Function(String)? onOtpChanged;

  // ─── Layout ───────────────────────────────────────────────────────────────
  final double fieldWidth;
  final double fieldHeight;
  final double spacing;
  final BorderRadius borderRadius;
  final double borderWidth;
  final BorderStyle borderStyle;

  // ─── Styling ──────────────────────────────────────────────────────────────
  final TextStyle? textStyle;
  final Color? cursorColor;
  final Color? fillColor;
  final bool isFilled;
  final Color? focusedBorderColor;
  final Color? enabledBorderColor;
  final Color? defaultBorderColor;
  final Color? errorBorderColor;
  final Color? disabledBorderColor;
  final Color? focusedErrorBorderColor;
  final Color? selectionHighlightColor;
  final Color? selectionHandleColor;
  final EdgeInsetsGeometry? contentPadding;

  // ─── Behavior ─────────────────────────────────────────────────────────────
  final TextInputType keyboardType;
  final bool isReadOnly;
  final bool showCursor;
  final bool obscureText;

  @override
  State<OTPInputField> createState() => _OTPInputFieldState();
}

class _OTPInputFieldState extends State<OTPInputField> {
  late final List<VoidCallback> _focusListeners;

  @override
  void initState() {
    super.initState();
    _focusListeners = List.generate(widget.otpManager.length, (i) {
      final node = widget.otpManager.focusNodes[i];
      void listener() => widget.otpManager.handleFocusChange(i, node);
      node.addListener(listener);
      return listener;
    });
  }

  @override
  void dispose() {
    for (int i = 0; i < _focusListeners.length; i++) {
      widget.otpManager.focusNodes[i].removeListener(_focusListeners[i]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buildTheme(context),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: KeyboardListener(
          focusNode: widget.otpManager.parentFocusNode,
          onKeyEvent: (event) =>
              widget.otpManager.handleKeyEvent(event, context),
          child: Form(
            key: widget.otpManager.formKey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.otpManager.length * 2 - 1, (i) {
                if (i.isOdd) {
                  return SizedBox(width: widget.spacing);
                }
                final index = i ~/ 2;
                return _OTPDigitField(
                  index: index,
                  length: widget.otpManager.length,
                  fieldWidth: widget.fieldWidth,
                  fieldHeight: widget.fieldHeight,
                  keyboardType: widget.keyboardType,
                  controller: widget.otpManager.controllers[index],
                  focusNode: widget.otpManager.focusNodes[index],
                  parentFocusNode: widget.otpManager.parentFocusNode,
                  isReadOnly: widget.isReadOnly,
                  showCursor: widget.showCursor,
                  obscureText: widget.obscureText,
                  otpManager: widget.otpManager,
                  onOtpChanged: widget.onOtpChanged,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    final colors = context.colors;

    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: widget.borderRadius,
          borderSide: BorderSide(
            color: color,
            width: widget.borderWidth,
            style: widget.borderStyle,
          ),
        );

    return ThemeData(
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: widget.cursorColor ?? colors.cursorColor,
        selectionColor:
            widget.selectionHighlightColor ?? colors.selectionHighlightColor,
        selectionHandleColor:
            widget.selectionHandleColor ?? colors.selectionHandleColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: widget.fillColor ?? colors.fillColor,
        filled: widget.isFilled,
        contentPadding: widget.contentPadding,
        focusedBorder: border(widget.focusedBorderColor ?? colors.focusedBorderColor),
        enabledBorder: border(widget.enabledBorderColor ?? colors.enabledBorderColor),
        border: border(widget.defaultBorderColor ?? colors.defaultBorderColor),
        errorBorder: border(widget.errorBorderColor ?? colors.error),
        disabledBorder: border(widget.disabledBorderColor ?? colors.disabledBorderColor),
        focusedErrorBorder: border(widget.focusedErrorBorderColor ?? colors.error),
      ),
      textTheme: TextTheme(
        bodyMedium: widget.textStyle ?? context.styles.medium20,
      ),
    );
  }
}

// ─── Single digit field ───────────────────────────────────────────────────────

class _OTPDigitField extends StatelessWidget {
  const _OTPDigitField({
    required this.index,
    required this.length,
    required this.fieldWidth,
    required this.fieldHeight,
    required this.keyboardType,
    required this.controller,
    required this.focusNode,
    required this.parentFocusNode,
    required this.isReadOnly,
    required this.showCursor,
    required this.obscureText,
    required this.otpManager,
    required this.onOtpChanged,
  });

  final int index;
  final int length;
  final double fieldWidth;
  final double fieldHeight;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode parentFocusNode;
  final bool isReadOnly;
  final bool showCursor;
  final bool obscureText;
  final OTPManager otpManager;
  final void Function(String)? onOtpChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fieldWidth,
      height: fieldHeight,
      child: Center(
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          readOnly: isReadOnly,
          obscureText: obscureText,
          showCursor: showCursor,
          keyboardType: keyboardType,
          textAlign: TextAlign.center,
          onTapOutside: (_) => focusNode.unfocus(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: Theme.of(context).textTheme.bodyMedium,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          errorBuilder: (_, __) => const SizedBox.shrink(),
          validator: (value) => Validator.validateRequired(context, value),
          onChanged: (value) {
            if (value.length > 1) {
              controller.text = value.substring(value.length - 1);
              controller.selection =
                  const TextSelection.collapsed(offset: 1);
            }
            if (controller.text.length == 1) {
              if (index == length - 1) {
                parentFocusNode.unfocus();
              } else {
                parentFocusNode.nextFocus();
              }
            }
            onOtpChanged?.call(otpManager.otpCode);
          },
        ),
      ),
    );
  }
}
