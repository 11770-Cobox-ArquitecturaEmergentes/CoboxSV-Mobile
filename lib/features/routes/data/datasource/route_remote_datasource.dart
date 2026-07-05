import 'package:cobox_sv_mobile/core/api/dio_client.dart';
import 'package:cobox_sv_mobile/core/api/endpoints.dart';
import 'package:cobox_sv_mobile/core/errors/exceptions.dart';
import 'package:cobox_sv_mobile/features/authentication/data/datasource/auth_local_datasource.dart';
import 'package:cobox_sv_mobile/features/routes/data/models/route_model.dart';

class RouteRemoteDataSource {
  final DioClient _dio;
  final AuthLocalDataSource _authLocalDataSource;

  RouteRemoteDataSource(this._dio, this._authLocalDataSource);

  Future<List<RouteModel>> getRoutes({DateTime? date}) async {
    final currentUser = await _authLocalDataSource.getUser();
    final path = await _resolveRoutesPath(
      currentUserId: currentUser?.id,
      currentUserEmail: currentUser?.email,
    );

    final response = await _getRoutesResponse(path);

    if (response.data is! List) {
      throw const ServerException('Invalid routes response');
    }

    return (response.data as List<dynamic>)
        .map((json) => RouteModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<String> _resolveRoutesPath({
    required String? currentUserId,
    required String? currentUserEmail,
  }) async {
    final driverId = await _resolveDriverId(
      currentUserId: currentUserId,
      currentUserEmail: currentUserEmail,
    );

    if (driverId == null || driverId.isEmpty) {
      return Endpoints.routes;
    }

    return Endpoints.driverRoutes(driverId);
  }

  Future<String?> _resolveDriverId({
    required String? currentUserId,
    required String? currentUserEmail,
  }) async {
    if (currentUserEmail != null && currentUserEmail.isNotEmpty) {
      try {
        final response = await _dio.get(
          Endpoints.driverSearch,
          queryParameters: {'email': currentUserEmail},
        );
        final data = response.data as Map<String, dynamic>?;
        final resolvedId = data?['id']?.toString();
        if (resolvedId != null && resolvedId.isNotEmpty) {
          return resolvedId;
        }
      } on AppException catch (error) {
        if (!_shouldIgnoreDriverResolutionError(error)) {
          rethrow;
        }
      }
    }

    return currentUserId;
  }

  Future<dynamic> _getRoutesResponse(String path) async {
    try {
      final response = await _dio.get(path);
      return response;
    } on AppException catch (error) {
      final shouldFallbackToAllRoutes =
          path != Endpoints.routes && _shouldIgnoreDriverResolutionError(error);

      if (shouldFallbackToAllRoutes) {
        return _dio.get(Endpoints.routes);
      }
      rethrow;
    }
  }

  bool _shouldIgnoreDriverResolutionError(AppException error) {
    final message = error.message.toLowerCase();
    return error.statusCode == 404 ||
        error.statusCode == 500 &&
            (message.contains('driver not found') ||
                message.contains('contexto fleet'));
  }

  Future<RouteModel> getRouteDetail(String id) async {
    final response = await _dio.get('${Endpoints.routeDetail}$id');
    if (response.data is! Map<String, dynamic>) {
      throw const ServerException('Invalid route detail response');
    }

    return RouteModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RouteModel> startRoute(String id) async {
    final response = await _dio.patch(
      '${Endpoints.startRoute}$id/in-progress',
    );
    if (response.data is! Map<String, dynamic>) {
      throw const ServerException('Invalid start route response');
    }

    return RouteModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RouteModel> completeStop(String routeId, String stopId) async {
    final response = await _dio.post(
      '${Endpoints.routeDetail}$routeId/delivered-orders',
      data: {'orderId': int.tryParse(stopId)},
    );
    if (response.data is! Map<String, dynamic>) {
      throw const ServerException('Invalid complete stop response');
    }

    return RouteModel.fromJson(response.data as Map<String, dynamic>);
  }
}
