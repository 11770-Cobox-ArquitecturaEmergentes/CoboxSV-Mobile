import 'package:cobox_sv_mobile/core/errors/error_handler.dart';
import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/core/network/network_info.dart';
import 'package:cobox_sv_mobile/features/routes/data/datasource/route_remote_datasource.dart';
import 'package:cobox_sv_mobile/features/routes/domain/entities/route_entity.dart';
import 'package:cobox_sv_mobile/features/routes/domain/repository/route_repository.dart';

class RouteRepositoryImpl implements RouteRepository {
  final RouteRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  RouteRepositoryImpl(
    this._remoteDataSource,
    this._networkInfo,
  );

  @override
  Future<List<RouteEntity>> getRoutes({DateTime? date}) async {
    try {
      final isConnected = await _networkInfo.checkConnectivity();
      if (!isConnected) {
        throw const NetworkFailure(
          message: 'No se pudo cargar la informacion. Intenta nuevamente.',
        );
      }

      final models = await _remoteDataSource.getRoutes(date: date);
      return models.map((m) => m.toEntity()).toList();
    } on Failure {
      rethrow;
    } catch (e) {
      if (e is Failure) rethrow;
      throw handleException(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<RouteEntity> getRouteDetail(String id) async {
    try {
      final isConnected = await _networkInfo.checkConnectivity();
      if (!isConnected) {
        throw const NetworkFailure(
          message: 'No se pudo cargar la informacion. Intenta nuevamente.',
        );
      }

      final model = await _remoteDataSource.getRouteDetail(id);
      return model.toEntity();
    } on Failure {
      rethrow;
    } catch (e) {
      if (e is Failure) rethrow;
      throw handleException(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<RouteEntity> startRoute(String id) async {
    try {
      final isConnected = await _networkInfo.checkConnectivity();
      if (!isConnected) {
        throw const NetworkFailure(
          message: 'No se pudo cargar la informacion. Intenta nuevamente.',
        );
      }

      final model = await _remoteDataSource.startRoute(id);
      return model.toEntity();
    } on Failure {
      rethrow;
    } catch (e) {
      if (e is Failure) rethrow;
      throw handleException(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<RouteEntity> completeStop(String routeId, String stopId) async {
    try {
      final isConnected = await _networkInfo.checkConnectivity();
      if (!isConnected) {
        throw const NetworkFailure(
          message: 'No se pudo cargar la informacion. Intenta nuevamente.',
        );
      }

      final model = await _remoteDataSource.completeStop(routeId, stopId);
      return model.toEntity();
    } on Failure {
      rethrow;
    } catch (e) {
      if (e is Failure) rethrow;
      throw handleException(e is Exception ? e : Exception(e.toString()));
    }
  }
}
