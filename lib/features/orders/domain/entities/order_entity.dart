import 'package:equatable/equatable.dart';
import 'package:cobox_sv_mobile/shared/enums/order_status.dart';
import 'package:cobox_sv_mobile/features/orders/domain/entities/address_entity.dart';
import 'package:cobox_sv_mobile/features/orders/domain/entities/order_item_entity.dart';

class OrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final String clientName;
  final String? clientPhone;
  final AddressEntity deliveryAddress;
  final AddressEntity? pickupAddress;
  final OrderStatus status;
  final List<OrderItemEntity> items;
  final DateTime? scheduledDate;
  final String? scheduledTimeWindow;
  final DateTime? actualDeliveryTime;
  final double? weight;
  final double? volume;
  final String? notes;
  final String? signature;
  final List<String> photoUrls;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.clientName,
    this.clientPhone,
    required this.deliveryAddress,
    this.pickupAddress,
    required this.status,
    this.items = const [],
    this.scheduledDate,
    this.scheduledTimeWindow,
    this.actualDeliveryTime,
    this.weight,
    this.volume,
    this.notes,
    this.signature,
    this.photoUrls = const [],
  });

  @override
  List<Object?> get props => [
    id, orderNumber, clientName, clientPhone, deliveryAddress,
    pickupAddress, status, items, scheduledDate, scheduledTimeWindow,
    actualDeliveryTime, weight, volume, notes, signature, photoUrls,
  ];
}
