import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cobox_sv_mobile/app/providers.dart';
import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/features/home/data/datasource/home_local_datasource.dart';
import 'package:cobox_sv_mobile/features/home/data/datasource/home_remote_datasource.dart';
import 'package:cobox_sv_mobile/features/home/data/repository/home_repository_impl.dart';
import 'package:cobox_sv_mobile/features/home/data/repository/mock_home_repository_impl.dart';
import 'package:cobox_sv_mobile/features/home/domain/entities/activity.dart';
import 'package:cobox_sv_mobile/features/home/domain/entities/dashboard.dart';
import 'package:cobox_sv_mobile/features/home/domain/repository/home_repository.dart';
import 'package:cobox_sv_mobile/features/home/domain/usecases/get_dashboard.dart';
import 'package:cobox_sv_mobile/features/home/domain/usecases/get_recent_activity.dart';
import 'package:cobox_sv_mobile/features/authentication/presentation/providers/auth_provider.dart';

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  return HomeRemoteDataSource(ref.watch(dioClientProvider));
});

final homeLocalDataSourceProvider = Provider<HomeLocalDataSource>((ref) {
  return HomeLocalDataSource(ref.watch(localStorageProvider));
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  if (ref.watch(useMockApiProvider)) {
    return const MockHomeRepositoryImpl();
  }
  return HomeRepositoryImpl(
    remoteDataSource: ref.watch(homeRemoteDataSourceProvider),
    localDataSource: ref.watch(homeLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final getDashboardProvider = Provider<GetDashboard>((ref) {
  return GetDashboard(ref.watch(homeRepositoryProvider));
});

final getRecentActivityProvider = Provider<GetRecentActivity>((ref) {
  return GetRecentActivity(ref.watch(homeRepositoryProvider));
});

final dashboardProvider = FutureProvider<Dashboard>((ref) async {
  final getDashboard = ref.watch(getDashboardProvider);
  final result = await getDashboard();
  return result.fold(
    (failure) => throw failure,
    (dashboard) => dashboard,
  );
});

final recentActivityProvider = FutureProvider<List<Activity>>((ref) async {
  final getRecentActivity = ref.watch(getRecentActivityProvider);
  final result = await getRecentActivity(limit: 10);
  return result.fold(
    (failure) => throw failure,
    (activity) => activity,
  );
});

enum HomeStatus { loading, loaded, error, refreshing }

class HomeState {
  final HomeStatus status;
  final Dashboard? dashboard;
  final List<Activity> recentActivity;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.loading,
    this.dashboard,
    this.recentActivity = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    Dashboard? dashboard,
    List<Activity>? recentActivity,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      dashboard: dashboard ?? this.dashboard,
      recentActivity: recentActivity ?? this.recentActivity,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class HomeController extends StateNotifier<HomeState> {
  final GetDashboard _getDashboard;
  final GetRecentActivity _getRecentActivity;

  HomeController({
    required GetDashboard getDashboard,
    required GetRecentActivity getRecentActivity,
  })  : _getDashboard = getDashboard,
        _getRecentActivity = getRecentActivity,
        super(const HomeState());

  Future<void> loadData() async {
    state = const HomeState(status: HomeStatus.loading);
    await _fetchData();
  }

  Future<void> refresh() async {
    state = state.copyWith(status: HomeStatus.refreshing);
    await _fetchData();
  }

  Future<void> _fetchData() async {
    final results = await Future.wait([
      _getDashboard(),
      _getRecentActivity(limit: 5),
    ]);

    final dashboardResult = results[0] as Either<Failure, Dashboard>;
    final activityResult = results[1] as Either<Failure, List<Activity>>;

    dashboardResult.fold(
      (failure) {
        state = state.copyWith(
          status: HomeStatus.error,
          errorMessage: failure.message,
        );
      },
      (dashboard) {
        final activities = activityResult.fold(
          (_) => <Activity>[],
          (list) => list,
        );
        state = state.copyWith(
          status: HomeStatus.loaded,
          dashboard: dashboard,
          recentActivity: activities,
          errorMessage: null,
        );
      },
    );
  }
}

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController(
    getDashboard: ref.watch(getDashboardProvider),
    getRecentActivity: ref.watch(getRecentActivityProvider),
  );
});
