import 'dart:io';
import 'package:cobox_sv_mobile/core/api/dio_client.dart';
import 'package:cobox_sv_mobile/core/api/endpoints.dart';
import 'package:cobox_sv_mobile/core/errors/exceptions.dart';
import 'package:cobox_sv_mobile/features/authentication/data/datasource/auth_local_datasource.dart';
import 'package:cobox_sv_mobile/features/incidents/data/models/incident_model.dart';

class IncidentRemoteDataSource {
  final DioClient _client;
  final AuthLocalDataSource _authLocalDataSource;

  IncidentRemoteDataSource(this._client, this._authLocalDataSource);

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
    if (response.data is! List) {
      throw const ServerException('Invalid incidents response');
    }

    var incidents = (response.data as List<dynamic>)
        .map((e) => IncidentModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final currentUser = await _authLocalDataSource.getUser();
    final currentUserId = currentUser?.id;
    if (currentUserId != null && currentUserId.isNotEmpty) {
      incidents = incidents
          .where((incident) => incident.reportedBy == currentUserId)
          .toList();
    }

    if (type != null && type.isNotEmpty) {
      incidents = incidents.where((incident) => incident.type == type).toList();
    }

    if (status != null && status.isNotEmpty) {
      incidents = incidents
          .where((incident) => incident.status.toUpperCase() == status.toUpperCase())
          .toList();
    }

    if (search != null && search.isNotEmpty) {
      final normalizedSearch = search.toLowerCase();
      incidents = incidents.where((incident) {
        return incident.id.toLowerCase().contains(normalizedSearch) ||
            incident.title.toLowerCase().contains(normalizedSearch) ||
            incident.description.toLowerCase().contains(normalizedSearch);
      }).toList();
    }

    incidents.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final total = incidents.length;
    final start = ((page - 1) * limit).clamp(0, total).toInt();
    final end = (start + limit).clamp(0, total).toInt();
    return (incidents: incidents.sublist(start, end), total: total);
  }

  Future<IncidentModel> createIncident(IncidentModel incident) async {
    final currentUser = await _authLocalDataSource.getUser();
    final responsibleUserId = int.tryParse(currentUser?.id ?? '');
    if (responsibleUserId == null) {
      throw const ServerException('No se pudo resolver el conductor autenticado');
    }

    final response = await _client.post(
      Endpoints.createIncident,
      data: {
        'type': incident.type,
        'description': incident.description,
        'severity': incident.severity.toUpperCase(),
        'responsibleUserId': responsibleUserId,
      },
    );
    return IncidentModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<IncidentModel> getIncidentDetail(String id) async {
    final response = await _client.get('${Endpoints.incidents}/$id');
    return IncidentModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<String>> uploadEvidence(List<String> filePaths) async {
    for (final path in filePaths) {
      final file = File(path);
      if (!file.existsSync()) {
        throw ServerException('No se encontro el archivo de evidencia: $path');
      }
    }
    return filePaths;
  }
}
