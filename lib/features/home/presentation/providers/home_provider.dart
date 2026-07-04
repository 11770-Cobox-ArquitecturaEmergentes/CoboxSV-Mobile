import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/features/home/domain/entities/activity.dart';
import 'package:cobox_sv_mobile/features/home/domain/entities/dashboard.dart';
import 'package:cobox_sv_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:cobox_sv_mobile/features/orders/domain/repository/order_repository.dart';
import 'package:cobox_sv_mobile/features/orders/presentation/providers/order_provider.dart';
import 'package:cobox_sv_mobile/features/routes/domain/entities/route_entity.dart';
import 'package:cobox_sv_mobile/features/routes/domain/repository/route_repository.dart';
import 'package:cobox_sv_mobile/features/routes/presentation/providers/route_provider.dart';
import 'package:cobox_sv_mobile/shared/enums/order_status.dart';

enum HomeStatus { loading, loaded, error, refreshing }

class HomeState {
  final HomeStatus status;
  final Dashboard? dashboard;
  final List<Activity> recentActivity;
  final List<RouteEntity> routes;
  final RouteEntity? activeRoute;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.loading,
    this.dashboard,
    this.recentActivity = const [],
    this.routes = const [],
    this.activeRoute,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    Dashboard? dashboard,
    List<Activity>? recentActivity,
    List<RouteEntity>? routes,
    RouteEntity? activeRoute,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      dashboard: dashboard ?? this.dashboard,
      recentActivity: recentActivity ?? this.recentActivity,
      routes: routes ?? this.routes,
      activeRoute: activeRoute ?? this.activeRoute,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class HomeController extends StateNotifier<HomeState> {
  final OrderRepository _orderRepository;
  final RouteRepository _routeRepository;

  HomeController({
    required OrderRepository orderRepository,
    required RouteRepository routeRepository,
  })  : _orderRepository = orderRepository,
        _routeRepository = routeRepository,
        super(const HomeState());

  Future<void> loadData() async {
    state = const HomeState(status: HomeStatus.loading);
    await _fetchData();
  }

  Future<void> refresh() async {
    state = state.copyWith(status: HomeStatus.refreshing);
    await _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final orderResult = await _orderRepository.getOrders(page: 1, limit: 200);
      final routesResult = await _safeGetRoutes();
      final orders = orderResult.orders;
      final routes = routesResult.routes;
      final activeRoute = routes.cast<RouteEntity?>().firstWhere(
            (route) => route?.status == 'IN_PROGRESS',
            orElse: () => null,
          );

      state = HomeState(
        status: HomeStatus.loaded,
        dashboard: _buildDashboard(orders, routes),
        recentActivity: _buildRecentActivity(orders, routes),
        routes: routes,
        activeRoute: activeRoute,
        errorMessage: routesResult.errorMessage,
      );
    } catch (error) {
      state = HomeState(
        status: HomeStatus.error,
        dashboard: state.dashboard,
        recentActivity: state.recentActivity,
        routes: state.routes,
        activeRoute: state.activeRoute,
        errorMessage: error.toString(),
      );
    }
  }

  Future<({List<RouteEntity> routes, String? errorMessage})> _safeGetRoutes() async {
    try {
      final routes = await _routeRepository.getRoutes();
      return (routes: routes, errorMessage: null);
    } on Failure catch (error) {
      if (_shouldIgnoreRoutesFailure(error)) {
        return (routes: <RouteEntity>[], errorMessage: null);
      }
      return (routes: <RouteEntity>[], errorMessage: error.message);
    }
  }

  bool _shouldIgnoreRoutesFailure(Failure error) {
    final message = error.message.toLowerCase();
    return error.statusCode == 404 ||
        error.statusCode == 500 &&
            (message.contains('driver not found') ||
                message.contains('contexto fleet'));
  }

  Dashboard _buildDashboard(
    List<OrderEntity> orders,
    List<RouteEntity> routes,
  ) {
    final completedOrders = orders
        .where((order) => order.status == OrderStatus.completed)
        .length;
    final pendingOrders = orders
        .where(
          (order) =>
              order.status == OrderStatus.pending ||
              order.status == OrderStatus.assigned,
        )
        .length;
    final activeOrders = orders
        .where((order) => order.status == OrderStatus.inProgress)
        .length;
    final totalDistance = routes.fold<double>(
      0,
      (sum, route) => sum + route.distance,
    );
    final totalStops = routes.fold<int>(
      0,
      (sum, route) => sum + route.stops.length,
    );

    return Dashboard(
      totalOrders: orders.length,
      activeOrders: activeOrders,
      completedOrders: completedOrders,
      pendingOrders: pendingOrders,
      totalDistance: totalDistance,
      totalFuel: 0,
      efficiency: 0,
      totalStops: totalStops,
      incidentsReported: 0,
      notificationsUnread: 0,
    );
  }

  List<Activity> _buildRecentActivity(
    List<OrderEntity> orders,
    List<RouteEntity> routes,
  ) {
    final now = DateTime.now();
    final routeActivities = routes.take(3).toList().asMap().entries.map((entry) {
      final route = entry.value;
      return Activity(
        id: 'route-${route.id}',
        title: route.name,
        description: 'Estado actual: ${_routeStatusLabel(route.status)}',
        type: 'route',
        status: route.status,
        timestamp: now.subtract(Duration(minutes: entry.key * 15)),
        relatedId: route.id,
      );
    });

    final orderActivities = orders.take(3).toList().asMap().entries.map((entry) {
      final order = entry.value;
      return Activity(
        id: 'order-${order.id}',
        title: 'Pedido #${order.orderNumber}',
        description: 'Estado: ${order.status.label}',
        type: 'order',
        status: order.status.value,
        timestamp: now.subtract(Duration(minutes: (entry.key + 1) * 10)),
        relatedId: order.id,
      );
    });

    final activities = [...routeActivities, ...orderActivities].toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return activities.take(5).toList();
  }

  String _routeStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'IN_PROGRESS':
        return 'En progreso';
      case 'COMPLETED':
        return 'Completada';
      case 'PLANNED':
        return 'Planificada';
      default:
        return status;
    }
  }
}

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController(
    orderRepository: ref.watch(orderRepositoryProvider),
    routeRepository: ref.watch(routeRepositoryProvider),
  );
});
