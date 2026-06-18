import 'package:json_annotation/json_annotation.dart';

import 'package:cobox_sv_mobile/features/routes/data/models/stop_model.dart';
import 'package:cobox_sv_mobile/features/routes/domain/entities/route_entity.dart';

part 'route_model.g.dart';

@JsonSerializable()
class RouteModel {
  final String id;
  final String name;
  final String origin;
  final String destination;
  final List<StopModel> stops;
  final String status;
  @JsonKey(name: 'start_time')
  final DateTime? startTime;
  @JsonKey(name: 'estimated_end_time')
  final DateTime? estimatedEndTime;
  @JsonKey(name: 'actual_end_time')
  final DateTime? actualEndTime;
  final double distance;
  final int? duration;
  @JsonKey(name: 'order_ids')
  final List<String> orderIds;
  final String? notes;

  const RouteModel({
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

  factory RouteModel.fromJson(Map<String, dynamic> json) => _$RouteModelFromJson(json);

  Map<String, dynamic> toJson() => _$RouteModelToJson(this);

  RouteEntity toEntity() {
    return RouteEntity(
      id: id,
      name: name,
      origin: origin,
      destination: destination,
      stops: stops.map((s) => s.toEntity()).toList(),
      status: status,
      startTime: startTime,
      estimatedEndTime: estimatedEndTime,
      actualEndTime: actualEndTime,
      distance: distance,
      duration: duration != null ? Duration(minutes: duration!) : null,
      orderIds: orderIds,
      notes: notes,
    );
  }

  factory RouteModel.fromEntity(RouteEntity entity) {
    return RouteModel(
      id: entity.id,
      name: entity.name,
      origin: entity.origin,
      destination: entity.destination,
      stops: entity.stops.map((s) => StopModel.fromEntity(s)).toList(),
      status: entity.status,
      startTime: entity.startTime,
      estimatedEndTime: entity.estimatedEndTime,
      actualEndTime: entity.actualEndTime,
      distance: entity.distance,
      duration: entity.duration?.inMinutes,
      orderIds: entity.orderIds,
      notes: entity.notes,
    );
  }
}
