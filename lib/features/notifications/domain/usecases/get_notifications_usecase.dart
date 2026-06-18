import 'package:cobox_sv_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:cobox_sv_mobile/features/notifications/domain/repository/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<List<NotificationEntity>> call() {
    return repository.getNotifications();
  }
}
