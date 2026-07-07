import 'dart:convert';

import 'package:cobox_sv_mobile/core/storage/local_storage.dart';
import 'package:cobox_sv_mobile/features/evidence/data/models/evidence_models.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/entities/incident_entity.dart';
import 'package:cobox_sv_mobile/shared/enums/incident_type.dart';

class PendingIncidentReport {
  const PendingIncidentReport({
    required this.localId,
    required this.incident,
    required this.evidences,
    required this.queuedAt,
    this.lastError,
  });

  final String localId;
  final IncidentEntity incident;
  final List<EvidenceDraft> evidences;
  final DateTime queuedAt;
  final String? lastError;

  PendingIncidentReport copyWith({
    IncidentEntity? incident,
    List<EvidenceDraft>? evidences,
    String? lastError,
  }) {
    return PendingIncidentReport(
      localId: localId,
      incident: incident ?? this.incident,
      evidences: evidences ?? this.evidences,
      queuedAt: queuedAt,
      lastError: lastError,
    );
  }

  Map<String, dynamic> toJson() => {
        'localId': localId,
        'incident': {
          'id': incident.id,
          'type': incident.type.value,
          'title': incident.title,
          'description': incident.description,
          'status': incident.status.name,
          'severity': incident.severity.name,
          'dateTime': incident.dateTime.toIso8601String(),
          'orderId': incident.orderId,
          'routeId': incident.routeId,
          'reportedBy': incident.reportedBy,
        },
        'evidences': evidences.map((item) => item.toJson()).toList(),
        'queuedAt': queuedAt.toIso8601String(),
        'lastError': lastError,
      };

  factory PendingIncidentReport.fromJson(Map<String, dynamic> json) {
    final rawIncident = json['incident'];
    final incidentMap = rawIncident is Map
        ? Map<String, dynamic>.from(rawIncident)
        : <String, dynamic>{};
    final rawEvidences = json['evidences'];

    return PendingIncidentReport(
      localId: (json['localId'] ?? '').toString(),
      incident: IncidentEntity(
        id: (incidentMap['id'] ?? json['localId'] ?? '').toString(),
        type: IncidentType.fromValue((incidentMap['type'] ?? 'other').toString()),
        title: (incidentMap['title'] ?? 'Incidencia pendiente').toString(),
        description: (incidentMap['description'] ?? '').toString(),
        status: IncidentStatus.fromValue(
          (incidentMap['status'] ?? IncidentStatus.open.name).toString(),
        ),
        severity: IncidentSeverity.fromValue(
          (incidentMap['severity'] ?? IncidentSeverity.medium.name).toString(),
        ),
        dateTime: DateTime.tryParse((incidentMap['dateTime'] ?? '').toString()) ??
            DateTime.now(),
        orderId: incidentMap['orderId']?.toString(),
        routeId: incidentMap['routeId']?.toString(),
        reportedBy: incidentMap['reportedBy']?.toString(),
      ),
      evidences: rawEvidences is List
          ? rawEvidences
              .whereType<Map>()
              .map((item) => EvidenceDraft.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : const [],
      queuedAt: DateTime.tryParse((json['queuedAt'] ?? '').toString()) ??
          DateTime.now(),
      lastError: json['lastError']?.toString(),
    );
  }
}

class PendingIncidentQueueRepository {
  PendingIncidentQueueRepository(this._storage);

  final LocalStorage _storage;

  static const _queueKey = 'incident_pending_queue_v1';

  List<PendingIncidentReport> getPending() {
    final value = _storage.getString(_queueKey);
    if (value == null || value.isEmpty) return [];
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic>) return [];
    final rawItems = decoded['items'];
    if (rawItems is! List) return [];
    return rawItems
        .whereType<Map>()
        .map((item) => PendingIncidentReport.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> upsert(PendingIncidentReport report) async {
    final items = getPending();
    final index = items.indexWhere((item) => item.localId == report.localId);
    if (index >= 0) {
      items[index] = report;
    } else {
      items.insert(0, report);
    }
    await _save(items);
  }

  Future<void> remove(String localId) async {
    final items = getPending().where((item) => item.localId != localId).toList();
    await _save(items);
  }

  Future<void> _save(List<PendingIncidentReport> items) async {
    await _storage.saveString(
      _queueKey,
      jsonEncode({
        'version': 1,
        'items': items.map((item) => item.toJson()).toList(),
      }),
    );
  }
}
