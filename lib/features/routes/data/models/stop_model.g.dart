// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StopModel _$StopModelFromJson(Map<String, dynamic> json) => StopModel(
  id: json['id'] as String,
  orderId: json['order_id'] as String?,
  sequence: (json['sequence'] as num).toInt(),
  address: json['address'] as String,
  clientName: json['client_name'] as String,
  status: json['status'] as String,
  scheduledTime: json['scheduled_time'] == null
      ? null
      : DateTime.parse(json['scheduled_time'] as String),
  actualArrivalTime: json['actual_arrival_time'] == null
      ? null
      : DateTime.parse(json['actual_arrival_time'] as String),
  actualDepartureTime: json['actual_departure_time'] == null
      ? null
      : DateTime.parse(json['actual_departure_time'] as String),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$StopModelToJson(StopModel instance) => <String, dynamic>{
  'id': instance.id,
  'order_id': instance.orderId,
  'sequence': instance.sequence,
  'address': instance.address,
  'client_name': instance.clientName,
  'status': instance.status,
  'scheduled_time': instance.scheduledTime?.toIso8601String(),
  'actual_arrival_time': instance.actualArrivalTime?.toIso8601String(),
  'actual_departure_time': instance.actualDepartureTime?.toIso8601String(),
  'notes': instance.notes,
};
