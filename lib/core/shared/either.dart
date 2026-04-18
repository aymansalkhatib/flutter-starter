/// A sealed Either type representing one of two possible values.
///
/// [Left] conventionally holds a failure/error value.
/// [Right] conventionally holds a success value.
///
/// Usage with Dart 3 pattern matching:
/// ```dart
/// switch (result) {
///   case Left(:final value): handleError(value);
///   case Right(:final value): handleSuccess(value);
/// }
/// ```
sealed class Either<L, R> {
  const Either();

  /// Applies [onLeft] if this is a [Left], or [onRight] if this is a [Right].
  T fold<T>(T Function(L value) onLeft, T Function(R value) onRight);

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  /// Returns the [Right] value, or [defaultValue] if this is a [Left].
  R getOrElse(R defaultValue) =>
      isRight ? (this as Right<L, R>).value : defaultValue;
}

final class Left<L, R> extends Either<L, R> {
  const Left(this.value);

  final L value;

  @override
  T fold<T>(T Function(L value) onLeft, T Function(R value) onRight) =>
      onLeft(value);

  @override
  bool operator ==(Object other) => other is Left<L, R> && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Left($value)';
}

final class Right<L, R> extends Either<L, R> {
  const Right(this.value);

  final R value;

  @override
  T fold<T>(T Function(L value) onLeft, T Function(R value) onRight) =>
      onRight(value);

  @override
  bool operator ==(Object other) =>
      other is Right<L, R> && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Right($value)';
}
