import 'package:json_annotation/json_annotation.dart';
import 'package:cobox_sv_mobile/features/orders/domain/entities/address_entity.dart';
import 'package:cobox_sv_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:cobox_sv_mobile/features/orders/data/models/order_item_model.dart';
import 'package:cobox_sv_mobile/shared/enums/order_status.dart';
import 'package:cobox_sv_mobile/shared/models/address_model.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel {
  final String id;
  final String? routeId;
  final String orderNumber;
  final String clientName;
  final String? clientPhone;
  final AddressModel deliveryAddress;
  final AddressModel? pickupAddress;
  final String status;
  final List<OrderItemModel> items;
  final DateTime? scheduledDate;
  final String? scheduledTimeWindow;
  final DateTime? actualDeliveryTime;
  final double? weight;
  final double? volume;
  final String? notes;
  final String? signature;
  final List<String>? photoUrls;

  const OrderModel({
    required this.id,
    this.routeId,
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
    this.photoUrls,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: (json['id'] ?? '').toString(),
      routeId: json['routeId']?.toString(),
      orderNumber: (json['orderNumber'] ?? json['id'] ?? '').toString(),
      clientName: 'Cliente ${(json['clientId'] ?? '').toString()}',
      clientPhone: json['clientPhone'] as String?,
      deliveryAddress: AddressModel(
        street: (json['addressLine'] ?? '').toString(),
        city: (json['city'] ?? '').toString(),
        state: (json['country'] ?? '').toString(),
        zipCode: json['postalCode']?.toString(),
        latitude: _doubleOrNull(json['referenceLatitude']),
        longitude: _doubleOrNull(json['referenceLongitude']),
      ),
      pickupAddress: null,
      status: _normalizeStatus((json['status'] ?? json['orderStatus'] ?? '').toString()),
      items: const [],
      scheduledDate: _dateOrNull(json['scheduledDate']),
      scheduledTimeWindow: json['scheduledTimeWindow']?.toString(),
      actualDeliveryTime: _dateOrNull(json['actualDeliveryTime']),
      weight: _doubleOrNull(json['weightKg'] ?? json['weight']),
      volume: _doubleOrNull(json['volume']),
      notes: json['notes']?.toString(),
      signature: json['signature']?.toString(),
      photoUrls: (json['photoUrls'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'routeId': routeId,
        'orderNumber': orderNumber,
        'clientName': clientName,
        'clientPhone': clientPhone,
        'deliveryAddress': deliveryAddress.toJson(),
        'pickupAddress': pickupAddress?.toJson(),
        'status': status,
        'items': items.map((item) => item.toJson()).toList(),
        'scheduledDate': scheduledDate?.toIso8601String(),
        'scheduledTimeWindow': scheduledTimeWindow,
        'actualDeliveryTime': actualDeliveryTime?.toIso8601String(),
        'weight': weight,
        'volume': volume,
        'notes': notes,
        'signature': signature,
        'photoUrls': photoUrls,
      };

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      routeId: routeId,
      orderNumber: orderNumber,
      clientName: clientName,
      clientPhone: clientPhone,
      deliveryAddress: AddressEntity(
        street: deliveryAddress.street,
        number: deliveryAddress.number,
        colony: deliveryAddress.colony,
        city: deliveryAddress.city,
        state: deliveryAddress.state,
        zipCode: deliveryAddress.zipCode,
        latitude: deliveryAddress.latitude,
        longitude: deliveryAddress.longitude,
      ),
      pickupAddress: pickupAddress != null
          ? AddressEntity(
              street: pickupAddress!.street,
              number: pickupAddress!.number,
              colony: pickupAddress!.colony,
              city: pickupAddress!.city,
              state: pickupAddress!.state,
              zipCode: pickupAddress!.zipCode,
              latitude: pickupAddress!.latitude,
              longitude: pickupAddress!.longitude,
            )
          : null,
      status: OrderStatus.fromValue(status),
      items: items.map((e) => e.toEntity()).toList(),
      scheduledDate: scheduledDate,
      scheduledTimeWindow: scheduledTimeWindow,
      actualDeliveryTime: actualDeliveryTime,
      weight: weight,
      volume: volume,
      notes: notes,
      signature: signature,
      photoUrls: photoUrls ?? [],
    );
  }

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      routeId: entity.routeId,
      orderNumber: entity.orderNumber,
      clientName: entity.clientName,
      clientPhone: entity.clientPhone,
      deliveryAddress: AddressModel(
        street: entity.deliveryAddress.street,
        number: entity.deliveryAddress.number,
        colony: entity.deliveryAddress.colony,
        city: entity.deliveryAddress.city,
        state: entity.deliveryAddress.state,
        zipCode: entity.deliveryAddress.zipCode,
        latitude: entity.deliveryAddress.latitude,
        longitude: entity.deliveryAddress.longitude,
      ),
      pickupAddress: entity.pickupAddress != null
          ? AddressModel(
              street: entity.pickupAddress!.street,
              number: entity.pickupAddress!.number,
              colony: entity.pickupAddress!.colony,
              city: entity.pickupAddress!.city,
              state: entity.pickupAddress!.state,
              zipCode: entity.pickupAddress!.zipCode,
              latitude: entity.pickupAddress!.latitude,
              longitude: entity.pickupAddress!.longitude,
            )
          : null,
      status: entity.status.value,
      items: entity.items.map((e) => OrderItemModel.fromEntity(e)).toList(),
      scheduledDate: entity.scheduledDate,
      scheduledTimeWindow: entity.scheduledTimeWindow,
      actualDeliveryTime: entity.actualDeliveryTime,
      weight: entity.weight,
      volume: entity.volume,
      notes: entity.notes,
      signature: entity.signature,
      photoUrls: entity.photoUrls.isNotEmpty ? entity.photoUrls : null,
    );
  }

  static String _normalizeStatus(String rawStatus) {
    switch (rawStatus.toUpperCase()) {
      case 'RECEIVED':
      case 'PROCESSING':
        return OrderStatus.pending.value;
      case 'READY_FOR_DISPATCH':
        return OrderStatus.assigned.value;
      case 'IN_TRANSIT':
        return OrderStatus.inProgress.value;
      case 'DELIVERED':
        return OrderStatus.completed.value;
      case 'CANCELLED':
        return OrderStatus.cancelled.value;
      default:
        return rawStatus.toLowerCase();
    }
  }

  static DateTime? _dateOrNull(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static double? _doubleOrNull(dynamic value) {
    if (value is num) return value.toDouble();
    return null;
  }
}
