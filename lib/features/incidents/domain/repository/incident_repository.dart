import 'package:cobox_sv_mobile/features/incidents/domain/entities/incident_entity.dart';
import 'package:cobox_sv_mobile/shared/enums/incident_type.dart';

abstract class IncidentRepository {
  Future<({List<IncidentEntity> incidents, int total})> getIncidents({
    int page = 1,
    int limit = 20,
    IncidentType? type,
    IncidentStatus? status,
    String? search,
  });

  Future<IncidentEntity> createIncident(IncidentEntity incident);

  Future<IncidentEntity> getIncidentDetail(String id);

  Future<List<String>> uploadEvidence(List<String> filePaths);
}
