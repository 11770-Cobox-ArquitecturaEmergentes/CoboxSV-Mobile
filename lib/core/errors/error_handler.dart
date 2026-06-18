import 'package:cobox_sv_mobile/core/errors/exceptions.dart';
import 'package:cobox_sv_mobile/core/errors/failures.dart';

Failure handleException(Exception e) {
  return switch (e) {
    ServerException() => ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
    UnauthorizedException() => AuthFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
    ForbiddenException() => AuthFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
    NotFoundException() => NotFoundFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
    ConflictException() => ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
    ValidationException() => ValidationFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
    TimeoutException() => NetworkFailure(
        message: e.message,
      ),
    NetworkException() => NetworkFailure(
        message: e.message,
      ),
    CacheException() => CacheFailure(
        message: e.message,
      ),
    StorageException() => StorageFailure(
        message: e.message,
      ),
    _ => UnexpectedFailure(message: e.toString()),
  };
}

String getErrorMessage(Failure failure) {
  return switch (failure.runtimeType) {
    ServerFailure _ => 'Something went wrong on our end. Please try again later.',
    AuthFailure _ => failure.message.isNotEmpty
        ? failure.message
        : 'Authentication failed. Please login again.',
    NetworkFailure _ => 'No internet connection. Please check your network settings.',
    ValidationFailure _ => failure.message.isNotEmpty
        ? failure.message
        : 'Please review your input and try again.',
    CacheFailure _ => 'Failed to load cached data.',
    StorageFailure _ => 'Failed to access device storage.',
    NotFoundFailure _ => 'The requested resource was not found.',
    _ => 'An unexpected error occurred. Please try again.',
  };
}

