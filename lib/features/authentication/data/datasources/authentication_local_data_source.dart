import 'package:flutter_starter/core/constants/hive/storage_keys.dart';
import 'package:flutter_starter/core/storage/hive/hive_boxes.dart';

abstract class AuthenticationLocalDataSource {
  String? getToken();
  Future<void> cacheToken(String token);
  Future<void> clearToken();
}

class AuthenticationLocalDataSourceImpl
    implements AuthenticationLocalDataSource {
  // TODO(security): migrate to HiveBoxes.secureBox (HiveAesCipher) before
  // production — auth tokens must live in an encrypted box per §8.5.
  // StorageKeys.authToken — stored in appBox (dev scaffold only).

  @override
  String? getToken() => HiveBoxes.appBox.get(StorageKeys.authToken) as String?;

  @override
  Future<void> cacheToken(String token) =>
      HiveBoxes.appBox.put(StorageKeys.authToken, token);

  @override
  Future<void> clearToken() => HiveBoxes.appBox.delete(StorageKeys.authToken);
}
