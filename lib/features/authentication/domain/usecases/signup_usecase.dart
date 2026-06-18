import 'package:cobox_sv_mobile/core/utils/either.dart';
import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:cobox_sv_mobile/features/authentication/domain/repository/auth_repository.dart';

class SignupParams {
  final String name;
  final String email;
  final String password;
  final String phone;

  const SignupParams({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });
}

class SignupUseCase {
  final AuthRepository repository;

  const SignupUseCase({required this.repository});

  Future<Either<Failure, UserEntity>> call(SignupParams params) {
    return repository.signup(
      name: params.name,
      email: params.email,
      password: params.password,
      phone: params.phone,
    );
  }
}
