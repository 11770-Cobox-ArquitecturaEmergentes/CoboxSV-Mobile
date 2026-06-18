import 'package:cobox_sv_mobile/features/routes/domain/entities/route_entity.dart';
import 'package:cobox_sv_mobile/features/routes/domain/repository/route_repository.dart';

class GetRouteDetailUseCase {
  final RouteRepository _repository;

  GetRouteDetailUseCase(this._repository);

  Future<RouteEntity> call(String id) {
    return _repository.getRouteDetail(id);
  }
}
