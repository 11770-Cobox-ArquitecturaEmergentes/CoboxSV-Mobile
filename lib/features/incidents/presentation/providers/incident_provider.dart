import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/core/errors/error_handler.dart';
import 'package:cobox_sv_mobile/app/providers.dart';
import 'package:cobox_sv_mobile/features/authentication/presentation/providers/auth_provider.dart';
import 'package:cobox_sv_mobile/features/incidents/data/datasource/incident_remote_datasource.dart';
import 'package:cobox_sv_mobile/features/incidents/data/repository/incident_repository_impl.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/entities/incident_entity.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/repository/incident_repository.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/usecases/create_incident_usecase.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/usecases/get_incident_detail_usecase.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/usecases/get_incidents_usecase.dart';
import 'package:cobox_sv_mobile/shared/enums/incident_type.dart';

final incidentRemoteDataSourceProvider = Provider<IncidentRemoteDataSource>((ref) {
  return IncidentRemoteDataSource(
    ref.watch(dioClientProvider),
    ref.watch(authLocalDataSourceProvider),
  );
});

final incidentRepositoryProvider = Provider<IncidentRepository>((ref) {
  return IncidentRepositoryImpl(ref.watch(incidentRemoteDataSourceProvider));
});

final getIncidentsUseCaseProvider = Provider<GetIncidentsUseCase>((ref) {
  return GetIncidentsUseCase(ref.watch(incidentRepositoryProvider));
});

final createIncidentUseCaseProvider = Provider<CreateIncidentUseCase>((ref) {
  return CreateIncidentUseCase(ref.watch(incidentRepositoryProvider));
});

final getIncidentDetailUseCaseProvider = Provider<GetIncidentDetailUseCase>((ref) {
  return GetIncidentDetailUseCase(ref.watch(incidentRepositoryProvider));
});

class IncidentsState {
  final List<IncidentEntity> incidents;
  final int total;
  final int page;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final IncidentType? typeFilter;
  final IncidentStatus? statusFilter;
  final String search;
  final bool hasMore;

  const IncidentsState({
    this.incidents = const [],
    this.total = 0,
    this.page = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.typeFilter,
    this.statusFilter,
    this.search = '',
    this.hasMore = false,
  });

  IncidentsState copyWith({
    List<IncidentEntity>? incidents,
    int? total,
    int? page,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    IncidentType? typeFilter,
    IncidentStatus? statusFilter,
    String? search,
    bool? hasMore,
  }) {
    return IncidentsState(
      incidents: incidents ?? this.incidents,
      total: total ?? this.total,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      typeFilter: typeFilter,
      statusFilter: statusFilter,
      search: search ?? this.search,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class IncidentsNotifier extends StateNotifier<IncidentsState> {
  final GetIncidentsUseCase _getIncidentsUseCase;
  final CreateIncidentUseCase _createIncidentUseCase;
  final GetIncidentDetailUseCase _getIncidentDetailUseCase;

  IncidentsNotifier({
    required GetIncidentsUseCase getIncidentsUseCase,
    required CreateIncidentUseCase createIncidentUseCase,
    required GetIncidentDetailUseCase getIncidentDetailUseCase,
  })  : _getIncidentsUseCase = getIncidentsUseCase,
        _createIncidentUseCase = createIncidentUseCase,
        _getIncidentDetailUseCase = getIncidentDetailUseCase,
        super(const IncidentsState());

  static const _pageSize = 20;

  Future<void> loadIncidents() async {
    state = state.copyWith(isLoading: true, error: null, page: 1);
    try {
      final result = await _getIncidentsUseCase(
        page: 1,
        limit: _pageSize,
        type: state.typeFilter,
        status: state.statusFilter,
        search: state.search.isNotEmpty ? state.search : null,
      );
      state = state.copyWith(
        incidents: result.incidents,
        total: result.total,
        isLoading: false,
        hasMore: result.incidents.length < result.total,
      );
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, error: getErrorMessage(e));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.page + 1;
    try {
      final result = await _getIncidentsUseCase(
        page: nextPage,
        limit: _pageSize,
        type: state.typeFilter,
        status: state.statusFilter,
        search: state.search.isNotEmpty ? state.search : null,
      );
      state = state.copyWith(
        incidents: [...state.incidents, ...result.incidents],
        total: result.total,
        page: nextPage,
        isLoadingMore: false,
        hasMore: state.incidents.length + result.incidents.length < result.total,
      );
    } on Failure catch (e) {
      state = state.copyWith(isLoadingMore: false, error: getErrorMessage(e));
    }
  }

  void setTypeFilter(IncidentType? type) {
    state = state.copyWith(typeFilter: type, page: 1);
    loadIncidents();
  }

  void setStatusFilter(IncidentStatus? status) {
    state = state.copyWith(statusFilter: status, page: 1);
    loadIncidents();
  }

  void setSearch(String search) {
    state = state.copyWith(search: search, page: 1);
    loadIncidents();
  }

  Future<void> refresh() => loadIncidents();

  Future<IncidentEntity?> createIncident(IncidentEntity incident) async {
    try {
      final result = await _createIncidentUseCase(incident);
      state = state.copyWith(
        incidents: [result, ...state.incidents],
        total: state.total + 1,
      );
      return result;
    } on Failure catch (e) {
      state = state.copyWith(error: getErrorMessage(e));
      return null;
    }
  }

  Future<IncidentEntity?> getIncidentDetail(String id) async {
    try {
      return await _getIncidentDetailUseCase(id);
    } on Failure catch (e) {
      state = state.copyWith(error: getErrorMessage(e));
      return null;
    }
  }
}

final incidentsProvider = StateNotifierProvider<IncidentsNotifier, IncidentsState>((ref) {
  return IncidentsNotifier(
    getIncidentsUseCase: ref.watch(getIncidentsUseCaseProvider),
    createIncidentUseCase: ref.watch(createIncidentUseCaseProvider),
    getIncidentDetailUseCase: ref.watch(getIncidentDetailUseCaseProvider),
  );
});
