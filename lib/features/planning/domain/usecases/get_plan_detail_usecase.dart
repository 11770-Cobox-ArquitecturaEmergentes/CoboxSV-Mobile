import 'package:cobox_sv_mobile/features/planning/domain/entities/plan_entity.dart';
import 'package:cobox_sv_mobile/features/planning/domain/repository/planning_repository.dart';

class GetPlanDetailUseCase {
  final PlanningRepository _repository;

  GetPlanDetailUseCase(this._repository);

  Future<PlanEntity> call(String id) {
    return _repository.getPlanDetail(id);
  }
}
