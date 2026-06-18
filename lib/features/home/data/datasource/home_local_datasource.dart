import 'dart:convert';

import 'package:cobox_sv_mobile/core/storage/local_storage.dart';
import 'package:cobox_sv_mobile/features/home/data/models/dashboard_model.dart';
import 'package:cobox_sv_mobile/features/home/data/models/recent_activity_model.dart';

class HomeLocalDataSource {
  static const String _dashboardKey = 'cached_dashboard';
  static const String _activityKey = 'cached_activities';

  final LocalStorage _storage;

  HomeLocalDataSource(this._storage);

  Future<void> cacheDashboard(DashboardModel dashboard) async {
    final json = jsonEncode(dashboard.toJson());
    await _storage.saveString(_dashboardKey, json);
  }

  DashboardModel? getCachedDashboard() {
    final json = _storage.getString(_dashboardKey);
    if (json == null) return null;
    return DashboardModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> cacheRecentActivity(List<RecentActivityModel> activities) async {
    final json = jsonEncode(activities.map((e) => e.toJson()).toList());
    await _storage.saveString(_activityKey, json);
  }

  List<RecentActivityModel>? getCachedRecentActivity() {
    final json = _storage.getString(_activityKey);
    if (json == null) return null;
    final list = jsonDecode(json) as List<dynamic>;
    return list
      .map((e) => RecentActivityModel.fromJson(e as Map<String, dynamic>))
      .toList();
  }
}
