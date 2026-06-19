import 'package:cobox_sv_mobile/core/api/api_response.dart';
import 'package:cobox_sv_mobile/core/api/dio_client.dart';
import 'package:cobox_sv_mobile/core/api/endpoints.dart';
import 'package:cobox_sv_mobile/core/errors/exceptions.dart';
import 'package:cobox_sv_mobile/features/routes/data/models/route_model.dart';

class RouteRemoteDataSource {
  final DioClient _dio;

  RouteRemoteDataSource(this._dio);

  Future<List<RouteModel>> getRoutes({DateTime? date}) async {
    final params = <String, dynamic>{};
    if (date != null) {
      params['date'] = date.toIso8601String().split('T').first;
    }

    final response = await _dio.get(
      Endpoints.routes,
      queryParameters: params,
    );

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data,
      (data) => data as List<dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw ServerException(apiResponse.message ?? 'Failed to fetch routes');
    }

    return apiResponse.data!
        .map((json) => RouteModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<RouteModel> getRouteDetail(String id) async {
    final response = await _dio.get('${Endpoints.routeDetail}$id');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw ServerException(apiResponse.message ?? 'Failed to fetch route detail');
    }

    return RouteModel.fromJson(apiResponse.data!);
  }

  Future<RouteModel> startRoute(String id) async {
    final response = await _dio.patch(
      '${Endpoints.startRoute}$id/in-progress',
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw ServerException(apiResponse.message ?? 'Failed to start route');
    }

    return RouteModel.fromJson(apiResponse.data!);
  }

  Future<RouteModel> completeStop(String routeId, String stopId) async {
    final response = await _dio.post(
      '${Endpoints.routeDetail}$routeId/delivered-orders',
      data: {'orderId': int.tryParse(stopId)},
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw ServerException(apiResponse.message ?? 'Failed to complete stop');
    }

    return RouteModel.fromJson(apiResponse.data!);
  }
}
