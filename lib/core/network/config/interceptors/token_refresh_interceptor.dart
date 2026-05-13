import 'package:dio/dio.dart';
import 'package:flutter_specialized_temp/core/logger/app_logger.dart';
import 'package:flutter_specialized_temp/core/network/config/dio_client.dart'
    show DioClient;
import 'package:flutter_specialized_temp/core/network/config/interceptors/retry_interceptor.dart'
    show RetryInterceptor;
import 'package:flutter_specialized_temp/core/storage/app_storage.dart';
import 'package:flutter_specialized_temp/core/storage/storage_keys.dart';

/// Intercepts 401 Unauthorized responses and attempts a silent token refresh.
///
/// Flow:
///  1. 401 received → try to refresh via [refreshPath] using the stored refresh token.
///  2. Refresh succeeds → save new tokens, retry the original request (once).
///  3. Refresh fails (or no refresh token) → clear all auth data so the router
///     redirect logic picks up the unauthenticated state and navigates to login.
///
/// Concurrent 401s are queued while a refresh is in flight so only one refresh
/// call is ever made per token lifetime.
///
/// ## Wiring
/// Call [dio =] after the [Dio] instance is fully built (same pattern as
/// [RetryInterceptor]) so the interceptor can replay requests through the
/// complete interceptor chain with the new token.
class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor({
    required AppStorage appStorage,
    this.refreshPath = '/auth/refresh',
  }) : _appStorage = appStorage;
  final AppStorage _appStorage;

  /// Override in your project to match your actual refresh endpoint.
  final String refreshPath;

  Dio? _dio;

  /// Guards against concurrent refresh attempts.
  bool _isRefreshing = false;

  /// Requests that arrived with a 401 while a refresh was already in flight.
  final List<_PendingRequest> _queue = [];

  /// Must be called by [DioClient] after the [Dio] instance is created.
  Dio get dio => _dio ?? Dio();
  set dio(Dio value) => _dio = value;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // The refresh call itself returned 401 → token is definitely invalid.
    if (err.requestOptions.extra['tokenRefreshAttempted'] == true) {
      await _clearAuth();
      return handler.next(err);
    }

    // Another refresh is already running — queue this request.
    if (_isRefreshing) {
      _queue.add(_PendingRequest(err.requestOptions, handler));
      return;
    }

    _isRefreshing = true;

    final refreshed = await _attemptRefresh();

    if (refreshed) {
      // Mark so a second 401 on the retry doesn't loop.
      err.requestOptions.extra['tokenRefreshAttempted'] = true;
      await _retry(err.requestOptions, handler);

      for (final pending in _queue) {
        pending.options.extra['tokenRefreshAttempted'] = true;
        await _retry(pending.options, pending.handler);
      }
    } else {
      await _clearAuth();
      handler.next(err);
      for (final pending in _queue) {
        pending.handler.next(err);
      }
    }

    _queue.clear();
    _isRefreshing = false;
  }

  Future<bool> _attemptRefresh() async {
    try {
      final storedRefreshToken = await _appStorage.secure.readSecureData(
        StorageKeys.refreshToken,
      );

      if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
        AppLogger.w(message: 'TokenRefreshInterceptor: no refresh token found');
        return false;
      }

      // Use a bare Dio instance to bypass the interceptor chain and avoid loops.
      final refreshDio = Dio(BaseOptions(baseUrl: _dio?.options.baseUrl ?? ''));

      final response = await refreshDio.post<Map<String, dynamic>>(
        refreshPath,
        data: {'refresh_token': storedRefreshToken},
      );

      final data = response.data;
      // Support both snake_case and camelCase server responses.
      final newAccess =
          data?['access_token'] as String? ?? data?['accessToken'] as String?;
      final newRefresh =
          data?['refresh_token'] as String? ?? data?['refreshToken'] as String?;

      if (newAccess == null || newAccess.isEmpty) {
        AppLogger.w(
          message:
              'TokenRefreshInterceptor: refresh response missing access token',
        );
        return false;
      }

      await _appStorage.secure.saveAuthTokens(
        accessToken: newAccess,
        refreshToken: newRefresh ?? storedRefreshToken,
      );

      AppLogger.i(
        message: 'TokenRefreshInterceptor: token refreshed successfully',
      );
      return true;
    } catch (e) {
      AppLogger.w(message: 'TokenRefreshInterceptor: refresh failed', error: e);
      return false;
    }
  }

  Future<void> _retry(
    RequestOptions options,
    ErrorInterceptorHandler handler,
  ) async {
    final dio = _dio;
    if (dio == null) {
      handler.next(DioException(requestOptions: options));
      return;
    }
    try {
      final response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<void> _clearAuth() async {
    AppLogger.w(
      message: 'TokenRefreshInterceptor: clearing auth data, redirect to login',
    );
    await _appStorage.clearAllData();
  }
}

class _PendingRequest {
  _PendingRequest(this.options, this.handler);
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
}
