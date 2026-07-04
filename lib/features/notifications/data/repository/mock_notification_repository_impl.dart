import 'package:cobox_sv_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:cobox_sv_mobile/features/notifications/domain/repository/notification_repository.dart';

class MockNotificationRepositoryImpl implements NotificationRepository {
  final List<NotificationEntity> _notifications = [
    NotificationEntity(
      id: '1',
      title: 'Sincronización parcial',
      body: 'Notificaciones reales aún no están conectadas al backend.',
      type: 'system',
      isRead: false,
      createdAt: DateTime(2026, 7, 3, 9, 0),
    ),
    NotificationEntity(
      id: '2',
      title: 'Modo híbrido',
      body: 'Autenticación, rutas y órdenes ya usan el backend real.',
      type: 'system',
      isRead: true,
      createdAt: DateTime(2026, 7, 3, 8, 30),
    ),
  ];

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    return List<NotificationEntity>.from(_notifications);
  }

  @override
  Future<void> markAllAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((notification) => notification.id == id);
    if (index == -1) return;
    _notifications[index] = _notifications[index].copyWith(isRead: true);
  }

  @override
  Future<int> getUnreadCount() async {
    return _notifications.where((notification) => !notification.isRead).length;
  }
}
