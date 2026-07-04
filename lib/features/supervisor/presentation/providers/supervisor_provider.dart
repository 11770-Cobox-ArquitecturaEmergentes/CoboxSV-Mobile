import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cobox_sv_mobile/app/providers.dart';
import 'package:cobox_sv_mobile/core/api/dio_client.dart';

class SupervisorRouteMetric {
  const SupervisorRouteMetric({
    required this.label,
    required this.efficiency,
  });

  final String label;
  final double efficiency;
}

class SupervisorOverview {
  const SupervisorOverview({
    required this.totalVehicles,
    required this.activeVehicles,
    required this.maintenanceVehicles,
    required this.activeDrivers,
    required this.activeOrders,
    required this.totalRoutes,
    required this.routesInProgress,
    required this.routeMetrics,
  });

  final int totalVehicles;
  final int activeVehicles;
  final int maintenanceVehicles;
  final int activeDrivers;
  final int activeOrders;
  final int totalRoutes;
  final int routesInProgress;
  final List<SupervisorRouteMetric> routeMetrics;
}

final supervisorOverviewProvider =
    FutureProvider.autoDispose<SupervisorOverview>((ref) async {
  final client = ref.watch(dioClientProvider);

  final responses = await Future.wait([
    _safeGetList(client, '/vehicles'),
    _safeGetList(client, '/drivers'),
    _safeGetList(client, '/orders'),
    _safeGetList(client, '/routes'),
  ]);

  final vehicles = responses[0];
  final drivers = responses[1];
  final orders = responses[2];
  final routes = responses[3];

  final activeVehicles = vehicles.where((vehicle) {
    final status = vehicle['vehicleStatus']?.toString().toUpperCase() ?? '';
    return status == 'OPERATIONAL' || status == 'ON_ROUTE';
  }).length;

  final maintenanceVehicles = vehicles.where((vehicle) {
    final status = vehicle['vehicleStatus']?.toString().toUpperCase() ?? '';
    return status == 'IN_MAINTENANCE';
  }).length;

  final activeDrivers = drivers.where((driver) {
    final status = driver['driverStatus']?.toString().toUpperCase() ?? '';
    return status != 'UNAVAILABLE';
  }).length;

  final activeOrders = orders.where((order) {
    final status = order['orderStatus']?.toString().toUpperCase() ?? '';
    return status != 'DELIVERED' && status != 'CANCELLED';
  }).length;

  final routesInProgress = routes.where((route) {
    final status = route['routeStatus']?.toString().toUpperCase() ?? '';
    return status == 'IN_PROGRESS';
  }).length;

  final routeMetrics = routes.take(5).map((route) {
    final label = 'R-${route['id'] ?? '-'}';
    final totalOrders = _orderIds(route['ordersIds']).length;
    final finishedOrders = _orderIds(route['finishedOrderIds']).length;
    final efficiency = totalOrders == 0
        ? 0.0
        : ((finishedOrders / totalOrders) * 100).toDouble().clamp(0.0, 100.0);

    return SupervisorRouteMetric(
      label: label,
      efficiency: efficiency,
    );
  }).toList();

  return SupervisorOverview(
    totalVehicles: vehicles.length,
    activeVehicles: activeVehicles,
    maintenanceVehicles: maintenanceVehicles,
    activeDrivers: activeDrivers,
    activeOrders: activeOrders,
    totalRoutes: routes.length,
    routesInProgress: routesInProgress,
    routeMetrics: routeMetrics,
  );
});

Future<List<Map<String, dynamic>>> _safeGetList(
  DioClient client,
  String path,
) async {
  final response = await client.get(path);
  if (response.data is! List) return const [];

  return (response.data as List<dynamic>)
      .whereType<Map<String, dynamic>>()
      .toList();
}

List<String> _orderIds(dynamic value) {
  if (value is! List) return const [];

  return value.map((entry) {
    if (entry is Map<String, dynamic>) {
      return (entry['orderId'] ?? '').toString();
    }
    return entry.toString();
  }).where((id) => id.isNotEmpty).toList();
}
