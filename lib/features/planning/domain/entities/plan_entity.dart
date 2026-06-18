import 'package:equatable/equatable.dart';

class PlanEntity extends Equatable {
  final String id;
  final String title;
  final DateTime date;
  final String shift;
  final String status;
  final int stopsCount;
  final double totalDistance;
  final Duration estimatedDuration;
  final List<String> routeIds;
  final String? notes;

  const PlanEntity({
    required this.id,
    required this.title,
    required this.date,
    required this.shift,
    required this.status,
    required this.stopsCount,
    required this.totalDistance,
    required this.estimatedDuration,
    required this.routeIds,
    this.notes,
  });

  PlanEntity copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? shift,
    String? status,
    int? stopsCount,
    double? totalDistance,
    Duration? estimatedDuration,
    List<String>? routeIds,
    String? notes,
  }) {
    return PlanEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      shift: shift ?? this.shift,
      status: status ?? this.status,
      stopsCount: stopsCount ?? this.stopsCount,
      totalDistance: totalDistance ?? this.totalDistance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      routeIds: routeIds ?? this.routeIds,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        date,
        shift,
        status,
        stopsCount,
        totalDistance,
        estimatedDuration,
        routeIds,
        notes,
      ];
}
