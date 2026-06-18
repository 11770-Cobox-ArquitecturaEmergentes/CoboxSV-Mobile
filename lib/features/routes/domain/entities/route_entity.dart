import 'package:equatable/equatable.dart';

import 'package:cobox_sv_mobile/features/routes/domain/entities/stop_entity.dart';

class RouteEntity extends Equatable {
  final String id;
  final String name;
  final String origin;
  final String destination;
  final List<StopEntity> stops;
  final String status;
  final DateTime? startTime;
  final DateTime? estimatedEndTime;
  final DateTime? actualEndTime;
  final double distance;
  final Duration? duration;
  final List<String> orderIds;
  final String? notes;

  const RouteEntity({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.stops,
    required this.status,
    this.startTime,
    this.estimatedEndTime,
    this.actualEndTime,
    required this.distance,
    this.duration,
    required this.orderIds,
    this.notes,
  });

  int get completedStops => stops.where((s) => s.status == 'COMPLETED').length;

  double get progress => stops.isEmpty ? 0 : completedStops / stops.length;

  RouteEntity copyWith({
    String? id,
    String? name,
    String? origin,
    String? destination,
    List<StopEntity>? stops,
    String? status,
    DateTime? startTime,
    DateTime? estimatedEndTime,
    DateTime? actualEndTime,
    double? distance,
    Duration? duration,
    List<String>? orderIds,
    String? notes,
  }) {
    return RouteEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      stops: stops ?? this.stops,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      estimatedEndTime: estimatedEndTime ?? this.estimatedEndTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      orderIds: orderIds ?? this.orderIds,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        origin,
        destination,
        stops,
        status,
        startTime,
        estimatedEndTime,
        actualEndTime,
        distance,
        duration,
        orderIds,
        notes,
      ];
}
