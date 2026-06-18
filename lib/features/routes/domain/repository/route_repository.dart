import 'package:cobox_sv_mobile/features/routes/domain/entities/route_entity.dart';

abstract class RouteRepository {
  Future<List<RouteEntity>> getRoutes({DateTime? date});

  Future<RouteEntity> getRouteDetail(String id);

  Future<RouteEntity> startRoute(String id);

  Future<RouteEntity> completeStop(String routeId, String stopId);
}
