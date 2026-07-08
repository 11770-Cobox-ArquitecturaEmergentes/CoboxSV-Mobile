import 'dart:convert';

enum EvidenceStatus {
  captured,
  intentCreated,
  uploaded,
  confirmed,
  synced,
  failed;

  static EvidenceStatus fromValue(String? value) {
    return EvidenceStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => EvidenceStatus.captured,
    );
  }
}

class EvidenceDraft {
  const EvidenceDraft({
    required this.clientEvidenceId,
    required this.filePath,
    required this.driverId,
    required this.orderId,
    required this.routeId,
    required this.type,
    required this.mimeType,
    required this.sizeBytes,
    required this.sha256,
    required this.capturedAt,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.speedKmh,
    this.objectKey,
    this.uploadIntentId,
    this.confirmedAt,
    this.syncEventType,
    this.syncAggregateType,
    this.syncAggregateId,
    this.syncPayload = const {},
    this.status = EvidenceStatus.captured,
    this.lastError,
  });

  final String clientEvidenceId;
  final String filePath;
  final int driverId;
  final int orderId;
  final int routeId;
  final String type;
  final String mimeType;
  final int sizeBytes;
  final String sha256;
  final DateTime capturedAt;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final double? speedKmh;
  final String? objectKey;
  final String? uploadIntentId;
  final DateTime? confirmedAt;
  final String? syncEventType;
  final String? syncAggregateType;
  final String? syncAggregateId;
  final Map<String, dynamic> syncPayload;
  final EvidenceStatus status;
  final String? lastError;

  bool get isComplete =>
      status == EvidenceStatus.synced || status == EvidenceStatus.confirmed;

  EvidenceDraft copyWith({
    String? objectKey,
    String? uploadIntentId,
    DateTime? confirmedAt,
    String? syncEventType,
    String? syncAggregateType,
    String? syncAggregateId,
    Map<String, dynamic>? syncPayload,
    EvidenceStatus? status,
    String? lastError,
  }) {
    return EvidenceDraft(
      clientEvidenceId: clientEvidenceId,
      filePath: filePath,
      driverId: driverId,
      orderId: orderId,
      routeId: routeId,
      type: type,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      sha256: sha256,
      capturedAt: capturedAt,
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
      speedKmh: speedKmh,
      objectKey: objectKey ?? this.objectKey,
      uploadIntentId: uploadIntentId ?? this.uploadIntentId,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      syncEventType: syncEventType ?? this.syncEventType,
      syncAggregateType: syncAggregateType ?? this.syncAggregateType,
      syncAggregateId: syncAggregateId ?? this.syncAggregateId,
      syncPayload: syncPayload ?? this.syncPayload,
      status: status ?? this.status,
      lastError: lastError,
    );
  }

  Map<String, dynamic> toJson() => {
        'clientEvidenceId': clientEvidenceId,
        'filePath': filePath,
        'driverId': driverId,
        'orderId': orderId,
        'routeId': routeId,
        'type': type,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
        'sha256': sha256,
        'capturedAt': capturedAt.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'accuracyMeters': accuracyMeters,
        'speedKmh': speedKmh,
        'objectKey': objectKey,
        'uploadIntentId': uploadIntentId,
        'confirmedAt': confirmedAt?.toIso8601String(),
        'syncEventType': syncEventType,
        'syncAggregateType': syncAggregateType,
        'syncAggregateId': syncAggregateId,
        'syncPayload': syncPayload,
        'status': status.name,
        'lastError': lastError,
      };

  factory EvidenceDraft.fromJson(Map<String, dynamic> json) {
    return EvidenceDraft(
      clientEvidenceId: json['clientEvidenceId'].toString(),
      filePath: json['filePath'].toString(),
      driverId: _intValue(json['driverId']),
      orderId: _intValue(json['orderId']),
      routeId: _intValue(json['routeId']),
      type: json['type'].toString(),
      mimeType: json['mimeType'].toString(),
      sizeBytes: _intValue(json['sizeBytes']),
      sha256: json['sha256'].toString(),
      capturedAt: DateTime.tryParse(json['capturedAt'].toString()) ?? DateTime.now(),
      latitude: _doubleValue(json['latitude']),
      longitude: _doubleValue(json['longitude']),
      accuracyMeters: _doubleValue(json['accuracyMeters']),
      speedKmh: _doubleValue(json['speedKmh']),
      objectKey: json['objectKey']?.toString(),
      uploadIntentId: json['uploadIntentId']?.toString(),
      confirmedAt: json['confirmedAt'] == null
          ? null
          : DateTime.tryParse(json['confirmedAt'].toString()),
      syncEventType: json['syncEventType']?.toString(),
      syncAggregateType: json['syncAggregateType']?.toString(),
      syncAggregateId: json['syncAggregateId']?.toString(),
      syncPayload: json['syncPayload'] is Map
          ? Map<String, dynamic>.from(json['syncPayload'] as Map)
          : const {},
      status: EvidenceStatus.fromValue(json['status']?.toString()),
      lastError: json['lastError']?.toString(),
    );
  }
}

class UploadIntent {
  const UploadIntent({
    required this.uploadIntentId,
    required this.clientEvidenceId,
    required this.objectKey,
    required this.httpMethod,
    required this.requiredHeaders,
    required this.expiresAt,
    required this.status,
    this.uploadUrl,
  });

  final String uploadIntentId;
  final String clientEvidenceId;
  final String objectKey;
  final String? uploadUrl;
  final String httpMethod;
  final Map<String, String> requiredHeaders;
  final DateTime expiresAt;
  final String status;

  factory UploadIntent.fromJson(Map<String, dynamic> json) {
    final headers = <String, String>{};
    final rawHeaders = json['requiredHeaders'];
    if (rawHeaders is Map) {
      rawHeaders.forEach((key, value) {
        headers[key.toString()] = value.toString();
      });
    }
    return UploadIntent(
      uploadIntentId: json['uploadIntentId'].toString(),
      clientEvidenceId: json['clientEvidenceId'].toString(),
      objectKey: json['objectKey'].toString(),
      uploadUrl: json['uploadUrl']?.toString(),
      httpMethod: (json['httpMethod'] ?? 'PUT').toString(),
      requiredHeaders: headers,
      expiresAt: DateTime.tryParse(json['expiresAt'].toString()) ?? DateTime.now(),
      status: json['status'].toString(),
    );
  }
}

class UploadConfirmation {
  const UploadConfirmation({
    required this.uploadIntentId,
    required this.clientEvidenceId,
    required this.objectKey,
    required this.status,
    this.confirmedAt,
  });

  final String uploadIntentId;
  final String clientEvidenceId;
  final String objectKey;
  final String status;
  final DateTime? confirmedAt;

  factory UploadConfirmation.fromJson(Map<String, dynamic> json) {
    return UploadConfirmation(
      uploadIntentId: json['uploadIntentId'].toString(),
      clientEvidenceId: json['clientEvidenceId'].toString(),
      objectKey: json['objectKey'].toString(),
      status: json['status'].toString(),
      confirmedAt: json['confirmedAt'] == null
          ? null
          : DateTime.tryParse(json['confirmedAt'].toString()),
    );
  }
}

class EdgeSyncResult {
  const EdgeSyncResult({
    required this.clientId,
    required this.status,
    this.serverId,
    this.message,
  });

  final String clientId;
  final int? serverId;
  final String status;
  final String? message;

  bool get accepted => status == 'RECORDED' || status == 'DUPLICATE';

  factory EdgeSyncResult.fromJson(Map<String, dynamic> json) {
    return EdgeSyncResult(
      clientId: json['clientId'].toString(),
      serverId: json['serverId'] is num ? (json['serverId'] as num).toInt() : null,
      status: json['status'].toString(),
      message: json['message']?.toString(),
    );
  }
}

class EdgeSyncBatchResponse {
  const EdgeSyncBatchResponse({
    required this.clientBatchId,
    required this.status,
    required this.results,
    this.batchId,
  });

  final int? batchId;
  final String clientBatchId;
  final String status;
  final List<EdgeSyncResult> results;

  bool get accepted =>
      status == 'ACCEPTED' ||
      status == 'PARTIALLY_ACCEPTED' ||
      status == 'DUPLICATE';

  factory EdgeSyncBatchResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    return EdgeSyncBatchResponse(
      batchId: json['batchId'] is num ? (json['batchId'] as num).toInt() : null,
      clientBatchId: json['clientBatchId'].toString(),
      status: json['status'].toString(),
      results: rawResults is List
          ? rawResults
              .whereType<Map<String, dynamic>>()
              .map(EdgeSyncResult.fromJson)
              .toList()
          : const [],
    );
  }
}

class PendingEvidenceQueue {
  const PendingEvidenceQueue({
    required this.version,
    required this.items,
  });

  final int version;
  final List<EvidenceDraft> items;

  String encode() => jsonEncode({
        'version': version,
        'items': items.map((item) => item.toJson()).toList(),
      });

  factory PendingEvidenceQueue.decode(String? value) {
    if (value == null || value.isEmpty) {
      return const PendingEvidenceQueue(version: 1, items: []);
    }
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic>) {
      return const PendingEvidenceQueue(version: 1, items: []);
    }
    final rawItems = decoded['items'];
    return PendingEvidenceQueue(
      version: decoded['version'] is num ? (decoded['version'] as num).toInt() : 1,
      items: rawItems is List
          ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(EvidenceDraft.fromJson)
              .toList()
          : const [],
    );
  }
}

int _intValue(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double? _doubleValue(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}
