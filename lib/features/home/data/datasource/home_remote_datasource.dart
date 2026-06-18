import 'package:cobox_sv_mobile/core/api/dio_client.dart';
import 'package:cobox_sv_mobile/core/api/endpoints.dart';
import 'package:cobox_sv_mobile/features/home/data/models/dashboard_model.dart';
import 'package:cobox_sv_mobile/features/home/data/models/recent_activity_model.dart';

class HomeRemoteDataSource {
  final DioClient _dioClient;

  HomeRemoteDataSource(this._dioClient);

  Future<DashboardModel> getDashboard() async {
    final response = await _dioClient.get(Endpoints.dashboard);
    return DashboardModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<RecentActivityModel>> getRecentActivity({int limit = 10}) async {
    final response = await _dioClient.get(
      Endpoints.recentActivity,
      queryParameters: {'limit': limit},
    );
    final list = response.data as List<dynamic>;
    return list
      .map((e) => RecentActivityModel.fromJson(e as Map<String, dynamic>))
      .toList();
  }
}
