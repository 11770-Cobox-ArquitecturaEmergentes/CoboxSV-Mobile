import 'package:cobox_sv_mobile/core/errors/error_handler.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/repository/incident_repository.dart';

class UploadEvidenceUseCase {
  final IncidentRepository _repository;

  UploadEvidenceUseCase(this._repository);

  Future<List<String>> call(List<String> filePaths) async {
    try {
      return await _repository.uploadEvidence(filePaths);
    } on Exception catch (e) {
      throw handleException(e);
    }
  }
}
