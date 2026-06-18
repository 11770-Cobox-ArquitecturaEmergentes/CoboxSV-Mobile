import 'package:cobox_sv_mobile/core/errors/exceptions.dart';
import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/core/network/network_info.dart';
import 'package:cobox_sv_mobile/features/notifications/data/datasource/notification_remote_datasource.dart';
import 'package:cobox_sv_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:cobox_sv_mobile/features/notifications/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    if (!await networkInfo.isConnected.first) {
      throw const NetworkFailure(message: 'Sin conexión a internet');
    }
    try {
      final models = await remoteDataSource.getNotifications();
      return models.map((m) => m.toEntity()).toList();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    if (!await networkInfo.isConnected.first) {
      throw const NetworkFailure(message: 'Sin conexión a internet');
    }
    try {
      await remoteDataSource.markAsRead(id);
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    if (!await networkInfo.isConnected.first) {
      throw const NetworkFailure(message: 'Sin conexión a internet');
    }
    try {
      await remoteDataSource.markAllAsRead();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      return await remoteDataSource.getUnreadCount();
    } on AppException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    }
  }
}
