import 'package:cobox_sv_mobile/core/api/dio_client.dart';
import 'package:cobox_sv_mobile/core/api/endpoints.dart';
import 'package:cobox_sv_mobile/core/errors/exceptions.dart';
import 'package:cobox_sv_mobile/features/authentication/data/datasource/auth_local_datasource.dart';
import 'package:cobox_sv_mobile/features/planning/data/models/plan_model.dart';
import 'package:cobox_sv_mobile/features/routes/data/models/route_model.dart';

class PlanningRemoteDataSource {
  final DioClient _dio;
  final AuthLocalDataSource _authLocalDataSource;

  PlanningRemoteDataSource(this._dio, this._authLocalDataSource);

  Future<List<PlanModel>> getPlans({DateTime? date}) async {
    final routesPath = await _resolveRoutesPath();
    final response = await _dio.get(routesPath);
    if (response.data is! List) {
      throw const ServerException('Invalid planning routes response');
    }

    final plans = (response.data as List<dynamic>)
        .map((json) => RouteModel.fromJson(json as Map<String, dynamic>))
        .map(PlanModel.fromRouteModel)
        .toList();

    if (date == null) {
      return plans;
    }

    final filterDate = DateTime(date.year, date.month, date.day);
    return plans.where((plan) {
      final planDate = DateTime(plan.date.year, plan.date.month, plan.date.day);
      return planDate == filterDate;
    }).toList();
  }

  Future<PlanModel> getPlanDetail(String id) async {
    final response = await _dio.get('${Endpoints.routeDetail}$id');
    if (response.data is! Map<String, dynamic>) {
      throw const ServerException('Invalid planning detail response');
    }

    final route = RouteModel.fromJson(response.data as Map<String, dynamic>);
    return PlanModel.fromRouteModel(route);
  }

  Future<void> updatePlanStatus(String id, String status) async {
    if (status.toUpperCase() != 'IN_PROGRESS') {
      throw const ServerException(
        'El backend actual solo permite iniciar rutas desde planificacion',
      );
    }

    await _dio.patch(
      '${Endpoints.startRoute}$id/in-progress',
    );
  }

  Future<String> _resolveRoutesPath() async {
    final currentUser = await _authLocalDataSource.getUser();
    final driverId = await _resolveDriverId(
      currentUserId: currentUser?.id,
      currentUserEmail: currentUser?.email,
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

  bool _shouldIgnoreDriverResolutionError(AppException error) {
    final message = error.message.toLowerCase();
    return error.statusCode == 404 ||
        error.statusCode == 500 &&
            (message.contains('driver not found') ||
                message.contains('contexto fleet'));
  }
}
