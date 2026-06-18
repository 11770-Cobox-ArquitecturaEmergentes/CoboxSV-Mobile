import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String id;
  final String name;
  final int quantity;
  final String? unit;
  final String? description;
  final double? weight;
  final double? volume;

  const OrderItemEntity({
    required this.id,
    required this.name,
    required this.quantity,
    this.unit,
    this.description,
    this.weight,
    this.volume,
  });

  @override
  List<Object?> get props => [
    id, name, quantity, unit, description, weight, volume,
  ];
}
