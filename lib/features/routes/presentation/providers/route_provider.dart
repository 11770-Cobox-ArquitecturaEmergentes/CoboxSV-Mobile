import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cobox_sv_mobile/app/providers.dart';
import 'package:cobox_sv_mobile/features/routes/domain/entities/route_entity.dart';
import 'package:cobox_sv_mobile/features/routes/domain/repository/route_repository.dart';
import 'package:cobox_sv_mobile/features/routes/domain/usecases/get_routes_usecase.dart';
import 'package:cobox_sv_mobile/features/routes/domain/usecases/get_route_detail_usecase.dart';
import 'package:cobox_sv_mobile/features/routes/domain/usecases/start_route_usecase.dart';
import 'package:cobox_sv_mobile/features/routes/domain/usecases/complete_stop_usecase.dart';
import 'package:cobox_sv_mobile/features/routes/data/datasource/route_remote_datasource.dart';
import 'package:cobox_sv_mobile/features/routes/data/repository/route_repository_impl.dart';
import 'package:cobox_sv_mobile/features/authentication/presentation/providers/auth_provider.dart';

final routeRemoteDataSourceProvider = Provider<RouteRemoteDataSource>((ref) {
  return RouteRemoteDataSource(
    ref.watch(dioClientProvider),
    ref.watch(authLocalDataSourceProvider),
  );
});

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return RouteRepositoryImpl(
    ref.watch(routeRemoteDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

final getRoutesUseCaseProvider = Provider<GetRoutesUseCase>((ref) {
  return GetRoutesUseCase(ref.watch(routeRepositoryProvider));
});

final getRouteDetailUseCaseProvider = Provider<GetRouteDetailUseCase>((ref) {
  return GetRouteDetailUseCase(ref.watch(routeRepositoryProvider));
});

final startRouteUseCaseProvider = Provider<StartRouteUseCase>((ref) {
  return StartRouteUseCase(ref.watch(routeRepositoryProvider));
});

final completeStopUseCaseProvider = Provider<CompleteStopUseCase>((ref) {
  return CompleteStopUseCase(ref.watch(routeRepositoryProvider));
});

final routesProvider = FutureProvider.autoDispose.family<List<RouteEntity>, DateTime?>((ref, date) {
  return ref.watch(getRoutesUseCaseProvider).call(date: date);
});

final routeDetailProvider = FutureProvider.autoDispose.family<RouteEntity, String>((ref, id) {
  return ref.watch(getRouteDetailUseCaseProvider).call(id);
});

final activeRouteProvider = FutureProvider.autoDispose<RouteEntity?>((ref) async {
  final routes = await ref.watch(getRoutesUseCaseProvider).call(date: DateTime.now());
  return routes.cast<RouteEntity?>().firstWhere(
        (r) => r!.status == 'IN_PROGRESS',
        orElse: () => null,
      );
});

class RouteNotifier extends StateNotifier<AsyncValue<RouteEntity?>> {
  final StartRouteUseCase _startRoute;
  final CompleteStopUseCase _completeStop;

  RouteNotifier(this._startRoute, this._completeStop)
      : super(const AsyncValue.data(null));

  Future<void> startRoute(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _startRoute(id));
  }

  Future<void> completeStop(String routeId, String stopId) async {
    state = await AsyncValue.guard(() => _completeStop(routeId, stopId));
  }
}

final routeNotifierProvider =
    StateNotifierProvider.family<RouteNotifier, AsyncValue<RouteEntity?>, String>((ref, routeId) {
  return RouteNotifier(
    ref.watch(startRouteUseCaseProvider),
    ref.watch(completeStopUseCaseProvider),
  );
});
