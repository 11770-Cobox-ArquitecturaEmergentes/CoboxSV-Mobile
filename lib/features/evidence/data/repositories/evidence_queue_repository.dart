import 'package:cobox_sv_mobile/core/storage/local_storage.dart';
import 'package:cobox_sv_mobile/features/evidence/data/models/evidence_models.dart';

class EvidenceQueueRepository {
  EvidenceQueueRepository(this._storage);

  final LocalStorage _storage;

  static const _queueKey = 'evidence_pending_queue_v1';

  List<EvidenceDraft> getPending() {
    return PendingEvidenceQueue.decode(_storage.getString(_queueKey)).items;
  }

  Future<void> upsert(EvidenceDraft draft) async {
    final items = getPending();
    final index = items.indexWhere(
      (item) => item.clientEvidenceId == draft.clientEvidenceId,
    );
    if (index >= 0) {
      items[index] = draft;
    } else {
      items.add(draft);
    }
    await _save(items);
  }

  Future<void> remove(String clientEvidenceId) async {
    final items = getPending()
        .where((item) => item.clientEvidenceId != clientEvidenceId)
        .toList();
    await _save(items);
  }

  Future<void> _save(List<EvidenceDraft> items) async {
    await _storage.saveString(
      _queueKey,
      PendingEvidenceQueue(version: 1, items: items).encode(),
    );
  }
}
