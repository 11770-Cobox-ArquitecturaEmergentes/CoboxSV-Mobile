import 'package:cobox_sv_mobile/core/utils/either.dart';
import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/features/authentication/domain/repository/auth_repository.dart';

class ForgotPasswordParams {
  final String email;

  const ForgotPasswordParams({required this.email});
}

class ForgotPasswordUseCase {
  final AuthRepository repository;

  const ForgotPasswordUseCase({required this.repository});

  Future<Either<Failure, void>> call(ForgotPasswordParams params) {
    return repository.forgotPassword(params.email);
  }
}
