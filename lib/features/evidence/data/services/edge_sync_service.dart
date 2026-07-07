import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

import 'package:cobox_sv_mobile/core/api/dio_client.dart';
import 'package:cobox_sv_mobile/core/api/endpoints.dart';
import 'package:cobox_sv_mobile/features/evidence/data/models/evidence_models.dart';
import 'package:cobox_sv_mobile/features/evidence/data/services/evidence_id_service.dart';

class EdgeSyncService {
  EdgeSyncService(this._client, {DeviceInfoPlugin? deviceInfo})
      : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final DioClient _client;
  final DeviceInfoPlugin _deviceInfo;

  Future<EdgeSyncBatchResponse> syncEvidence({
    required EvidenceDraft draft,
    required String eventType,
    required String aggregateType,
    required String aggregateId,
    Map<String, dynamic> payload = const {},
  }) async {
    final response = await _client.post(
      Endpoints.edgeSyncBatches,
      data: {
        'clientBatchId': newClientUuid(),
        'driverId': draft.driverId,
        'deviceId': await _deviceId(),
        'sentAt': DateTime.now().toUtc().toIso8601String(),
        'evidences': [
          {
            'clientEvidenceId': draft.clientEvidenceId,
            'orderId': draft.orderId,
            'routeId': draft.routeId,
            'type': draft.type,
            'objectKey': draft.objectKey,
            'sha256': draft.sha256,
            'mimeType': draft.mimeType,
            'sizeBytes': draft.sizeBytes,
            'capturedAt': draft.capturedAt.toIso8601String(),
          }
        ],
        'telemetry': draft.latitude == null || draft.longitude == null
            ? <Map<String, dynamic>>[]
            : [
                {
                  'clientTelemetryId': newClientUuid(),
                  'routeId': draft.routeId,
                  'latitude': draft.latitude,
                  'longitude': draft.longitude,
                  'accuracyMeters': draft.accuracyMeters,
                  'speedKmh': draft.speedKmh,
                  'batteryLevel': null,
                  'capturedAt': draft.capturedAt.toIso8601String(),
                }
              ],
        'events': [
          {
            'clientEventId': newClientUuid(),
            'type': eventType,
            'aggregateType': aggregateType,
            'aggregateId': aggregateId,
            'payload': jsonEncode(payload),
            'occurredAt': DateTime.now().toUtc().toIso8601String(),
          }
        ],
      },
    );
    return EdgeSyncBatchResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<String> _deviceId() async {
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        return info.id;
      }
      if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        return info.identifierForVendor ?? info.name;
      }
    } catch (_) {
      // Fall through to a stable enough label for unsupported environments.
    }
    return 'unknown-mobile-device';
  }
}
