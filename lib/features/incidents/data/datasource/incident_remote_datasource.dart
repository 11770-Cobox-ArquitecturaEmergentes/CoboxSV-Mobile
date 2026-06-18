import 'dart:io';
import 'package:cobox_sv_mobile/core/api/dio_client.dart';
import 'package:cobox_sv_mobile/core/api/endpoints.dart';
import 'package:cobox_sv_mobile/features/incidents/data/models/incident_model.dart';

class IncidentRemoteDataSource {
  final DioClient _client;

  IncidentRemoteDataSource(this._client);

  Future<({List<IncidentModel> incidents, int total})> getIncidents({
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (type != null) queryParams['type'] = type;
    if (status != null) queryParams['status'] = status;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _client.get(
      Endpoints.incidents,
      queryParameters: queryParams,
    );

    final data = response.data as Map<String, dynamic>;
    final list = (data['data'] as List<dynamic>?)
            ?.map((e) => IncidentModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final total = data['total'] as int? ?? list.length;
    return (incidents: list, total: total);
  }

  Future<IncidentModel> createIncident(IncidentModel incident) async {
    final response = await _client.post(
      Endpoints.createIncident,
      data: incident.toJson(),
    );
    final data = response.data as Map<String, dynamic>;
    final incidentData = data['data'] as Map<String, dynamic>? ?? data;
    return IncidentModel.fromJson(incidentData);
  }

  Future<IncidentModel> getIncidentDetail(String id) async {
    final response = await _client.get('${Endpoints.incidents}/$id');
    final data = response.data as Map<String, dynamic>;
    final incidentData = data['data'] as Map<String, dynamic>? ?? data;
    return IncidentModel.fromJson(incidentData);
  }

  Future<List<String>> uploadEvidence(List<String> filePaths) async {
    final files = <String, File>{};
    for (int i = 0; i < filePaths.length; i++) {
      files['file_$i'] = File(filePaths[i]);
    }

    final response = await _client.upload(
      Endpoints.uploadEvidence,
      files: files,
    );

    final data = response.data as Map<String, dynamic>;
    final urls = (data['data'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    return urls;
  }
}
