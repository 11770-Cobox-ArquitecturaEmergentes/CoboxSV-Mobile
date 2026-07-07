import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cobox_sv_mobile/app/providers.dart';
import 'package:cobox_sv_mobile/features/evidence/data/models/evidence_models.dart';
import 'package:cobox_sv_mobile/features/evidence/data/repositories/evidence_queue_repository.dart';
import 'package:cobox_sv_mobile/features/evidence/data/services/edge_sync_service.dart';
import 'package:cobox_sv_mobile/features/evidence/data/services/evidence_capture_service.dart';
import 'package:cobox_sv_mobile/features/evidence/data/services/evidence_upload_service.dart';
import 'package:cobox_sv_mobile/features/evidence/data/services/evidence_workflow_service.dart';

final evidenceCaptureServiceProvider = Provider<EvidenceCaptureService>((ref) {
  return EvidenceCaptureService();
});

final evidenceQueueRepositoryProvider = Provider<EvidenceQueueRepository>((ref) {
  return EvidenceQueueRepository(ref.watch(localStorageProvider));
});

final evidenceUploadServiceProvider = Provider<EvidenceUploadService>((ref) {
  return EvidenceUploadService(ref.watch(dioClientProvider));
});

final edgeSyncServiceProvider = Provider<EdgeSyncService>((ref) {
  return EdgeSyncService(ref.watch(dioClientProvider));
});

final evidenceWorkflowServiceProvider = Provider<EvidenceWorkflowService>((ref) {
  return EvidenceWorkflowService(
    uploadService: ref.watch(evidenceUploadServiceProvider),
    edgeSyncService: ref.watch(edgeSyncServiceProvider),
    queueRepository: ref.watch(evidenceQueueRepositoryProvider),
  );
});

class EvidenceSyncState {
  const EvidenceSyncState({
    this.pending = const [],
    this.isSyncing = false,
    this.error,
  });

  final List<EvidenceDraft> pending;
  final bool isSyncing;
  final String? error;

  EvidenceSyncState copyWith({
    List<EvidenceDraft>? pending,
    bool? isSyncing,
    String? error,
  }) {
    return EvidenceSyncState(
      pending: pending ?? this.pending,
      isSyncing: isSyncing ?? this.isSyncing,
      error: error,
    );
  }
}

class EvidenceSyncNotifier extends StateNotifier<EvidenceSyncState> {
  EvidenceSyncNotifier(this._workflow)
      : super(EvidenceSyncState(pending: _workflow.getPending()));

  final EvidenceWorkflowService _workflow;

  void refreshPending() {
    state = state.copyWith(pending: _workflow.getPending(), error: null);
  }

  Future<void> queue(EvidenceDraft draft) async {
    await _workflow.queue(draft);
    refreshPending();
  }

  Future<void> retryPending() async {
    if (state.isSyncing) return;
    state = state.copyWith(isSyncing: true, error: null);
    try {
      await _workflow.retryPending();
      state = EvidenceSyncState(pending: _workflow.getPending());
    } catch (error) {
      state = state.copyWith(
        isSyncing: false,
        pending: _workflow.getPending(),
        error: error.toString(),
      );
    }
  }
}

final evidenceSyncProvider =
    StateNotifierProvider<EvidenceSyncNotifier, EvidenceSyncState>((ref) {
  return EvidenceSyncNotifier(ref.watch(evidenceWorkflowServiceProvider));
});
