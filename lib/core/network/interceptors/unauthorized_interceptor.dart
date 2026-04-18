import 'package:dio/dio.dart';

import '../../constants/api_endpoints.dart';
import '../../constants/environment_config.dart';
import '../../constants/hive/storage_keys.dart';
import '../../routing/app_route.dart';
import '../../routing/navigation_service.dart';
import '../../storage/hive/hive_boxes.dart';

/// Handles 401 responses by clearing auth data and redirecting to login.
///
/// Skips the login endpoint itself to avoid redirect loops.
class UnauthorizedInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 && !_isLoginRequest(err)) {
      _handleUnauthorized();
    }
    handler.next(err);
  }

  bool _isLoginRequest(DioException err) {
    final requestUri = err.requestOptions.uri.toString();
    final loginUri = '${EnvironmentConfig.apiBaseUrl}${ApiEndpoints.login}';
    return requestUri == loginUri;
  }

  Future<void> _handleUnauthorized() async {
    await HiveBoxes.appBox.delete(StorageKeys.authToken);
    await HiveBoxes.appBox.delete(StorageKeys.userData);
    await NavigationService.clearAndPush<void>(AppRoute.loginScreen);
  }
}
