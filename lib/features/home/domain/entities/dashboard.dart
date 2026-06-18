import 'package:equatable/equatable.dart';

class Dashboard with EquatableMixin {
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

  const Dashboard({
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

  @override
  List<Object?> get props => [
    totalOrders,
    activeOrders,
    completedOrders,
    pendingOrders,
    totalDistance,
    totalFuel,
    efficiency,
    totalStops,
    incidentsReported,
    notificationsUnread,
  ];
}
