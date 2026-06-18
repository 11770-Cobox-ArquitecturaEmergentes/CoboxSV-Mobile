// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardModel _$DashboardModelFromJson(Map<String, dynamic> json) =>
    DashboardModel(
      totalOrders: (json['totalOrders'] as num).toInt(),
      activeOrders: (json['activeOrders'] as num).toInt(),
      completedOrders: (json['completedOrders'] as num).toInt(),
      pendingOrders: (json['pendingOrders'] as num).toInt(),
      totalDistance: (json['totalDistance'] as num).toDouble(),
      totalFuel: (json['totalFuel'] as num).toDouble(),
      efficiency: (json['efficiency'] as num).toDouble(),
      totalStops: (json['totalStops'] as num).toInt(),
      incidentsReported: (json['incidentsReported'] as num).toInt(),
      notificationsUnread: (json['notificationsUnread'] as num).toInt(),
    );

Map<String, dynamic> _$DashboardModelToJson(DashboardModel instance) =>
    <String, dynamic>{
      'totalOrders': instance.totalOrders,
      'activeOrders': instance.activeOrders,
      'completedOrders': instance.completedOrders,
      'pendingOrders': instance.pendingOrders,
      'totalDistance': instance.totalDistance,
      'totalFuel': instance.totalFuel,
      'efficiency': instance.efficiency,
      'totalStops': instance.totalStops,
      'incidentsReported': instance.incidentsReported,
      'notificationsUnread': instance.notificationsUnread,
    };
