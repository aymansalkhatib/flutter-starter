import 'package:dio/dio.dart';

import '../../constants/hive/storage_keys.dart';
import '../../localization/translation_manager.dart';
import '../../storage/hive/hive_boxes.dart';

/// Attaches auth token and standard headers to every outgoing request.
///
/// Skips `Content-Type` for [FormData] requests — Dio sets it automatically
/// with the correct multipart boundary.
class HeaderInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = HiveBoxes.appBox.get(StorageKeys.authToken) as String?;
    final isFormData = options.data is FormData;

    options.headers.addAll({
      if (!isFormData) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Language': TranslationManager.fetchCurrentLanguageCode(),
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    });

    handler.next(options);
  }
}
