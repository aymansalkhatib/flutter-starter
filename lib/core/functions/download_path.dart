import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../utils/app_logger.dart';

abstract final class DownloadPath {
  /// Returns the platform's download directory path, or null if unsupported.
  ///
  /// - Android : `/storage/emulated/0/Download`
  /// - iOS     : Application Documents directory
  /// - Desktop : System Downloads directory via `path_provider`
  static Future<String?> get() async {
    try {
      if (Platform.isAndroid) {
        return '/storage/emulated/0/Download';
      }
      if (Platform.isIOS) {
        final dir = await getApplicationDocumentsDirectory();
        return dir.path;
      }
      // macOS / Windows / Linux
      final dir = await getDownloadsDirectory();
      return dir?.path;
    } catch (e) {
      AppLogger.error('DownloadPath.get failed', tag: 'DownloadPath', error: e);
      return null;
    }
  }
}
