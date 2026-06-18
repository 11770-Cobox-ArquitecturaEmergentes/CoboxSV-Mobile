import 'package:cobox_sv_mobile/core/api/api_response.dart';
import 'package:cobox_sv_mobile/core/api/dio_client.dart';
import 'package:cobox_sv_mobile/core/api/endpoints.dart';
import 'package:cobox_sv_mobile/core/errors/exceptions.dart';
import 'package:cobox_sv_mobile/features/planning/data/models/plan_model.dart';

class PlanningRemoteDataSource {
  final DioClient _dio;

  PlanningRemoteDataSource(this._dio);

  Future<List<PlanModel>> getPlans({DateTime? date}) async {
    final params = <String, dynamic>{};
    if (date != null) {
      params['date'] = date.toIso8601String().split('T').first;
    }

    final response = await _dio.get(
      Endpoints.plans,
      queryParameters: params,
    );

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data,
      (data) => data as List<dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw ServerException(apiResponse.message ?? 'Failed to fetch plans');
    }

    return apiResponse.data!
        .map((json) => PlanModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<PlanModel> getPlanDetail(String id) async {
    final response = await _dio.get('${Endpoints.planDetail}$id');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw ServerException(apiResponse.message ?? 'Failed to fetch plan detail');
    }

    return PlanModel.fromJson(apiResponse.data!);
  }

  Future<void> updatePlanStatus(String id, String status) async {
    final response = await _dio.patch(
      '${Endpoints.planDetail}$id',
      data: {'status': status},
    );

    final apiResponse = ApiResponse<dynamic>.fromJson(response.data, null);

    if (!apiResponse.success) {
      throw ServerException(apiResponse.message ?? 'Failed to update plan status');
    }
  }
}
