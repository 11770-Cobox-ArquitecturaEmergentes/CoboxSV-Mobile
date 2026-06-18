import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cobox_sv_mobile/app/providers.dart';
import 'package:cobox_sv_mobile/features/planning/domain/entities/plan_entity.dart';
import 'package:cobox_sv_mobile/features/planning/domain/repository/planning_repository.dart';
import 'package:cobox_sv_mobile/features/planning/domain/usecases/get_plans_usecase.dart';
import 'package:cobox_sv_mobile/features/planning/domain/usecases/get_plan_detail_usecase.dart';
import 'package:cobox_sv_mobile/features/planning/data/datasource/planning_local_datasource.dart';
import 'package:cobox_sv_mobile/features/planning/data/datasource/planning_remote_datasource.dart';
import 'package:cobox_sv_mobile/features/planning/data/repository/planning_repository_impl.dart';

final planningRemoteDataSourceProvider = Provider<PlanningRemoteDataSource>((ref) {
  return PlanningRemoteDataSource(ref.watch(dioClientProvider));
});

final planningLocalDataSourceProvider = Provider<PlanningLocalDataSource>((ref) {
  return PlanningLocalDataSource(ref.watch(localStorageProvider));
});

final planningRepositoryProvider = Provider<PlanningRepository>((ref) {
  return PlanningRepositoryImpl(
    ref.watch(planningRemoteDataSourceProvider),
    ref.watch(planningLocalDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

final getPlansUseCaseProvider = Provider<GetPlansUseCase>((ref) {
  return GetPlansUseCase(ref.watch(planningRepositoryProvider));
});

final getPlanDetailUseCaseProvider = Provider<GetPlanDetailUseCase>((ref) {
  return GetPlanDetailUseCase(ref.watch(planningRepositoryProvider));
});

final plansProvider = FutureProvider.autoDispose.family<List<PlanEntity>, DateTime?>((ref, date) {
  return ref.watch(getPlansUseCaseProvider).call(date: date);
});

final planDetailProvider = FutureProvider.autoDispose.family<PlanEntity, String>((ref, id) {
  return ref.watch(getPlanDetailUseCaseProvider).call(id);
});

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class PlanningNotifier extends StateNotifier<AsyncValue<List<PlanEntity>>> {
  final GetPlansUseCase _getPlans;

  PlanningNotifier(this._getPlans) : super(const AsyncValue.loading());

  Future<void> loadPlans({DateTime? date}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _getPlans(date: date));
  }

  Future<void> refresh({DateTime? date}) async {
    state = await AsyncValue.guard(() => _getPlans(date: date));
  }
}

final planningNotifierProvider =
    StateNotifierProvider<PlanningNotifier, AsyncValue<List<PlanEntity>>>((ref) {
  final getPlans = ref.watch(getPlansUseCaseProvider);
  return PlanningNotifier(getPlans);
});
