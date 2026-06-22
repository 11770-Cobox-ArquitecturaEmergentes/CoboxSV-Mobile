import 'package:cobox_sv_mobile/features/planning/domain/entities/plan_entity.dart';
import 'package:cobox_sv_mobile/features/planning/domain/repository/planning_repository.dart';

class MockPlanningRepositoryImpl implements PlanningRepository {
  const MockPlanningRepositoryImpl();

  @override
  Future<List<PlanEntity>> getPlans({DateTime? date}) async {
    return [
      PlanEntity(
        id: 'plan-1',
        title: 'Planificar ruta',
        date: date ?? DateTime(2026, 6, 18),
        shift: 'manana',
        status: 'CALCULATED',
        stopsCount: 3,
        totalDistance: 24.5,
        estimatedDuration: const Duration(minutes: 28),
        routeIds: const ['201', '202', '203'],
        notes: 'Mock basado en fleet-service RouteResource',
      ),
    ];
  }

  @override
  Future<PlanEntity> getPlanDetail(String id) async {
    return PlanEntity(
      id: id,
      title: 'Planificar ruta',
      date: DateTime(2026, 6, 18),
      shift: 'manana',
      status: 'CALCULATED',
      stopsCount: 3,
      totalDistance: 24.5,
      estimatedDuration: const Duration(minutes: 28),
      routeIds: const ['201', '202', '203'],
      notes: 'Detalle de plan mock',
    );
  }

  @override
  Future<void> updatePlanStatus(String id, String status) async {}
}
