import 'package:cobox_sv_mobile/core/errors/error_handler.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/entities/incident_entity.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/repository/incident_repository.dart';
import 'package:cobox_sv_mobile/shared/enums/incident_type.dart';

class GetIncidentsUseCase {
  final IncidentRepository _repository;

  GetIncidentsUseCase(this._repository);

  Future<({List<IncidentEntity> incidents, int total})> call({
    int page = 1,
    int limit = 20,
    IncidentType? type,
    IncidentStatus? status,
    String? search,
  }) async {
    try {
      return await _repository.getIncidents(
        page: page,
        limit: limit,
        type: type,
        status: status,
        search: search,
      );
    } on Exception catch (e) {
      throw handleException(e);
    }
  }
}
