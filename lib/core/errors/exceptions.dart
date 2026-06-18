class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException([
    super.message = 'Internal server error',
    int? statusCode,
  ]) : super(statusCode: statusCode ?? 500);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Unauthorized',
    int? statusCode,
  ]) : super(statusCode: statusCode ?? 401);
}

class ForbiddenException extends AppException {
  const ForbiddenException([
    super.message = 'Forbidden',
    int? statusCode,
  ]) : super(statusCode: statusCode ?? 403);
}

class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'Resource not found',
    int? statusCode,
  ]) : super(statusCode: statusCode ?? 404);
}

class ConflictException extends AppException {
  const ConflictException([
    super.message = 'Conflict',
    int? statusCode,
  ]) : super(statusCode: statusCode ?? 409);
}

class ValidationException extends AppException {
  final Map<String, dynamic>? fieldErrors;

  const ValidationException([
    super.message = 'Validation failed',
    this.fieldErrors,
    int? statusCode,
  ]) : super(statusCode: statusCode ?? 422);
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out']);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

class StorageException extends AppException {
  const StorageException([super.message = 'Storage error']);
}
