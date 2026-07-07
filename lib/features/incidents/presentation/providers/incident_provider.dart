import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cobox_sv_mobile/core/network/network_info.dart';
import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/core/errors/error_handler.dart';
import 'package:cobox_sv_mobile/app/providers.dart';
import 'package:cobox_sv_mobile/features/evidence/data/models/evidence_models.dart';
import 'package:cobox_sv_mobile/features/evidence/data/services/evidence_workflow_service.dart';
import 'package:cobox_sv_mobile/features/evidence/presentation/providers/evidence_provider.dart';
import 'package:cobox_sv_mobile/features/authentication/presentation/providers/auth_provider.dart';
import 'package:cobox_sv_mobile/features/incidents/data/datasource/incident_remote_datasource.dart';
import 'package:cobox_sv_mobile/features/incidents/data/repositories/pending_incident_queue_repository.dart';
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

final pendingIncidentQueueRepositoryProvider =
    Provider<PendingIncidentQueueRepository>((ref) {
  return PendingIncidentQueueRepository(ref.watch(localStorageProvider));
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
  final PendingIncidentQueueRepository _pendingQueue;
  final EvidenceWorkflowService _evidenceWorkflowService;
  final NetworkInfo _networkInfo;

  IncidentsNotifier({
    required GetIncidentsUseCase getIncidentsUseCase,
    required CreateIncidentUseCase createIncidentUseCase,
    required GetIncidentDetailUseCase getIncidentDetailUseCase,
    required PendingIncidentQueueRepository pendingQueue,
    required EvidenceWorkflowService evidenceWorkflowService,
    required NetworkInfo networkInfo,
  })  : _getIncidentsUseCase = getIncidentsUseCase,
        _createIncidentUseCase = createIncidentUseCase,
        _getIncidentDetailUseCase = getIncidentDetailUseCase,
        _pendingQueue = pendingQueue,
        _evidenceWorkflowService = evidenceWorkflowService,
        _networkInfo = networkInfo,
        super(const IncidentsState());

  static const _pageSize = 20;

  Future<void> loadIncidents() async {
    state = state.copyWith(isLoading: true, error: null, page: 1);
    try {
      await retryPendingReports();
      final result = await _getIncidentsUseCase(
        page: 1,
        limit: _pageSize,
        type: state.typeFilter,
        status: state.statusFilter,
        search: state.search.isNotEmpty ? state.search : null,
      );
      final pending = _pendingQueue.getPending().map(_pendingToIncident).toList();
      state = state.copyWith(
        incidents: [...pending, ...result.incidents],
        total: result.total + pending.length,
        isLoading: false,
        hasMore: result.incidents.length < result.total,
      );
    } on Failure catch (e) {
      final pending = _pendingQueue.getPending().map(_pendingToIncident).toList();
      state = state.copyWith(
        incidents: pending,
        total: pending.length,
        isLoading: false,
        error: pending.isEmpty ? getErrorMessage(e) : null,
      );
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

  Future<void> queuePendingReport({
    required IncidentEntity incident,
    required List<EvidenceDraft> evidences,
    String? lastError,
  }) async {
    final localId = 'local-${DateTime.now().microsecondsSinceEpoch}';
    final report = PendingIncidentReport(
      localId: localId,
      incident: IncidentEntity(
        id: localId,
        type: incident.type,
        title: incident.title,
        description: incident.description,
        status: incident.status,
        severity: incident.severity,
        dateTime: incident.dateTime,
        location: incident.location,
        orderId: incident.orderId,
        routeId: incident.routeId,
        evidenceUrls: incident.evidenceUrls,
        reportedBy: incident.reportedBy,
        resolvedAt: incident.resolvedAt,
        resolution: incident.resolution,
      ),
      evidences: evidences,
      queuedAt: DateTime.now(),
      lastError: lastError,
    );
    await _pendingQueue.upsert(report);

    state = state.copyWith(
      incidents: [_pendingToIncident(report), ...state.incidents],
      total: state.total + 1,
      error: null,
    );
  }

  Future<void> retryPendingReports() async {
    final pending = _pendingQueue.getPending();
    if (pending.isEmpty || !(await _networkInfo.checkConnectivity())) return;

    for (final report in pending) {
      try {
        final created = await _createIncidentUseCase(report.incident);
        for (final evidence in report.evidences) {
          try {
            await _evidenceWorkflowService.uploadAndSync(
              draft: evidence,
              eventType: 'INCIDENT_EVIDENCE',
              aggregateType: 'INCIDENT',
              aggregateId: created.id,
              payload: {
                'incidentId': created.id,
                'type': report.incident.type.value,
                'description': report.incident.description,
              },
            );
          } catch (_) {
            // The evidence workflow keeps failed evidence in its own retry queue.
          }
        }
        await _pendingQueue.remove(report.localId);
      } catch (error) {
        await _pendingQueue.upsert(report.copyWith(lastError: error.toString()));
      }
    }
  }

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
    if (id.startsWith('local-')) {
      final pending = _pendingQueue.getPending().where((item) => item.localId == id);
      if (pending.isNotEmpty) return _pendingToIncident(pending.first);
    }
    try {
      return await _getIncidentDetailUseCase(id);
    } on Failure catch (e) {
      state = state.copyWith(error: getErrorMessage(e));
      return null;
    }
  }

  IncidentEntity _pendingToIncident(PendingIncidentReport report) {
    final incident = report.incident;
    return IncidentEntity(
      id: report.localId,
      type: incident.type,
      title: incident.title,
      description: incident.description,
      status: IncidentStatus.inProgress,
      severity: incident.severity,
      dateTime: incident.dateTime,
      location: incident.location,
      orderId: incident.orderId,
      routeId: incident.routeId,
      evidenceUrls: incident.evidenceUrls,
      reportedBy: incident.reportedBy,
      resolvedAt: incident.resolvedAt,
      resolution: 'Pendiente de sincronizacion',
    );
  }
}

final incidentsProvider = StateNotifierProvider<IncidentsNotifier, IncidentsState>((ref) {
  return IncidentsNotifier(
    getIncidentsUseCase: ref.watch(getIncidentsUseCaseProvider),
    createIncidentUseCase: ref.watch(createIncidentUseCaseProvider),
    getIncidentDetailUseCase: ref.watch(getIncidentDetailUseCaseProvider),
    pendingQueue: ref.watch(pendingIncidentQueueRepositoryProvider),
    evidenceWorkflowService: ref.watch(evidenceWorkflowServiceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});
