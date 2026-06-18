import 'package:cobox_sv_mobile/core/api/dio_client.dart';
import 'package:cobox_sv_mobile/core/api/endpoints.dart';
import 'package:cobox_sv_mobile/core/errors/exceptions.dart';
import 'package:cobox_sv_mobile/features/notifications/data/models/notification_model.dart';

class NotificationRemoteDataSource {
  final DioClient _client;

  NotificationRemoteDataSource(this._client);

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _client.get(Endpoints.notifications);
    final data = response.data as Map<String, dynamic>?;
    final list = data?['data'] as List<dynamic>?;
    if (list == null) {
      throw ServerException('Invalid notifications response');
    }
    return list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(String id) async {
    await _client.put('${Endpoints.markRead}$id');
  }

  Future<void> markAllAsRead() async {
    await _client.post(Endpoints.markAllRead);
  }

  Future<int> getUnreadCount() async {
    final response = await _client.get(
      Endpoints.notifications,
      queryParameters: {'unread_only': true, 'per_page': 1},
    );
    final data = response.data as Map<String, dynamic>?;
    return (data?['meta']?['total'] as int?) ?? 0;
  }
}
