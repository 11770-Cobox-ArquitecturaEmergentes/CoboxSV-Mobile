import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/features/notifications/data/repository/mock_notification_repository_impl.dart';
import 'package:cobox_sv_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:cobox_sv_mobile/features/notifications/domain/repository/notification_repository.dart';
import 'package:cobox_sv_mobile/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:cobox_sv_mobile/features/notifications/domain/usecases/mark_read_usecase.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return MockNotificationRepositoryImpl();
});

final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((ref) {
  return GetNotificationsUseCase(ref.watch(notificationRepositoryProvider));
});

final markReadUseCaseProvider = Provider<MarkReadUseCase>((ref) {
  return MarkReadUseCase(ref.watch(notificationRepositoryProvider));
});

final markAllReadUseCaseProvider = Provider<MarkAllReadUseCase>((ref) {
  return MarkAllReadUseCase(ref.watch(notificationRepositoryProvider));
});

enum NotificationsStatus { initial, loading, loaded, error }

class NotificationsState {
  final NotificationsStatus status;
  final List<NotificationEntity> notifications;
  final String? error;
  final int unreadCount;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.error,
    this.unreadCount = 0,
  });

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationEntity>? notifications,
    String? error,
    int? unreadCount,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final GetNotificationsUseCase _getNotifications;
  final MarkReadUseCase _markRead;
  final MarkAllReadUseCase _markAllRead;

  NotificationsNotifier(
    this._getNotifications,
    this._markRead,
    this._markAllRead,
  ) : super(const NotificationsState());

  Future<void> loadNotifications() async {
    state = state.copyWith(status: NotificationsStatus.loading, error: null);
    try {
      final notifications = await _getNotifications();
      final unread = notifications.where((n) => !n.isRead).length;
      state = state.copyWith(
        status: NotificationsStatus.loaded,
        notifications: notifications,
        unreadCount: unread,
      );
    } on Failure catch (e) {
      state = state.copyWith(
        status: NotificationsStatus.error,
        error: e.message,
      );
    }
  }

  Future<void> markAsRead(String id) async {
    await _markRead(id);
    final updated = state.notifications.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    final unread = updated.where((n) => !n.isRead).length;
    state = state.copyWith(
      notifications: updated,
      unreadCount: unread,
    );
  }

  Future<void> markAllAsRead() async {
    await _markAllRead();
    final updated = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    state = state.copyWith(notifications: updated, unreadCount: 0);
  }

  void removeNotification(String id) {
    final updated = state.notifications.where((n) => n.id != id).toList();
    final unread = updated.where((n) => !n.isRead).length;
    state = state.copyWith(notifications: updated, unreadCount: unread);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(
    ref.watch(getNotificationsUseCaseProvider),
    ref.watch(markReadUseCaseProvider),
    ref.watch(markAllReadUseCaseProvider),
  );
});
