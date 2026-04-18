/// Custom exception for storage-related errors.
class StorageException implements Exception {
  final String message;
  final Object? cause;

  const StorageException(this.message, [this.cause]);

  @override
  String toString() =>
      'StorageException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}
