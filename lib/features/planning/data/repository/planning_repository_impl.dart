import 'package:cobox_sv_mobile/core/errors/error_handler.dart';
import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/core/network/network_info.dart';
import 'package:cobox_sv_mobile/features/planning/data/datasource/planning_local_datasource.dart';
import 'package:cobox_sv_mobile/features/planning/data/datasource/planning_remote_datasource.dart';
import 'package:cobox_sv_mobile/features/planning/domain/entities/plan_entity.dart';
import 'package:cobox_sv_mobile/features/planning/domain/repository/planning_repository.dart';

class PlanningRepositoryImpl implements PlanningRepository {
  final PlanningRemoteDataSource _remoteDataSource;
  final PlanningLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  PlanningRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<List<PlanEntity>> getPlans({DateTime? date}) async {
    try {
      final isConnected = await _networkInfo.checkConnectivity();
      if (isConnected) {
        final models = await _remoteDataSource.getPlans(date: date);
        await _localDataSource.cachePlans(models);
        return models.map((m) => m.toEntity()).toList();
      }

      final cached = await _localDataSource.getCachedPlans();
      if (cached != null) {
        return cached.map((m) => m.toEntity()).toList();
      }

      throw const NetworkFailure(
        message: 'No se pudo cargar la informacion. Intenta nuevamente.',
      );
    } on Failure {
      rethrow;
    } catch (e) {
      if (e is Failure) rethrow;
      final cached = await _localDataSource.getCachedPlans();
      if (cached != null) {
        return cached.map((m) => m.toEntity()).toList();
      }
      throw handleException(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<PlanEntity> getPlanDetail(String id) async {
    try {
      final isConnected = await _networkInfo.checkConnectivity();
      if (isConnected) {
        final model = await _remoteDataSource.getPlanDetail(id);
        await _localDataSource.cachePlanDetail(model);
        return model.toEntity();
      }

      final cached = await _localDataSource.getCachedPlanDetail(id);
      if (cached != null) {
        return cached.toEntity();
      }

      throw const NetworkFailure(
        message: 'No se pudo cargar la informacion. Intenta nuevamente.',
      );
    } on Failure {
      rethrow;
    } catch (e) {
      if (e is Failure) rethrow;
      final cached = await _localDataSource.getCachedPlanDetail(id);
      if (cached != null) {
        return cached.toEntity();
      }
      throw handleException(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<void> updatePlanStatus(String id, String status) async {
    try {
      await _remoteDataSource.updatePlanStatus(id, status);
    } on Failure {
      rethrow;
    } catch (e) {
      if (e is Failure) rethrow;
      throw handleException(e is Exception ? e : Exception(e.toString()));
    }
  }
}
