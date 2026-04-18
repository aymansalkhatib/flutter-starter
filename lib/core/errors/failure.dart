/// A base class representing a failure with an error message and status code.
abstract class Failure {
  /// The error message describing the failure.
  final String message;

  /// The HTTP status code or custom error code associated with the failure.
  final int errorCode;

  /// Creates an instance of [Failure].
  const Failure(this.message, {required this.errorCode});

  Map<String, dynamic> toJson() {
    return {'message': message, 'errorCode': errorCode};
  }

  @override
  String toString() => 'Failure(errorCode: $errorCode, message: $message)';
}
