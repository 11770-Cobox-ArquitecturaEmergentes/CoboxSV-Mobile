import 'package:cobox_sv_mobile/core/utils/either.dart';
import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:cobox_sv_mobile/features/authentication/domain/repository/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  const GetCurrentUserUseCase({required this.repository});

  Future<Either<Failure, UserEntity>> call() {
    return repository.getCurrentUser();
  }
}
