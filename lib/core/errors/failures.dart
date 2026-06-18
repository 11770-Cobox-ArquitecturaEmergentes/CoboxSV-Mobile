import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final int? statusCode;

  const Failure({
    required this.message,
    this.code,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, code, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Internal server error',
    super.code,
    super.statusCode,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication error',
    super.code,
    super.statusCode,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network error',
    super.code,
    super.statusCode,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Validation error',
    super.code,
    super.statusCode,
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache error',
    super.code,
    super.statusCode,
  });
}

class StorageFailure extends Failure {
  const StorageFailure({
    super.message = 'Storage error',
    super.code,
    super.statusCode,
  });
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Resource not found',
    super.code,
    super.statusCode,
  });
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred',
    super.code,
    super.statusCode,
  });
}
