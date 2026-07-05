import 'package:cobox_sv_mobile/core/errors/error_handler.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/entities/incident_entity.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/repository/incident_repository.dart';

class GetIncidentDetailUseCase {
  final IncidentRepository _repository;

  GetIncidentDetailUseCase(this._repository);

  Future<IncidentEntity> call(String id) async {
    try {
      return await _repository.getIncidentDetail(id);
    } on Exception catch (e) {
      throw handleException(e);
    }
  }
}
