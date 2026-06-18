import 'package:json_annotation/json_annotation.dart';

import 'package:cobox_sv_mobile/features/planning/domain/entities/plan_entity.dart';

part 'plan_model.g.dart';

@JsonSerializable()
class PlanModel {
  final String id;
  final String title;
  final DateTime date;
  final String shift;
  final String status;
  @JsonKey(name: 'stops_count')
  final int stopsCount;
  @JsonKey(name: 'total_distance')
  final double totalDistance;
  @JsonKey(name: 'estimated_duration')
  final int estimatedDuration;
  @JsonKey(name: 'route_ids')
  final List<String> routeIds;
  final String? notes;

  const PlanModel({
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

  factory PlanModel.fromJson(Map<String, dynamic> json) => _$PlanModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlanModelToJson(this);

  PlanEntity toEntity() {
    return PlanEntity(
      id: id,
      title: title,
      date: date,
      shift: shift,
      status: status,
      stopsCount: stopsCount,
      totalDistance: totalDistance,
      estimatedDuration: Duration(minutes: estimatedDuration),
      routeIds: routeIds,
      notes: notes,
    );
  }

  factory PlanModel.fromEntity(PlanEntity entity) {
    return PlanModel(
      id: entity.id,
      title: entity.title,
      date: entity.date,
      shift: entity.shift,
      status: entity.status,
      stopsCount: entity.stopsCount,
      totalDistance: entity.totalDistance,
      estimatedDuration: entity.estimatedDuration.inMinutes,
      routeIds: entity.routeIds,
      notes: entity.notes,
    );
  }
}
