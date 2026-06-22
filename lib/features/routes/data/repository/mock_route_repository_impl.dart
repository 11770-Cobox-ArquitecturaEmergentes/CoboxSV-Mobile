import 'package:cobox_sv_mobile/features/routes/domain/entities/route_entity.dart';
import 'package:cobox_sv_mobile/features/routes/domain/entities/stop_entity.dart';
import 'package:cobox_sv_mobile/features/routes/domain/repository/route_repository.dart';

class MockRouteRepositoryImpl implements RouteRepository {
  MockRouteRepositoryImpl();

  final List<RouteEntity> _routes = [
    RouteEntity(
      id: '201',
      name: 'Ruta Rapida',
      origin: 'Base operativa',
      destination: 'Av. Cordoba',
      stops: [
        StopEntity(
          id: 'stop-1',
          orderId: '101',
          sequence: 1,
          address: 'Av. Libertador 1200',
          clientName: 'Cliente 1',
          status: 'COMPLETED',
          scheduledTime: DateTime(2026, 6, 18, 8, 30),
          actualArrivalTime: DateTime(2026, 6, 18, 8, 35),
        ),
        StopEntity(
          id: 'stop-2',
          orderId: '102',
          sequence: 2,
          address: 'Av. Cordoba 1450',
          clientName: 'Cliente 2',
          status: 'IN_PROGRESS',
          scheduledTime: DateTime(2026, 6, 18, 9, 10),
        ),
      ],
      status: 'IN_PROGRESS',
      startTime: DateTime(2026, 6, 18, 8, 24),
      estimatedEndTime: DateTime(2026, 6, 18, 8, 52),
      distance: 24.5,
      duration: const Duration(minutes: 28),
      orderIds: const ['101', '102'],
      notes: 'RouteResource compatible mock',
    ),
    RouteEntity(
      id: '202',
      name: 'Ruta Economica',
      origin: 'Base operativa',
      destination: 'Av. Rivadavia',
      stops: [
        StopEntity(
          id: 'stop-3',
          orderId: '103',
          sequence: 1,
          address: 'Av. Belgrano 330',
          clientName: 'Cliente 3',
          status: 'PENDING',
          scheduledTime: DateTime(2026, 6, 18, 10, 00),
        ),
      ],
      status: 'PENDING',
      estimatedEndTime: DateTime(2026, 6, 18, 10, 35),
      distance: 26.8,
      duration: const Duration(minutes: 35),
      orderIds: const ['103'],
      notes: 'Economical route',
    ),
    RouteEntity(
      id: '203',
      name: 'Autopista',
      origin: 'Base operativa',
      destination: 'Autopista Sur',
      stops: [
        StopEntity(
          id: 'stop-4',
          orderId: '104',
          sequence: 1,
          address: 'Autopista 25 de Mayo',
          clientName: 'Cliente 4',
          status: 'PENDING',
          scheduledTime: DateTime(2026, 6, 18, 11, 00),
        ),
      ],
      status: 'PENDING',
      estimatedEndTime: DateTime(2026, 6, 18, 11, 25),
      distance: 22.1,
      duration: const Duration(minutes: 25),
      orderIds: const ['104'],
      notes: 'High traffic and toll',
    ),
  ];

  @override
  Future<List<RouteEntity>> getRoutes({DateTime? date}) async {
    return _routes;
  }

  @override
  Future<RouteEntity> getRouteDetail(String id) async {
    return _routes.firstWhere((route) => route.id == id);
  }

  @override
  Future<RouteEntity> startRoute(String id) async {
    final route = _routes.firstWhere((item) => item.id == id);
    return route.copyWith(
      status: 'IN_PROGRESS',
      startTime: DateTime(2026, 6, 18, 8, 24),
    );
  }

  @override
  Future<RouteEntity> completeStop(String routeId, String stopId) async {
    final route = _routes.firstWhere((item) => item.id == routeId);
    final stops = route.stops
        .map(
          (stop) => stop.id == stopId
              ? stop.copyWith(
                  status: 'COMPLETED',
                  actualDepartureTime: DateTime(2026, 6, 18, 8, 50),
                )
              : stop,
        )
        .toList();
    return route.copyWith(stops: stops);
  }
}
