// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AppState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AppState()';
  }
}

/// @nodoc
class $AppStateCopyWith<$Res> {
  $AppStateCopyWith(AppState _, $Res Function(AppState) __);
}

/// Adds pattern-matching-related methods to [AppState].
extension AppStatePatterns on AppState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_InitialState value)? initial,
    TResult Function(_ThemeChangedState value)? themeChanged,
    TResult Function(_LanguageChangedState value)? languageChanged,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InitialState() when initial != null:
        return initial(_that);
      case _ThemeChangedState() when themeChanged != null:
        return themeChanged(_that);
      case _LanguageChangedState() when languageChanged != null:
        return languageChanged(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_InitialState value) initial,
    required TResult Function(_ThemeChangedState value) themeChanged,
    required TResult Function(_LanguageChangedState value) languageChanged,
  }) {
    final _that = this;
    switch (_that) {
      case _InitialState():
        return initial(_that);
      case _ThemeChangedState():
        return themeChanged(_that);
      case _LanguageChangedState():
        return languageChanged(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_InitialState value)? initial,
    TResult? Function(_ThemeChangedState value)? themeChanged,
    TResult? Function(_LanguageChangedState value)? languageChanged,
  }) {
    final _that = this;
    switch (_that) {
      case _InitialState() when initial != null:
        return initial(_that);
      case _ThemeChangedState() when themeChanged != null:
        return themeChanged(_that);
      case _LanguageChangedState() when languageChanged != null:
        return languageChanged(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ThemeMode themeMode, Locale locale)? initial,
    TResult Function(ThemeMode themeMode)? themeChanged,
    TResult Function(Locale locale)? languageChanged,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InitialState() when initial != null:
        return initial(_that.themeMode, _that.locale);
      case _ThemeChangedState() when themeChanged != null:
        return themeChanged(_that.themeMode);
      case _LanguageChangedState() when languageChanged != null:
        return languageChanged(_that.locale);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ThemeMode themeMode, Locale locale) initial,
    required TResult Function(ThemeMode themeMode) themeChanged,
    required TResult Function(Locale locale) languageChanged,
  }) {
    final _that = this;
    switch (_that) {
      case _InitialState():
        return initial(_that.themeMode, _that.locale);
      case _ThemeChangedState():
        return themeChanged(_that.themeMode);
      case _LanguageChangedState():
        return languageChanged(_that.locale);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ThemeMode themeMode, Locale locale)? initial,
    TResult? Function(ThemeMode themeMode)? themeChanged,
    TResult? Function(Locale locale)? languageChanged,
  }) {
    final _that = this;
    switch (_that) {
      case _InitialState() when initial != null:
        return initial(_that.themeMode, _that.locale);
      case _ThemeChangedState() when themeChanged != null:
        return themeChanged(_that.themeMode);
      case _LanguageChangedState() when languageChanged != null:
        return languageChanged(_that.locale);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _InitialState implements AppState {
  const _InitialState({required this.themeMode, required this.locale});

  final ThemeMode themeMode;
  final Locale locale;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InitialStateCopyWith<_InitialState> get copyWith =>
      __$InitialStateCopyWithImpl<_InitialState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InitialState &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.locale, locale) || other.locale == locale));
  }

  @override
  int get hashCode => Object.hash(runtimeType, themeMode, locale);

  @override
  String toString() {
    return 'AppState.initial(themeMode: $themeMode, locale: $locale)';
  }
}

/// @nodoc
abstract mixin class _$InitialStateCopyWith<$Res>
    implements $AppStateCopyWith<$Res> {
  factory _$InitialStateCopyWith(
          _InitialState value, $Res Function(_InitialState) _then) =
      __$InitialStateCopyWithImpl;
  @useResult
  $Res call({ThemeMode themeMode, Locale locale});
}

/// @nodoc
class __$InitialStateCopyWithImpl<$Res>
    implements _$InitialStateCopyWith<$Res> {
  __$InitialStateCopyWithImpl(this._self, this._then);

  final _InitialState _self;
  final $Res Function(_InitialState) _then;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? themeMode = null,
    Object? locale = null,
  }) {
    return _then(_InitialState(
      themeMode: null == themeMode
          ? _self.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      locale: null == locale
          ? _self.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as Locale,
    ));
  }
}

/// @nodoc

class _ThemeChangedState implements AppState {
  const _ThemeChangedState({required this.themeMode});

  final ThemeMode themeMode;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ThemeChangedStateCopyWith<_ThemeChangedState> get copyWith =>
      __$ThemeChangedStateCopyWithImpl<_ThemeChangedState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ThemeChangedState &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, themeMode);

  @override
  String toString() {
    return 'AppState.themeChanged(themeMode: $themeMode)';
  }
}

/// @nodoc
abstract mixin class _$ThemeChangedStateCopyWith<$Res>
    implements $AppStateCopyWith<$Res> {
  factory _$ThemeChangedStateCopyWith(
          _ThemeChangedState value, $Res Function(_ThemeChangedState) _then) =
      __$ThemeChangedStateCopyWithImpl;
  @useResult
  $Res call({ThemeMode themeMode});
}

/// @nodoc
class __$ThemeChangedStateCopyWithImpl<$Res>
    implements _$ThemeChangedStateCopyWith<$Res> {
  __$ThemeChangedStateCopyWithImpl(this._self, this._then);

  final _ThemeChangedState _self;
  final $Res Function(_ThemeChangedState) _then;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? themeMode = null,
  }) {
    return _then(_ThemeChangedState(
      themeMode: null == themeMode
          ? _self.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
    ));
  }
}

/// @nodoc

class _LanguageChangedState implements AppState {
  const _LanguageChangedState({required this.locale});

  final Locale locale;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LanguageChangedStateCopyWith<_LanguageChangedState> get copyWith =>
      __$LanguageChangedStateCopyWithImpl<_LanguageChangedState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LanguageChangedState &&
            (identical(other.locale, locale) || other.locale == locale));
  }

  @override
  int get hashCode => Object.hash(runtimeType, locale);

  @override
  String toString() {
    return 'AppState.languageChanged(locale: $locale)';
  }
}

/// @nodoc
abstract mixin class _$LanguageChangedStateCopyWith<$Res>
    implements $AppStateCopyWith<$Res> {
  factory _$LanguageChangedStateCopyWith(_LanguageChangedState value,
          $Res Function(_LanguageChangedState) _then) =
      __$LanguageChangedStateCopyWithImpl;
  @useResult
  $Res call({Locale locale});
}

/// @nodoc
class __$LanguageChangedStateCopyWithImpl<$Res>
    implements _$LanguageChangedStateCopyWith<$Res> {
  __$LanguageChangedStateCopyWithImpl(this._self, this._then);

  final _LanguageChangedState _self;
  final $Res Function(_LanguageChangedState) _then;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? locale = null,
  }) {
    return _then(_LanguageChangedState(
      locale: null == locale
          ? _self.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as Locale,
    ));
  }
}

// dart format on
