import 'package:cobox_sv_mobile/features/evidence/data/models/evidence_models.dart';
import 'package:cobox_sv_mobile/features/evidence/data/repositories/evidence_queue_repository.dart';
import 'package:cobox_sv_mobile/features/evidence/data/services/edge_sync_service.dart';
import 'package:cobox_sv_mobile/features/evidence/data/services/evidence_upload_service.dart';

class EvidenceWorkflowService {
  EvidenceWorkflowService({
    required EvidenceUploadService uploadService,
    required EdgeSyncService edgeSyncService,
    required EvidenceQueueRepository queueRepository,
  })  : _uploadService = uploadService,
        _edgeSyncService = edgeSyncService,
        _queueRepository = queueRepository;

  final EvidenceUploadService _uploadService;
  final EdgeSyncService _edgeSyncService;
  final EvidenceQueueRepository _queueRepository;

  List<EvidenceDraft> getPending() => _queueRepository.getPending();

  Future<void> queue(EvidenceDraft draft) => _queueRepository.upsert(draft);

  Future<EvidenceDraft> uploadAndSync({
    required EvidenceDraft draft,
    required String eventType,
    required String aggregateType,
    required String aggregateId,
    Map<String, dynamic> payload = const {},
  }) async {
    EvidenceDraft current = draft.copyWith(
      syncEventType: eventType,
      syncAggregateType: aggregateType,
      syncAggregateId: aggregateId,
      syncPayload: payload,
      lastError: null,
    );
    try {
      final intent = await _uploadService.createIntent(current);
      current = current.copyWith(
        uploadIntentId: intent.uploadIntentId,
        objectKey: intent.objectKey,
        status: EvidenceStatus.intentCreated,
        lastError: null,
      );
      await _queueRepository.upsert(current);

      await _uploadService.uploadObject(current, intent);
      current = current.copyWith(status: EvidenceStatus.uploaded);
      await _queueRepository.upsert(current);

      final confirmation = await _uploadService.confirmIntent(intent);
      current = current.copyWith(
        objectKey: confirmation.objectKey,
        confirmedAt: confirmation.confirmedAt,
        status: EvidenceStatus.confirmed,
      );
      await _queueRepository.upsert(current);

      final sync = await _edgeSyncService.syncEvidence(
        draft: current,
        eventType: eventType,
        aggregateType: aggregateType,
        aggregateId: aggregateId,
        payload: payload,
      );

      final accepted = sync.accepted &&
          sync.results.any(
            (result) =>
                result.clientId == current.clientEvidenceId && result.accepted,
          );
      if (!accepted) {
        throw Exception(sync.results.isEmpty
            ? 'La sincronizacion edge fue rechazada'
            : sync.results.first.message ?? 'La evidencia fue rechazada');
      }

      current = current.copyWith(status: EvidenceStatus.synced, lastError: null);
      await _queueRepository.remove(current.clientEvidenceId);
      return current;
    } catch (error) {
      current = current.copyWith(
        status: EvidenceStatus.failed,
        lastError: error.toString(),
      );
      await _queueRepository.upsert(current);
      rethrow;
    }
  }

  Future<List<EvidenceDraft>> retryPending() async {
    final completed = <EvidenceDraft>[];
    for (final draft in getPending()) {
      final eventType = draft.syncEventType;
      final aggregateType = draft.syncAggregateType;
      final aggregateId = draft.syncAggregateId;
      if (eventType == null || aggregateType == null || aggregateId == null) {
        continue;
      }
      try {
        completed.add(await uploadAndSync(
          draft: draft,
          eventType: eventType,
          aggregateType: aggregateType,
          aggregateId: aggregateId,
          payload: draft.syncPayload,
        ));
      } catch (_) {
        // Keep the failed item in queue and continue with the next one.
      }
    }
    return completed;
  }
}
