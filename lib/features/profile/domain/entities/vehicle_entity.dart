import 'package:equatable/equatable.dart';

class VehicleEntity extends Equatable {
  final String id;
  final String plate;
  final String brand;
  final String model;
  final int year;
  final String type;
  final String color;
  final double capacity;
  final String fuelType;
  final DateTime? lastMaintenance;
  final DateTime? nextMaintenance;

  const VehicleEntity({
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

  @override
  List<Object?> get props => [
        id,
        plate,
        brand,
        model,
        year,
        type,
        color,
        capacity,
        fuelType,
        lastMaintenance,
        nextMaintenance,
      ];
}
