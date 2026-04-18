import 'package:image_picker/image_picker.dart';

import 'app_logger.dart';

abstract final class ImagePickerUtils {
  static final _picker = ImagePicker();

  // ─── Camera ───────────────────────────────────────────────────────────────

  /// Captures a photo from the camera.
  ///
  /// Returns null if the user cancels or an error occurs.
  static Future<XFile?> capturePhoto({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) =>
      _pickSingle(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

  /// Records a video from the camera.
  ///
  /// Returns null if the user cancels or an error occurs.
  static Future<XFile?> captureVideo({
    Duration? maxDuration,
    CameraDevice preferredCamera = CameraDevice.rear,
  }) =>
      _pickVideo(
        source: ImageSource.camera,
        maxDuration: maxDuration,
        preferredCamera: preferredCamera,
      );

  // ─── Gallery ──────────────────────────────────────────────────────────────

  /// Picks a single image from the gallery.
  ///
  /// Returns null if the user cancels or an error occurs.
  static Future<XFile?> pickImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) =>
      _pickSingle(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

  /// Picks multiple images from the gallery.
  ///
  /// Returns null if the user cancels or an error occurs.
  static Future<List<XFile>?> pickMultipleImages({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
  }) async {
    try {
      final files = await _picker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        limit: limit,
      );
      return files.isEmpty ? null : files;
    } catch (e, st) {
      AppLogger.error(
        'Multi-image picking failed',
        tag: 'ImagePickerUtils',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Picks a video from the gallery.
  ///
  /// Returns null if the user cancels or an error occurs.
  static Future<XFile?> pickVideo({Duration? maxDuration}) =>
      _pickVideo(source: ImageSource.gallery, maxDuration: maxDuration);

  // ─── Internal ─────────────────────────────────────────────────────────────

  static Future<XFile?> _pickSingle({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      return await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
    } catch (e, st) {
      AppLogger.error(
        'Image picking failed',
        tag: 'ImagePickerUtils',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  static Future<XFile?> _pickVideo({
    required ImageSource source,
    Duration? maxDuration,
    CameraDevice preferredCamera = CameraDevice.rear,
  }) async {
    try {
      return await _picker.pickVideo(
        source: source,
        maxDuration: maxDuration,
        preferredCameraDevice: preferredCamera,
      );
    } catch (e, st) {
      AppLogger.error(
        'Video picking failed',
        tag: 'ImagePickerUtils',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
