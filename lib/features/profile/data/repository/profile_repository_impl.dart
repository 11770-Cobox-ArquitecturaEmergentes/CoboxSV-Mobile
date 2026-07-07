import 'package:cobox_sv_mobile/core/errors/exceptions.dart';
import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/core/network/network_info.dart';
import 'package:cobox_sv_mobile/features/profile/data/datasource/profile_remote_datasource.dart';
import 'package:cobox_sv_mobile/features/profile/data/models/profile_model.dart';
import 'package:cobox_sv_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:cobox_sv_mobile/features/profile/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<ProfileEntity> getProfile() async {
    if (!await networkInfo.checkConnectivity()) {
      throw const NetworkFailure(
        message: 'No se pudo cargar el perfil. Intenta nuevamente.',
      );
    }
    try {
      final model = await remoteDataSource.getProfile();
      return model.toEntity();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    }
  }

  @override
  Future<ProfileEntity> updateProfile(ProfileEntity profile) async {
    if (!await networkInfo.checkConnectivity()) {
      throw const NetworkFailure(
        message: 'No se pudo guardar el perfil. Intenta nuevamente.',
      );
    }
    try {
      final model = ProfileModel.fromEntity(profile);
      final updated = await remoteDataSource.updateProfile(model.toJson());
      return updated.toEntity();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    }
  }

  @override
  Future<String> uploadPhoto(String filePath) async {
    if (!await networkInfo.checkConnectivity()) {
      throw const NetworkFailure(
        message: 'No se pudo subir la foto. Intenta nuevamente.',
      );
    }
    try {
      return await remoteDataSource.uploadPhoto(filePath);
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    if (!await networkInfo.checkConnectivity()) {
      throw const NetworkFailure(
        message: 'No se pudo cambiar la contrasena. Intenta nuevamente.',
      );
    }
    try {
      await remoteDataSource.changePassword(currentPassword, newPassword);
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    }
  }
}
