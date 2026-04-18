import 'dart:io';

import 'package:dio/dio.dart';

import '../constants/environment_config.dart';
import 'interceptors/api_logger_interceptor.dart';
import 'interceptors/header_interceptor.dart';
import 'interceptors/network_interceptor.dart';
import 'interceptors/unauthorized_interceptor.dart';

/// Centralized HTTP client built on Dio.
///
/// Usage:
/// ```dart
/// final response = await apiClient.get('/users');
/// final response = await apiClient.post('/users', body: {...});
/// final response = await apiClient.upload('/avatar', files: {'image': [file]});
/// ```
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio) {
    _dio.options
      ..baseUrl = EnvironmentConfig.apiBaseUrl
      ..connectTimeout = const Duration(seconds: 30)
      ..receiveTimeout = const Duration(seconds: 30);

    _dio.interceptors.addAll([
      NetworkInterceptor(),
      HeaderInterceptor(),
      ApiLoggerInterceptor(),
      UnauthorizedInterceptor(),
    ]);
  }

  // ─── Public API ────────────────────────────────────────────────────────────

  Future<Response<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    int maxRetries = 0,
  }) =>
      _send('GET', endpoint,
          queryParams: queryParams,
          headers: headers,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
          maxRetries: maxRetries);

  Future<Response<dynamic>> post(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    int maxRetries = 0,
  }) =>
      _send('POST', endpoint,
          data: body,
          queryParams: queryParams,
          headers: headers,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          maxRetries: maxRetries);

  Future<Response<dynamic>> put(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    int maxRetries = 0,
  }) =>
      _send('PUT', endpoint,
          data: body,
          queryParams: queryParams,
          headers: headers,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          maxRetries: maxRetries);

  Future<Response<dynamic>> patch(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    int maxRetries = 0,
  }) =>
      _send('PATCH', endpoint,
          data: body,
          queryParams: queryParams,
          headers: headers,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          maxRetries: maxRetries);

  Future<Response<dynamic>> delete(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) =>
      _send('DELETE', endpoint,
          data: body, queryParams: queryParams, headers: headers, cancelToken: cancelToken);

  /// Uploads files as multipart/form-data.
  ///
  /// Uses POST by default. Pass `method: 'PUT'` to replace an existing file.
  ///
  /// ```dart
  /// await apiClient.upload(
  ///   '/documents',
  ///   files: {'attachments': [file1, file2]},
  ///   fields: {'title': 'Report'},
  ///   onSendProgress: (sent, total) => print('${sent / total * 100}%'),
  /// );
  /// ```
  Future<Response<dynamic>> upload(
    String endpoint, {
    required Map<String, List<File>> files,
    String method = 'POST',
    Map<String, dynamic>? fields,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    final formData = FormData.fromMap(
      fields ?? {},
      ListFormat.multiCompatible,
    );

    for (final entry in files.entries) {
      for (final file in entry.value) {
        formData.files.add(
          MapEntry(
            entry.key,
            await MultipartFile.fromFile(
              file.path,
              filename: file.uri.pathSegments.last,
            ),
          ),
        );
      }
    }

    return _send(
      method,
      endpoint,
      data: formData,
      headers: headers,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }

  // ─── Internal ──────────────────────────────────────────────────────────────

  Future<Response<dynamic>> _send(
    String method,
    String endpoint, {
    Object? data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    ResponseType? responseType,
    int maxRetries = 0,
    Duration retryDelay = const Duration(seconds: 2),
  }) {
    return _retry(
      maxRetries: maxRetries,
      retryDelay: retryDelay,
      request: () => _dio.request(
        endpoint,
        data: data,
        queryParameters: queryParams,
        options: Options(
          method: method,
          headers: headers,
          responseType: responseType,
        ),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  /// Retries the [request] on transient failures (network errors, 5xx).
  Future<Response<dynamic>> _retry({
    required Future<Response<dynamic>> Function() request,
    required int maxRetries,
    required Duration retryDelay,
  }) async {
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await request();
      } on DioException catch (e) {
        final isLastAttempt = attempt == maxRetries;
        if (isLastAttempt || !_isRetryable(e)) {
          rethrow;
        }
        await Future<void>.delayed(retryDelay);
      }
    }
    // Unreachable — the loop always returns or rethrows.
    throw StateError('Retry loop exited unexpectedly');
  }

  bool _isRetryable(DioException e) {
    // Network / timeout errors
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return true;
    }
    // Server errors (5xx)
    final statusCode = e.response?.statusCode;
    return statusCode != null && statusCode >= 500;
  }
}
