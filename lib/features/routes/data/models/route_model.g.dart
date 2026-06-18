// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteModel _$RouteModelFromJson(Map<String, dynamic> json) => RouteModel(
  id: json['id'] as String,
  name: json['name'] as String,
  origin: json['origin'] as String,
  destination: json['destination'] as String,
  stops: (json['stops'] as List<dynamic>)
      .map((e) => StopModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  status: json['status'] as String,
  startTime: json['start_time'] == null
      ? null
      : DateTime.parse(json['start_time'] as String),
  estimatedEndTime: json['estimated_end_time'] == null
      ? null
      : DateTime.parse(json['estimated_end_time'] as String),
  actualEndTime: json['actual_end_time'] == null
      ? null
      : DateTime.parse(json['actual_end_time'] as String),
  distance: (json['distance'] as num).toDouble(),
  duration: (json['duration'] as num?)?.toInt(),
  orderIds: (json['order_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$RouteModelToJson(RouteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'origin': instance.origin,
      'destination': instance.destination,
      'stops': instance.stops,
      'status': instance.status,
      'start_time': instance.startTime?.toIso8601String(),
      'estimated_end_time': instance.estimatedEndTime?.toIso8601String(),
      'actual_end_time': instance.actualEndTime?.toIso8601String(),
      'distance': instance.distance,
      'duration': instance.duration,
      'order_ids': instance.orderIds,
      'notes': instance.notes,
    };
