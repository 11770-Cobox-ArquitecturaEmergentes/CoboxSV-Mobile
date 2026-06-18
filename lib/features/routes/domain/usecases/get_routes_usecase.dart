import 'package:cobox_sv_mobile/features/routes/domain/entities/route_entity.dart';
import 'package:cobox_sv_mobile/features/routes/domain/repository/route_repository.dart';

class GetRoutesUseCase {
  final RouteRepository _repository;

  GetRoutesUseCase(this._repository);

  Future<List<RouteEntity>> call({DateTime? date}) {
    return _repository.getRoutes(date: date);
  }
}
