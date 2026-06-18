import 'package:cobox_sv_mobile/features/notifications/domain/repository/notification_repository.dart';

class MarkReadUseCase {
  final NotificationRepository repository;

  MarkReadUseCase(this.repository);

  Future<void> call(String id) {
    return repository.markAsRead(id);
  }
}

class MarkAllReadUseCase {
  final NotificationRepository repository;

  MarkAllReadUseCase(this.repository);

  Future<void> call() {
    return repository.markAllAsRead();
  }
}
