import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import 'package:cobox_sv_mobile/app/constants.dart';
import 'package:cobox_sv_mobile/core/api/endpoints.dart';
import 'package:cobox_sv_mobile/core/errors/exceptions.dart';

class _PendingRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;

  _PendingRequest({required this.options, required this.handler});
}

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;
  final Dio dio;

  AuthInterceptor({
    required this.secureStorage,
    required this.dio,
  });

  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  bool _isPublicAuthPath(String path) {
    return path == Endpoints.login ||
        path == Endpoints.register ||
        path == Endpoints.refreshToken ||
        path == Endpoints.forgotPassword ||
        path == Endpoints.resetPassword;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (_isPublicAuthPath(options.path)) {
      options.headers.remove('Authorization');
      handler.next(options);
      return;
    }

    try {
      final token = await secureStorage.read(
        key: AppConstants.storageAuthToken,
      );
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    if (_isPublicAuthPath(err.requestOptions.path)) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      _pendingRequests.add(_PendingRequest(options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await secureStorage.read(
        key: AppConstants.storageRefreshToken,
      );
      if (refreshToken == null || refreshToken.isEmpty) {
        handler.next(err);
        return;
      }

      final response = await dio.post(
        Endpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final newToken = response.data['accessToken'] as String?;
      if (newToken == null || newToken.isEmpty) {
        throw UnauthorizedException('Invalid refresh response');
      }

      final newRefreshToken = response.data['refreshToken'] as String? ?? refreshToken;

      await secureStorage.write(
        key: AppConstants.storageAuthToken,
        value: newToken,
      );
      await secureStorage.write(
        key: AppConstants.storageRefreshToken,
        value: newRefreshToken,
      );

      final pending = List<_PendingRequest>.from(_pendingRequests);
      _pendingRequests.clear();

      for (final p in pending) {
        p.options.headers['Authorization'] = 'Bearer $newToken';
        try {
          final r = await dio.fetch(p.options);
          p.handler.resolve(r);
        } catch (e) {
          p.handler.reject(e as DioException);
        }
      }

      err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      final retryResponse = await dio.fetch(err.requestOptions);
      handler.resolve(retryResponse);
    } catch (e) {
      await secureStorage.delete(key: AppConstants.storageAuthToken);
      await secureStorage.delete(key: AppConstants.storageRefreshToken);

      final pending = List<_PendingRequest>.from(_pendingRequests);
      _pendingRequests.clear();

      for (final p in pending) {
        p.handler.reject(err);
      }

      handler.reject(DioException(
        requestOptions: err.requestOptions,
        error: e is AppException ? e : UnauthorizedException('Session expired. Please login again.'),
        response: err.response,
      ));
    } finally {
      _isRefreshing = false;
    }
  }
}

class LoggingInterceptor extends Interceptor {
  final Logger _logger;

  LoggingInterceptor({Logger? logger}) : _logger = logger ?? Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i('--> ${options.method} ${options.path}');
    _logger.d('Headers: ${options.headers}');
    if (options.data != null) {
      _logger.d('Body: ${options.data}');
    }
    _logger.i('--> END ${options.method}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i('<-- ${response.statusCode} ${response.requestOptions.path}');
    _logger.d('Response: ${response.data}');
    _logger.i('<-- END HTTP');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('<-- ${err.response?.statusCode ?? 'N/A'} ${err.requestOptions.path}');
    _logger.e('Error: ${err.message}');
    if (err.response != null) {
      _logger.e('Response data: ${err.response?.data}');
    }
    _logger.e('<-- END ERROR');
    handler.next(err);
  }
}

class ErrorInterceptor extends Interceptor {
  final Logger _logger;

  ErrorInterceptor({Logger? logger}) : _logger = logger ?? Logger();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is AppException) {
      handler.next(err);
      return;
    }

    if (err.response?.statusCode == 401) {
      handler.next(err);
      return;
    }

    final appException = _mapToAppException(err);
    _logger.e('Error: ${appException.message}');

    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: appException,
      response: err.response,
      type: err.type,
    ));
  }

  AppException _mapToAppException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Request timed out. Please try again.');
      case DioExceptionType.connectionError:
        return NetworkException('No internet connection.');
      case DioExceptionType.cancel:
        return AppException('Request was cancelled.');
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        final message = _extractMessage(err.response);
        switch (statusCode) {
          case 403:
            return ForbiddenException(message);
          case 404:
            return NotFoundException(message);
          case 409:
            return ConflictException(message);
          case 422:
            final errors = err.response?.data is Map
                ? (err.response!.data as Map)['errors'] as Map<String, dynamic>?
                : null;
            return ValidationException(message, errors);
          case 500:
          case 501:
          case 502:
          case 503:
            return ServerException(message);
          default:
            return AppException(message, statusCode: statusCode);
        }
      case DioExceptionType.badCertificate:
        return AppException('Invalid server certificate.');
      case DioExceptionType.unknown:
        if (err.message != null && err.message!.contains('SocketException')) {
          return NetworkException('No internet connection.');
        }
        return AppException(err.message ?? 'An unexpected error occurred.');
    }
  }

  String _extractMessage(Response? response) {
    if (response?.data is Map) {
      final msg = (response!.data as Map)['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return response?.statusMessage ?? 'An error occurred';
  }
}
