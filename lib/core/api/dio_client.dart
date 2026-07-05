import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import 'package:cobox_sv_mobile/core/api/endpoints.dart';
import 'package:cobox_sv_mobile/core/api/interceptors.dart';
import 'package:cobox_sv_mobile/core/errors/exceptions.dart';

class DioClient {
  static DioClient? _instance;
  late final Dio _dio;
  late final Logger _logger;

  DioClient._internal({
    required FlutterSecureStorage secureStorage,
    Logger? logger,
  }) {
    _logger = logger ?? Logger();

    _dio = Dio(
      BaseOptions(
        baseUrl: Endpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(
        secureStorage: secureStorage,
      ),
      LoggingInterceptor(logger: _logger),
      ErrorInterceptor(logger: _logger),
    ]);
  }

  static DioClient getInstance({
    FlutterSecureStorage? secureStorage,
    Logger? logger,
  }) {
    _instance ??= DioClient._internal(
      secureStorage: secureStorage ?? const FlutterSecureStorage(),
      logger: logger,
    );
    return _instance!;
  }

  Future<Response> _request(Future<Response> Function() requestFn) async {
    try {
      return await requestFn();
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw AppException(e.message ?? 'An unexpected error occurred');
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request(() => _dio.get(
          path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ));
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request(() => _dio.post(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ));
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request(() => _dio.put(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ));
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request(() => _dio.patch(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ));
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request(() => _dio.delete(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ));
  }

  Future<Response> upload(
    String path, {
    required Map<String, File> files,
    Map<String, dynamic>? fields,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    final formData = FormData();
    for (final entry in files.entries) {
      final multipartFile = await MultipartFile.fromFile(
        entry.value.path,
        filename: entry.value.path.split('/').last,
      );
      formData.files.add(MapEntry(entry.key, multipartFile));
    }
    if (fields != null) {
      for (final entry in fields.entries) {
        formData.fields.add(MapEntry(entry.key, entry.value.toString()));
      }
    }
    return _request(() => _dio.post(
          path,
          data: formData,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
        ));
  }
}
