// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'authentication_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthenticationEntity {
  String get token;

  /// Create a copy of AuthenticationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AuthenticationEntityCopyWith<AuthenticationEntity> get copyWith =>
      _$AuthenticationEntityCopyWithImpl<AuthenticationEntity>(
          this as AuthenticationEntity, _$identity);

  /// Serializes this AuthenticationEntity to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuthenticationEntity &&
            (identical(other.token, token) || other.token == token));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, token);

  @override
  String toString() {
    return 'AuthenticationEntity(token: $token)';
  }
}

/// @nodoc
abstract mixin class $AuthenticationEntityCopyWith<$Res> {
  factory $AuthenticationEntityCopyWith(AuthenticationEntity value,
          $Res Function(AuthenticationEntity) _then) =
      _$AuthenticationEntityCopyWithImpl;
  @useResult
  $Res call({String token});
}

/// @nodoc
class _$AuthenticationEntityCopyWithImpl<$Res>
    implements $AuthenticationEntityCopyWith<$Res> {
  _$AuthenticationEntityCopyWithImpl(this._self, this._then);

  final AuthenticationEntity _self;
  final $Res Function(AuthenticationEntity) _then;

  /// Create a copy of AuthenticationEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
  }) {
    return _then(_self.copyWith(
      token: null == token
          ? _self.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [AuthenticationEntity].
extension AuthenticationEntityPatterns on AuthenticationEntity {
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
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AuthenticationEntity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthenticationEntity() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_AuthenticationEntity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthenticationEntity():
        return $default(_that);
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
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AuthenticationEntity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthenticationEntity() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String token)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthenticationEntity() when $default != null:
        return $default(_that.token);
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
  TResult when<TResult extends Object?>(
    TResult Function(String token) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthenticationEntity():
        return $default(_that.token);
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
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String token)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthenticationEntity() when $default != null:
        return $default(_that.token);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AuthenticationEntity implements AuthenticationEntity {
  const _AuthenticationEntity({required this.token});
  factory _AuthenticationEntity.fromJson(Map<String, dynamic> json) =>
      _$AuthenticationEntityFromJson(json);

  @override
  final String token;

  /// Create a copy of AuthenticationEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AuthenticationEntityCopyWith<_AuthenticationEntity> get copyWith =>
      __$AuthenticationEntityCopyWithImpl<_AuthenticationEntity>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AuthenticationEntityToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AuthenticationEntity &&
            (identical(other.token, token) || other.token == token));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, token);

  @override
  String toString() {
    return 'AuthenticationEntity(token: $token)';
  }
}

/// @nodoc
abstract mixin class _$AuthenticationEntityCopyWith<$Res>
    implements $AuthenticationEntityCopyWith<$Res> {
  factory _$AuthenticationEntityCopyWith(_AuthenticationEntity value,
          $Res Function(_AuthenticationEntity) _then) =
      __$AuthenticationEntityCopyWithImpl;
  @override
  @useResult
  $Res call({String token});
}

/// @nodoc
class __$AuthenticationEntityCopyWithImpl<$Res>
    implements _$AuthenticationEntityCopyWith<$Res> {
  __$AuthenticationEntityCopyWithImpl(this._self, this._then);

  final _AuthenticationEntity _self;
  final $Res Function(_AuthenticationEntity) _then;

  /// Create a copy of AuthenticationEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? token = null,
  }) {
    return _then(_AuthenticationEntity(
      token: null == token
          ? _self.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
