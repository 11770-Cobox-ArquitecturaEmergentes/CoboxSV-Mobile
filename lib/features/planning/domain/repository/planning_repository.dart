import 'package:cobox_sv_mobile/features/planning/domain/entities/plan_entity.dart';

abstract class PlanningRepository {
  Future<List<PlanEntity>> getPlans({DateTime? date});

  Future<PlanEntity> getPlanDetail(String id);

  Future<void> updatePlanStatus(String id, String status);
}
