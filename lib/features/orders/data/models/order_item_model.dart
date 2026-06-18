import 'package:json_annotation/json_annotation.dart';
import 'package:cobox_sv_mobile/features/orders/domain/entities/order_item_entity.dart';

part 'order_item_model.g.dart';

@JsonSerializable()
class OrderItemModel {
  final String id;
  final String name;
  final int quantity;
  final String? unit;
  final String? description;
  final double? weight;
  final double? volume;

  const OrderItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    this.unit,
    this.description,
    this.weight,
    this.volume,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  OrderItemEntity toEntity() => OrderItemEntity(
    id: id,
    name: name,
    quantity: quantity,
    unit: unit,
    description: description,
    weight: weight,
    volume: volume,
  );

  factory OrderItemModel.fromEntity(OrderItemEntity entity) => OrderItemModel(
    id: entity.id,
    name: entity.name,
    quantity: entity.quantity,
    unit: entity.unit,
    description: entity.description,
    weight: entity.weight,
    volume: entity.volume,
  );
}
