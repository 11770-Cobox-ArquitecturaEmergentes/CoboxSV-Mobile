import 'package:cobox_sv_mobile/core/utils/either.dart';
import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/core/errors/error_handler.dart';
import 'package:cobox_sv_mobile/core/errors/exceptions.dart';
import 'package:cobox_sv_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:cobox_sv_mobile/features/authentication/domain/repository/auth_repository.dart';
import 'package:cobox_sv_mobile/features/authentication/data/datasource/auth_remote_datasource.dart';
import 'package:cobox_sv_mobile/features/authentication/data/datasource/auth_local_datasource.dart';
import 'package:cobox_sv_mobile/features/authentication/data/datasource/fleet_remote_datasource.dart';
import 'package:cobox_sv_mobile/shared/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final FleetRemoteDataSource fleetRemoteDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.fleetRemoteDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await remoteDataSource.login(email, password);
      await localDataSource.saveTokens(
        response.accessToken,
        response.refreshToken,
      );
      await localDataSource.saveUser(response.user);
      await localDataSource.saveCredentials(email, password);
      return Right(_userModelToEntity(response.user));
    } on Exception catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String licenceNumber,
  }) async {
    try {
      final response = await remoteDataSource.signup(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      await localDataSource.saveTokens(
        response.accessToken,
        response.refreshToken,
      );
      await localDataSource.saveUser(response.user);
      await localDataSource.saveCredentials(email, password);
      try {
        await fleetRemoteDataSource.createDriver(
          email: email,
          licenceNumber: licenceNumber,
        );
      } on AppException catch (error) {
        final normalizedMessage = error.message.toLowerCase();
        final driverAlreadyExists =
            error.statusCode == 409 &&
            normalizedMessage.contains('driver already exists');
        if (!driverAlreadyExists) {
          rethrow;
        }
      }
      return Right(_userModelToEntity(response.user));
    } on Exception catch (e) {
      await localDataSource.clearTokens();
      await localDataSource.clearUser();
      await localDataSource.clearCredentials();
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
    } on Exception {
      // Continue with local cleanup even if remote logout fails
    }
    await localDataSource.clearTokens();
    await localDataSource.clearUser();
    await localDataSource.clearCredentials();
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await localDataSource.getUser();
      if (user != null) {
        try {
          final remoteUser = await remoteDataSource.getCurrentUserProfile();
          final updatedUser = UserModel.fromJson(remoteUser);
          await localDataSource.saveUser(updatedUser);
          return Right(_userModelToEntity(updatedUser));
        } on Exception {
          await localDataSource.clearTokens();
          await localDataSource.clearUser();
          await localDataSource.clearCredentials();
          return Left(
            AuthFailure(
              message:
                  'La sesión ya no es válida. Inicia sesión nuevamente.',
            ),
          );
        }
      }
      return Left(CacheFailure(message: 'No cached user found'));
    } on Exception catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final token = await localDataSource.getAccessToken();
      return Right(token != null && token.isNotEmpty);
    } on Exception catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(null);
    } on Exception catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(
    String token,
    String password,
  ) async {
    try {
      await remoteDataSource.resetPassword(token, password);
      return const Right(null);
    } on Exception catch (e) {
      return Left(handleException(e));
    }
  }

  UserEntity _userModelToEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      name: model.name,
      email: model.email,
      phone: model.phone,
      photoUrl: model.photoUrl,
      role: model.role.value,
      isActive: model.isActive,
      createdAt: model.createdAt,
    );
  }
}
