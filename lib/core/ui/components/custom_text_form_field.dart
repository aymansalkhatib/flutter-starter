import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../extensions/build_context_extensions.dart';
import '../../extensions/responsive_font_size_extension.dart';

/// The base input field for all text entry in the app.
///
/// Supports:
/// - SVG prefix icon with focus-aware color
/// - Custom prefix / suffix widgets
/// - Password visibility toggle
/// - Responsive sizing via [sp]
class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.prefixIconSvg,
    this.prefixIcon,
    this.suffixIcon,
    this.showVisibilityToggle = false,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.autocorrect = false,
    this.isDense = false,
    this.fillColor,
    this.textStyle,
    this.hintTextStyle,
    this.labelTextStyle,
    this.borderRadius,
    this.contentPadding,
    this.prefixIconPadding,
    this.suffixIconPadding,
    this.visualDensity,
    this.maxLines = 1,
    this.maxLength,
    this.unfocusOnTapOutside = false,
    this.onPrefixIconTap,
  });

  // ─── Content ──────────────────────────────────────────────────────────────
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;

  // ─── Callbacks ────────────────────────────────────────────────────────────
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final VoidCallback? onTap;

  // ─── Focus & keyboard ─────────────────────────────────────────────────────
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  // ─── Icons ────────────────────────────────────────────────────────────────
  /// SVG asset path. Gets focus-aware color automatically.
  /// Ignored if [prefixIcon] is also provided.
  final String? prefixIconSvg;

  /// Any widget as prefix. Takes priority over [prefixIconSvg].
  final Widget? prefixIcon;

  /// Any widget as suffix. Ignored if [showVisibilityToggle] is true.
  final Widget? suffixIcon;

  /// Only applies when [prefixIconSvg] is used. Ignored if [prefixIcon] is set.
  final VoidCallback? onPrefixIconTap;

  // ─── Behavior ─────────────────────────────────────────────────────────────
  final bool showVisibilityToggle;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final bool autocorrect;
  final bool unfocusOnTapOutside;

  // ─── Layout ───────────────────────────────────────────────────────────────
  final bool isDense;
  final VisualDensity? visualDensity;
  final int maxLines;
  final int? maxLength;

  // ─── Styling ──────────────────────────────────────────────────────────────
  final Color? fillColor;
  final TextStyle? textStyle;
  final TextStyle? hintTextStyle;
  final TextStyle? labelTextStyle;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? prefixIconPadding;
  final EdgeInsetsGeometry? suffixIconPadding;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _isObscured;
  late FocusNode _focusNode;
  late VoidCallback _focusListener;
  bool _ownsNode = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsNode = true;
    }

    _focusListener = () {
      if (mounted) {
        setState(() {});
      }
    };
    _focusNode.addListener(_focusListener);
  }

  @override
  void didUpdateWidget(CustomTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_focusListener);
      if (_ownsNode) {
        _focusNode.dispose();
      }
      if (widget.focusNode != null) {
        _focusNode = widget.focusNode!;
        _ownsNode = false;
      } else {
        _focusNode = FocusNode();
        _ownsNode = true;
      }
      _focusNode.addListener(_focusListener);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusListener);
    if (_ownsNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      onTap: widget.onTap,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      obscureText: _isObscured,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      autocorrect: widget.autocorrect,
      cursorColor: colors.primary,
      style: widget.textStyle ??
          context.styles.regular16.copyWith(color: colors.textPrimary),
      onTapOutside: widget.unfocusOnTapOutside
          ? (_) => FocusManager.instance.primaryFocus?.unfocus()
          : null,
      decoration: InputDecoration(
        counterText: '',
        isDense: widget.isDense,
        visualDensity: widget.visualDensity,
        hintText: widget.hintText,
        hintStyle: widget.hintTextStyle ??
            context.styles.bold14.copyWith(color: colors.hintTextColor),
        labelText: widget.labelText,
        labelStyle: widget.labelTextStyle ??
            context.styles.semiBold14.copyWith(color: colors.hintTextColor),
        filled: true,
        fillColor: widget.fillColor ?? colors.fillColor,
        border: _border(colors.defaultBorderColor),
        focusedBorder: _border(colors.focusedBorderColor),
        enabledBorder: _border(colors.enabledBorderColor),
        errorBorder: _border(colors.error),
        focusedErrorBorder: _border(colors.error),
        contentPadding: widget.contentPadding ??
            EdgeInsets.symmetric(
              horizontal: 12.sp(context),
              vertical: 12.sp(context),
            ),
        prefixIconConstraints: const BoxConstraints.tightFor(
          width: 44,
          height: 44,
        ),
        prefixIcon: _buildPrefixIcon(context),
        suffixIcon: _buildSuffixIcon(context),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
        borderSide: BorderSide(color: color),
      );

  Widget? _buildPrefixIcon(BuildContext context) {
    final colors = context.colors;

    if (widget.prefixIcon != null) {
      return Padding(
        padding: widget.prefixIconPadding ??
            const EdgeInsetsDirectional.only(start: 12, end: 4),
        child: widget.prefixIcon,
      );
    }

    if (widget.prefixIconSvg != null) {
      return Padding(
        padding: widget.prefixIconPadding ??
            const EdgeInsetsDirectional.only(start: 12, end: 4),
        child: GestureDetector(
          onTap: widget.onPrefixIconTap,
          child: SvgPicture.asset(
            widget.prefixIconSvg!,
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(
              _focusNode.hasFocus
                  ? colors.focusedBorderColor
                  : colors.hintTextColor,
              BlendMode.srcIn,
            ),
          ),
        ),
      );
    }

    return null;
  }

  Widget? _buildSuffixIcon(BuildContext context) {
    if (widget.showVisibilityToggle) {
      return Padding(
        padding: widget.suffixIconPadding ??
            EdgeInsets.symmetric(horizontal: 14.sp(context)),
        child: GestureDetector(
          onTap: () => setState(() => _isObscured = !_isObscured),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Icon(
              _isObscured
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              key: ValueKey(_isObscured),
              color: _focusNode.hasFocus
                  ? context.colors.focusedBorderColor
                  : context.colors.hintTextColor,
              size: 22.sp(context),
            ),
          ),
        ),
      );
    }

    if (widget.suffixIcon != null) {
      return Padding(
        padding: widget.suffixIconPadding ??
            EdgeInsets.symmetric(horizontal: 14.sp(context)),
        child: widget.suffixIcon,
      );
    }

    return null;
  }
}
