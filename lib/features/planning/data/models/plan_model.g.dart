// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanModel _$PlanModelFromJson(Map<String, dynamic> json) => PlanModel(
  id: json['id'] as String,
  title: json['title'] as String,
  date: DateTime.parse(json['date'] as String),
  shift: json['shift'] as String,
  status: json['status'] as String,
  stopsCount: (json['stops_count'] as num).toInt(),
  totalDistance: (json['total_distance'] as num).toDouble(),
  estimatedDuration: (json['estimated_duration'] as num).toInt(),
  routeIds: (json['route_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$PlanModelToJson(PlanModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'date': instance.date.toIso8601String(),
  'shift': instance.shift,
  'status': instance.status,
  'stops_count': instance.stopsCount,
  'total_distance': instance.totalDistance,
  'estimated_duration': instance.estimatedDuration,
  'route_ids': instance.routeIds,
  'notes': instance.notes,
};
