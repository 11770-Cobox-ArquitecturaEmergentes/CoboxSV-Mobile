import 'package:cobox_sv_mobile/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();

  Future<ProfileEntity> updateProfile(ProfileEntity profile);

  Future<String> uploadPhoto(String filePath);

  Future<void> changePassword(String currentPassword, String newPassword);
}
