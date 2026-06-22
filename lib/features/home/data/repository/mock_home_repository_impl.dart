import 'package:dartz/dartz.dart';

import 'package:cobox_sv_mobile/core/errors/failures.dart';
import 'package:cobox_sv_mobile/features/home/domain/entities/activity.dart';
import 'package:cobox_sv_mobile/features/home/domain/entities/dashboard.dart';
import 'package:cobox_sv_mobile/features/home/domain/repository/home_repository.dart';

class MockHomeRepositoryImpl implements HomeRepository {
  const MockHomeRepositoryImpl();

  @override
  Future<Either<Failure, Dashboard>> getDashboard() async {
    return const Right(
      Dashboard(
        totalOrders: 17,
        activeOrders: 5,
        completedOrders: 12,
        pendingOrders: 5,
        totalDistance: 145,
        totalFuel: 42.5,
        efficiency: 93.0,
        totalStops: 8,
        incidentsReported: 1,
        notificationsUnread: 3,
      ),
    );
  }

  @override
  Future<Either<Failure, List<Activity>>> getRecentActivity({int limit = 10}) async {
    final activities = [
      Activity(
        id: 'act-1',
        title: 'Entrega completada',
        description: 'Av. Belgrano 3200',
        type: 'order',
        status: 'completed',
        timestamp: DateTime(2026, 6, 18, 14, 30),
        relatedId: '101',
      ),
      Activity(
        id: 'act-2',
        title: 'En transito',
        description: 'Ruta hacia cliente',
        type: 'route',
        status: 'in_progress',
        timestamp: DateTime(2026, 6, 18, 13, 15),
        relatedId: '201',
      ),
      Activity(
        id: 'act-3',
        title: 'Recogida confirmada',
        description: 'Centro de distribucion',
        type: 'order',
        status: 'assigned',
        timestamp: DateTime(2026, 6, 18, 12, 00),
        relatedId: '102',
      ),
      Activity(
        id: 'act-4',
        title: 'Inicio de ruta',
        description: 'Base operativa',
        type: 'route',
        status: 'in_progress',
        timestamp: DateTime(2026, 6, 18, 11, 30),
        relatedId: '201',
      ),
    ];

    return Right(activities.take(limit).toList());
  }
}
