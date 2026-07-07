import 'dart:io';

import 'package:dio/dio.dart';

import 'package:cobox_sv_mobile/core/api/dio_client.dart';
import 'package:cobox_sv_mobile/core/api/endpoints.dart';
import 'package:cobox_sv_mobile/features/evidence/data/models/evidence_models.dart';

class EvidenceUploadService {
  EvidenceUploadService(this._client, {Dio? directDio})
      : _directDio = directDio ?? Dio();

  final DioClient _client;
  final Dio _directDio;

  Future<UploadIntent> createIntent(EvidenceDraft draft) async {
    final response = await _client.post(
      Endpoints.mobileEvidenceUploadIntents,
      data: {
        'clientEvidenceId': draft.clientEvidenceId,
        'driverId': draft.driverId,
        'orderId': draft.orderId,
        'routeId': draft.routeId,
        'type': draft.type,
        'mimeType': draft.mimeType,
        'sizeBytes': draft.sizeBytes,
        'sha256': draft.sha256,
      },
    );
    return UploadIntent.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> uploadObject(EvidenceDraft draft, UploadIntent intent) async {
    final uploadUrl = intent.uploadUrl;
    if (uploadUrl == null || uploadUrl.isEmpty) {
      return;
    }

    final file = File(draft.filePath);
    await _directDio.putUri(
      Uri.parse(uploadUrl),
      data: file.openRead(),
      options: Options(
        headers: {
          ...intent.requiredHeaders,
          Headers.contentLengthHeader: draft.sizeBytes,
        },
        contentType: draft.mimeType,
      ),
    );
  }

  Future<UploadConfirmation> confirmIntent(UploadIntent intent) async {
    final response = await _client.post(
      '${Endpoints.mobileEvidenceUploadIntents}/${intent.uploadIntentId}/confirm',
      data: {
        'clientEvidenceId': intent.clientEvidenceId,
      },
    );
    return UploadConfirmation.fromJson(response.data as Map<String, dynamic>);
  }
}
