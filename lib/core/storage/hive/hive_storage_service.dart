import 'dart:async';

import 'package:hive_ce/hive.dart';

import '../../errors/storage_exception.dart';
import '../storage_service.dart';

/// Generic local storage service built on Hive.
///
/// Instances are cached by [boxName] — calling the factory with the same
/// name always returns the same instance.
///
/// Example:
/// ```dart
/// final storage = HiveStorageService<String>('settings');
/// await storage.initialize();
///
/// await storage.put('theme', 'dark');
/// final theme = storage.get('theme'); // 'dark'
///
/// // Watch for changes
/// storage.watch('theme').listen((value) => print('Theme changed: $value'));
///
/// // Transaction with rollback
/// await storage.transaction(() async {
///   await storage.put('key1', 'value1');
///   await storage.put('key2', 'value2');
/// });
/// ```
class HiveStorageService<T> implements StorageService<T> {
  static final Map<String, HiveStorageService<dynamic>> _instances = {};

  late final Box<T> _box;
  final String boxName;

  bool _isInitialized = false;
  bool _watchersInitialized = false;

  StreamController<Map<String, T>>? _changeController;
  final Map<String, StreamController<T?>> _keyWatchers = {};

  /// Returns a cached instance for the given [boxName].
  factory HiveStorageService(String boxName) {
    return (_instances[boxName] as HiveStorageService<T>?) ??
        (_instances[boxName] = HiveStorageService<T>._internal(boxName));
  }

  HiveStorageService._internal(this.boxName);

  // ─── Initialization ────────────────────────────────────────────────────────

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    try {
      _box = await Hive.openBox<T>(boxName);
      _isInitialized = true;
    } catch (e) {
      throw StorageException('Failed to initialize box "$boxName"', e);
    }
  }

  /// Initializes watchers for reactive change notifications.
  /// Call only when you need [watch] or [watchAll].
  void initializeWatcher() {
    if (_watchersInitialized) {
      return;
    }
    _changeController = StreamController<Map<String, T>>.broadcast();
    _box.watch().listen(_onBoxChanged);
    _watchersInitialized = true;
  }

  void _onBoxChanged(BoxEvent event) {
    final key = event.key as String;
    _keyWatchers[key]?.add(event.value as T?);

    if (_changeController?.hasListener ?? false) {
      _changeController?.add(getAll());
    }
  }

  // ─── Read ──────────────────────────────────────────────────────────────────

  @override
  T? get(String key) {
    _assertInitialized();
    try {
      return _box.get(key);
    } catch (e) {
      throw StorageException('Failed to get "$key"', e);
    }
  }

  @override
  bool containsKey(String key) {
    _assertInitialized();
    return _box.containsKey(key);
  }

  @override
  Map<String, T> getAll() {
    _assertInitialized();
    try {
      return Map<String, T>.from(_box.toMap());
    } catch (e) {
      throw StorageException('Failed to getAll from "$boxName"', e);
    }
  }

  @override
  List<String> keys() {
    _assertInitialized();
    return _box.keys.cast<String>().toList();
  }

  @override
  List<T> values() {
    _assertInitialized();
    return _box.values.toList();
  }

  @override
  int get length {
    _assertInitialized();
    return _box.length;
  }

  // ─── Write ─────────────────────────────────────────────────────────────────

  @override
  Future<void> put(String key, T value) async {
    _assertInitialized();
    try {
      await _box.put(key, value);
    } catch (e) {
      throw StorageException('Failed to put "$key"', e);
    }
  }

  @override
  Future<void> putAll(Map<String, T> entries) async {
    _assertInitialized();
    try {
      await _box.putAll(entries);
    } catch (e) {
      throw StorageException('Failed to putAll in "$boxName"', e);
    }
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  @override
  Future<void> delete(String key) async {
    _assertInitialized();
    try {
      await _box.delete(key);
    } catch (e) {
      throw StorageException('Failed to delete "$key"', e);
    }
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    _assertInitialized();
    try {
      await _box.deleteAll(keys);
    } catch (e) {
      throw StorageException('Failed to deleteAll in "$boxName"', e);
    }
  }

  @override
  Future<void> clear() async {
    _assertInitialized();
    try {
      await _box.clear();
    } catch (e) {
      throw StorageException('Failed to clear "$boxName"', e);
    }
  }

  // ─── Transaction ───────────────────────────────────────────────────────────

  @override
  Future<R> transaction<R>(Future<R> Function() operations) async {
    _assertInitialized();
    final snapshot = getAll();
    try {
      return await operations();
    } catch (e) {
      await restore(snapshot);
      throw StorageException('Transaction failed — rolled back', e);
    }
  }

  Future<void> restore(Map<String, T> data) async {
    await clear();
    await putAll(Map<String, T>.from(data));
  }

  // ─── Streams ───────────────────────────────────────────────────────────────

  @override
  Stream<T?> watch(String key) {
    _assertInitialized();
    if (!_watchersInitialized) {
      initializeWatcher();
    }
    return _keyWatchers
        .putIfAbsent(key, StreamController<T?>.broadcast)
        .stream;
  }

  @override
  Stream<Map<String, T>> watchAll() {
    _assertInitialized();
    if (!_watchersInitialized) {
      initializeWatcher();
    }
    return _changeController!.stream;
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> dispose() async {
    _assertInitialized();
    try {
      if (_watchersInitialized) {
        for (final controller in _keyWatchers.values) {
          await controller.close();
        }
        await _changeController?.close();
      }
      await _box.close();
      _instances.remove(boxName);
    } catch (e) {
      throw StorageException('Failed to dispose "$boxName"', e);
    }
  }

  @override
  Future<void> deleteFromDisk() async {
    _assertInitialized();
    try {
      await _box.close();
      await Hive.deleteBoxFromDisk(boxName);
      _instances.remove(boxName);
    } catch (e) {
      throw StorageException('Failed to delete "$boxName" from disk', e);
    }
  }

  /// Deletes a box from disk without needing an active instance.
  static Future<void> forceDeleteFromDisk(String boxName) async {
    try {
      await Hive.deleteBoxFromDisk(boxName);
      _instances.remove(boxName);
    } catch (e) {
      throw StorageException('Failed to force delete "$boxName" from disk', e);
    }
  }

  // ─── Internal ──────────────────────────────────────────────────────────────

  void _assertInitialized() {
    if (!_isInitialized) {
      throw StorageException('HiveStorageService "$boxName" not initialized. Call initialize() first.');
    }
  }
}
