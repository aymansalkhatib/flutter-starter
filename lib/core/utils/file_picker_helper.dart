import 'package:file_picker/file_picker.dart';

import 'app_logger.dart';

abstract final class FilePickerUtils {
  // ─── Documents ────────────────────────────────────────────────────────────

  /// Picks document files.
  ///
  /// Defaults to `['doc', 'docx', 'pdf', 'txt']`. Returns null if the user
  /// cancels or an error occurs.
  static Future<List<PlatformFile>?> pickDocuments({
    List<String> allowedExtensions = const ['doc', 'docx', 'pdf', 'txt'],
    bool multiple = true,
  }) =>
      _pick(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: multiple,
      );

  // ─── Images ───────────────────────────────────────────────────────────────

  /// Picks image files.
  static Future<List<PlatformFile>?> pickImages({bool multiple = true}) =>
      _pick(type: FileType.image, allowMultiple: multiple);

  // ─── Video ────────────────────────────────────────────────────────────────

  /// Picks video files.
  static Future<List<PlatformFile>?> pickVideos({bool multiple = true}) =>
      _pick(type: FileType.video, allowMultiple: multiple);

  // ─── Any ──────────────────────────────────────────────────────────────────

  /// Picks files of any type.
  static Future<List<PlatformFile>?> pickAny({bool multiple = true}) =>
      _pick(type: FileType.any, allowMultiple: multiple);

  // ─── Internal ─────────────────────────────────────────────────────────────

  static Future<List<PlatformFile>?> _pick({
    required FileType type,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
  }) async {
    try {
      final result = await FilePicker.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultiple,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      if (allowedExtensions != null) {
        final filtered = result.files.where((file) {
          return allowedExtensions.contains(file.extension?.toLowerCase());
        }).toList();

        if (filtered.length != result.files.length) {
          AppLogger.info(
            '${result.files.length - filtered.length} file(s) filtered — invalid extension.',
            tag: 'FilePickerUtils',
          );
        }

        return filtered.isEmpty ? null : filtered;
      }

      return result.files;
    } catch (e, st) {
      AppLogger.error('File picking failed', tag: 'FilePickerUtils', error: e, stackTrace: st);
      return null;
    }
  }
}
