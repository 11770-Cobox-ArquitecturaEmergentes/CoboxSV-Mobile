import 'package:cobox_sv_mobile/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();

  Future<int> getUnreadCount();
}
