import 'package:cobox_sv_mobile/core/utils/either.dart';
import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:cobox_sv_mobile/features/authentication/domain/repository/auth_repository.dart';

final _mockUser = UserEntity(
  id: 'mock-001',
  name: 'Carlos Rodríguez',
  email: 'carlos@coboxsv.com',
  phone: '+54 11 1234-5678',
  photoUrl: null,
  role: 'Conductor',
  isActive: true,
  createdAt: DateTime(2026, 1, 15),
);

class MockAuthRepositoryImpl implements AuthRepository {
  int _mockUserId = 0;

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isEmpty || password.isEmpty) {
      return const Left(AuthFailure(message: 'Credenciales inválidas'));
    }
    return Right(_mockUser);
  }

  @override
  Future<Either<Failure, UserEntity>> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String licenceNumber,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockUserId++;
    return Right(
      UserEntity(
        id: 'mock-${_mockUserId.toString().padLeft(3, '0')}',
        name: name,
        email: email,
        phone: phone,
        photoUrl: null,
        role: 'Conductor',
        isActive: true,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    return Right(_mockUser);
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> resetPassword(
    String token,
    String password,
  ) async {
    return const Right(null);
  }
}
