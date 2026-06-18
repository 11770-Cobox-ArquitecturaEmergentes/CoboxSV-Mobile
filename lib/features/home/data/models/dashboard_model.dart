import 'package:json_annotation/json_annotation.dart';

import 'package:cobox_sv_mobile/features/home/domain/entities/dashboard.dart';

part 'dashboard_model.g.dart';

@JsonSerializable()
class DashboardModel {
  final int totalOrders;
  final int activeOrders;
  final int completedOrders;
  final int pendingOrders;
  final double totalDistance;
  final double totalFuel;
  final double efficiency;
  final int totalStops;
  final int incidentsReported;
  final int notificationsUnread;

  const DashboardModel({
    required this.totalOrders,
    required this.activeOrders,
    required this.completedOrders,
    required this.pendingOrders,
    required this.totalDistance,
    required this.totalFuel,
    required this.efficiency,
    required this.totalStops,
    required this.incidentsReported,
    required this.notificationsUnread,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) =>
    _$DashboardModelFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardModelToJson(this);

  Dashboard toEntity() => Dashboard(
    totalOrders: totalOrders,
    activeOrders: activeOrders,
    completedOrders: completedOrders,
    pendingOrders: pendingOrders,
    totalDistance: totalDistance,
    totalFuel: totalFuel,
    efficiency: efficiency,
    totalStops: totalStops,
    incidentsReported: incidentsReported,
    notificationsUnread: notificationsUnread,
  );
}
