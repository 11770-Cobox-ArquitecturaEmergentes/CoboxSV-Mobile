import 'package:cobox_sv_mobile/core/errors/error_handler.dart';
import 'package:cobox_sv_mobile/core/errors/exceptions.dart';
import 'package:cobox_sv_mobile/features/incidents/data/datasource/incident_remote_datasource.dart';
import 'package:cobox_sv_mobile/features/incidents/data/models/incident_model.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/entities/incident_entity.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/repository/incident_repository.dart';
import 'package:cobox_sv_mobile/shared/enums/incident_type.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  final IncidentRemoteDataSource _dataSource;

  IncidentRepositoryImpl(this._dataSource);

  @override
  Future<({List<IncidentEntity> incidents, int total})> getIncidents({
    int page = 1,
    int limit = 20,
    IncidentType? type,
    IncidentStatus? status,
    String? search,
  }) async {
    try {
      final result = await _dataSource.getIncidents(
        page: page,
        limit: limit,
        type: type?.value,
        status: status?.name,
        search: search,
      );
      return (
        incidents: result.incidents.map((e) => e.toEntity()).toList(),
        total: result.total,
      );
    } on AppException catch (e) {
      throw handleException(e);
    }
  }

  @override
  Future<IncidentEntity> createIncident(IncidentEntity incident) async {
    try {
      final model = IncidentModel.fromEntity(incident);
      final result = await _dataSource.createIncident(model);
      return result.toEntity();
    } on AppException catch (e) {
      throw handleException(e);
    }
  }

  @override
  Future<IncidentEntity> getIncidentDetail(String id) async {
    try {
      final model = await _dataSource.getIncidentDetail(id);
      return model.toEntity();
    } on AppException catch (e) {
      throw handleException(e);
    }
  }

  @override
  Future<List<String>> uploadEvidence(List<String> filePaths) async {
    try {
      return await _dataSource.uploadEvidence(filePaths);
    } on AppException catch (e) {
      throw handleException(e);
    }
  }
}
