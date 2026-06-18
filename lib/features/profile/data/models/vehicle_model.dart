import 'package:json_annotation/json_annotation.dart';

import 'package:cobox_sv_mobile/features/profile/domain/entities/vehicle_entity.dart';

part 'vehicle_model.g.dart';

@JsonSerializable()
class VehicleModel {
  final String id;
  final String plate;
  final String brand;
  final String model;
  final int year;
  final String type;
  final String color;
  final double capacity;
  @JsonKey(name: 'fuel_type')
  final String fuelType;
  @JsonKey(name: 'last_maintenance')
  final DateTime? lastMaintenance;
  @JsonKey(name: 'next_maintenance')
  final DateTime? nextMaintenance;

  const VehicleModel({
    required this.id,
    required this.plate,
    required this.brand,
    required this.model,
    required this.year,
    required this.type,
    required this.color,
    required this.capacity,
    required this.fuelType,
    this.lastMaintenance,
    this.nextMaintenance,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleModelToJson(this);

  VehicleEntity toEntity() {
    return VehicleEntity(
      id: id,
      plate: plate,
      brand: brand,
      model: model,
      year: year,
      type: type,
      color: color,
      capacity: capacity,
      fuelType: fuelType,
      lastMaintenance: lastMaintenance,
      nextMaintenance: nextMaintenance,
    );
  }

  factory VehicleModel.fromEntity(VehicleEntity entity) {
    return VehicleModel(
      id: entity.id,
      plate: entity.plate,
      brand: entity.brand,
      model: entity.model,
      year: entity.year,
      type: entity.type,
      color: entity.color,
      capacity: entity.capacity,
      fuelType: entity.fuelType,
      lastMaintenance: entity.lastMaintenance,
      nextMaintenance: entity.nextMaintenance,
    );
  }
}
