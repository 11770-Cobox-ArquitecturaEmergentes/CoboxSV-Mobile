import 'package:cobox_sv_mobile/features/routes/domain/entities/route_entity.dart';
import 'package:cobox_sv_mobile/features/routes/domain/repository/route_repository.dart';

class CompleteStopUseCase {
  final RouteRepository _repository;

  CompleteStopUseCase(this._repository);

  Future<RouteEntity> call(String routeId, String stopId) {
    return _repository.completeStop(routeId, stopId);
  }
}
