import 'package:cobox_sv_mobile/core/errors/error_handler.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/entities/incident_entity.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/repository/incident_repository.dart';

class CreateIncidentUseCase {
  final IncidentRepository _repository;

  CreateIncidentUseCase(this._repository);

  Future<IncidentEntity> call(IncidentEntity incident) async {
    try {
      return await _repository.createIncident(incident);
    } on Exception catch (e) {
      throw handleException(e);
    }
  }
}
