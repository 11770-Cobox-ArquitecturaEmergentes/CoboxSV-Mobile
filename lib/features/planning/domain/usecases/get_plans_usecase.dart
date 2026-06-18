import 'package:cobox_sv_mobile/features/planning/domain/entities/plan_entity.dart';
import 'package:cobox_sv_mobile/features/planning/domain/repository/planning_repository.dart';

class GetPlansUseCase {
  final PlanningRepository _repository;

  GetPlansUseCase(this._repository);

  Future<List<PlanEntity>> call({DateTime? date}) {
    return _repository.getPlans(date: date);
  }
}
