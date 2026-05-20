import 'package:dio/dio.dart';
import 'package:flutter_starter/generated/locale_keys.dart';

import '../network_monitor.dart';

/// Rejects requests early when the device is offline.
class NetworkInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final online = await NetworkMonitor().isOnline;

    if (!online) {
      return handler.reject(
        DioException(
          requestOptions: options,
          message: LocaleKeys.noInternetConnection,
          type: DioExceptionType.connectionError,
          error: LocaleKeys.noInternetConnection,
        ),
      );
    }

    handler.next(options);
  }
}
