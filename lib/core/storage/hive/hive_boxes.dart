import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

import '../../../features/products/domain/entities/product_entity.dart';
import '../../constants/hive/hive_box_names.dart';
import 'hive_storage_service.dart';

/// Manages Hive storage boxes for the application.
///
/// Call [initialize] once during app startup before accessing any box.
class HiveBoxes {
  HiveBoxes._();

  /// The main app storage box.
  static late HiveStorageService<dynamic> appBox;

  /// Products cache box.
  static late HiveStorageService<ProductEntity> productBox;

  static bool _isInitialized = false;

  /// Initializes all Hive boxes.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops.
  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    Hive.registerAdapter<ProductEntity>(ProductEntityAdapter());

    appBox = HiveStorageService<dynamic>(HiveBoxNames.appBox);
    await appBox.initialize();

    productBox = HiveStorageService<ProductEntity>(HiveBoxNames.productBox);
    await productBox.initialize();

    _isInitialized = true;
  }

  static bool get isInitialized => _isInitialized;

  /// Resets all boxes — for testing only.
  @visibleForTesting
  static Future<void> reset() async {
    if (!_isInitialized) {
      return;
    }
    await appBox.dispose();
    _isInitialized = false;
  }
}
