/// Abstract interface for key-value storage operations.
///
/// Implement this to provide different storage backends
/// (e.g. Hive, SharedPreferences, SecureStorage).
abstract class StorageService<T> {
  /// Must be called before any other operations.
  Future<void> initialize();

  /// Store a value with the given key.
  Future<void> put(String key, T value);

  /// Retrieve a value by key. Returns null if not found.
  T? get(String key);

  /// Check if a key exists.
  bool containsKey(String key);

  /// Delete a value by key.
  Future<void> delete(String key);

  /// Clear all stored values.
  Future<void> clear();

  /// Store multiple key-value pairs at once.
  Future<void> putAll(Map<String, T> entries);

  /// Retrieve all stored key-value pairs.
  Map<String, T> getAll();

  /// Delete multiple keys at once.
  Future<void> deleteAll(List<String> keys);

  /// Get all keys.
  List<String> keys();

  /// Get all values.
  List<T> values();

  /// Get the count of stored items.
  int get length;

  /// Execute operations with automatic rollback on failure.
  Future<R> transaction<R>(Future<R> Function() operations);

  /// Watch changes for a specific key.
  Stream<T?> watch(String key);

  /// Watch all changes in the storage.
  Stream<Map<String, T>> watchAll();

  /// Release all resources. Call when storage is no longer needed.
  Future<void> dispose();

  /// Delete the box and all its data from disk.
  Future<void> deleteFromDisk();
}
