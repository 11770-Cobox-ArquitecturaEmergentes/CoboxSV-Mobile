// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleModel _$VehicleModelFromJson(Map<String, dynamic> json) => VehicleModel(
  id: json['id'] as String,
  plate: json['plate'] as String,
  brand: json['brand'] as String,
  model: json['model'] as String,
  year: (json['year'] as num).toInt(),
  type: json['type'] as String,
  color: json['color'] as String,
  capacity: (json['capacity'] as num).toDouble(),
  fuelType: json['fuel_type'] as String,
  lastMaintenance: json['last_maintenance'] == null
      ? null
      : DateTime.parse(json['last_maintenance'] as String),
  nextMaintenance: json['next_maintenance'] == null
      ? null
      : DateTime.parse(json['next_maintenance'] as String),
);

Map<String, dynamic> _$VehicleModelToJson(VehicleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plate': instance.plate,
      'brand': instance.brand,
      'model': instance.model,
      'year': instance.year,
      'type': instance.type,
      'color': instance.color,
      'capacity': instance.capacity,
      'fuel_type': instance.fuelType,
      'last_maintenance': instance.lastMaintenance?.toIso8601String(),
      'next_maintenance': instance.nextMaintenance?.toIso8601String(),
    };
