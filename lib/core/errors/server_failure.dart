import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_starter/generated/locale_keys.dart';

import 'failure.dart';

/// Failure produced by network/server errors.
///
/// Error code ranges:
///   10xx — Dio / transport errors
///   4xx  — HTTP client errors  (from server response)
///   5xx  — HTTP server errors  (from server response)
class ServerFailure extends Failure {
  ServerFailure(super.message, {super.errorCode = 1000});

  // ─── From Dio ─────────────────────────────────────────────────────────────

  factory ServerFailure.fromDioError(DioException dioError) {
    return switch (dioError.type) {
      DioExceptionType.connectionTimeout => ServerFailure(
          LocaleKeys.connectionTimeoutWithApiServer,
          errorCode: 1001,
        ),
      DioExceptionType.sendTimeout => ServerFailure(
          LocaleKeys.sendTimeoutToApiServer,
          errorCode: 1002,
        ),
      DioExceptionType.receiveTimeout => ServerFailure(
          LocaleKeys.receiveTimeoutFromApiServer,
          errorCode: 1003,
        ),
      DioExceptionType.cancel => ServerFailure(
          LocaleKeys.requestToApiServerWasCanceled,
          errorCode: 1004,
        ),
      DioExceptionType.badCertificate => ServerFailure(
          LocaleKeys
              .theServerCertificateIsInvalidPleaseCheckYourNetworkSecuritySettings,
          errorCode: 1005,
        ),
      DioExceptionType.connectionError => ServerFailure(
          LocaleKeys
              .failedToConnectToTheServerPleaseCheckYourInternetConnectionOrTryAgainLater,
          errorCode: 1006,
        ),
      DioExceptionType.badResponse => ServerFailure.fromResponse(
          dioError.response?.statusCode,
          dioError.response?.data,
        ),
      DioExceptionType.unknown => dioError.error is SocketException
          ? ServerFailure(
              LocaleKeys.noInternetConnection,
              errorCode: 1007,
            )
          : ServerFailure(
              LocaleKeys.unexpectedErrorPleaseTryAgain,
              errorCode: 1008,
            ),
    };
  }

  // ─── From HTTP response ───────────────────────────────────────────────────

  factory ServerFailure.fromResponse(int? statusCode, Object? responseData) {
    final message = _extractErrorMessage(responseData);

    return switch (statusCode) {
      // 4xx — use server-provided message
      400 ||
      401 ||
      403 ||
      404 ||
      409 ||
      422 ||
      429 =>
        ServerFailure(message, errorCode: statusCode!),

      // 5xx — server-side error
      final int s when s >= 500 => ServerFailure(
          LocaleKeys.internalServerErrorPleaseTryLater,
          errorCode: s,
        ),

      // Unknown status
      _ => ServerFailure(
          LocaleKeys.oopsThereWasAnErrorPleaseTryAgain,
          errorCode: statusCode ?? 500,
        ),
    };
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static String _extractErrorMessage(Object? responseData) {
    if (responseData is Map<String, dynamic>) {
      return switch (responseData['message']) {
        final String m => m,
        final List<dynamic> msgs => msgs.join(', '),
        _ => LocaleKeys.badRequest,
      };
    }
    return LocaleKeys.badRequest;
  }
}
