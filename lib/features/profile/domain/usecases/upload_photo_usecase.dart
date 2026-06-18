import 'package:cobox_sv_mobile/features/profile/domain/repository/profile_repository.dart';

class UploadPhotoUseCase {
  final ProfileRepository repository;

  UploadPhotoUseCase(this.repository);

  Future<String> call(String filePath) {
    return repository.uploadPhoto(filePath);
  }
}
