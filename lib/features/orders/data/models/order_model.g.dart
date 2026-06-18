// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: json['id'] as String,
  orderNumber: json['orderNumber'] as String,
  clientName: json['clientName'] as String,
  clientPhone: json['clientPhone'] as String?,
  deliveryAddress: AddressModel.fromJson(
    json['deliveryAddress'] as Map<String, dynamic>,
  ),
  pickupAddress: json['pickupAddress'] == null
      ? null
      : AddressModel.fromJson(json['pickupAddress'] as Map<String, dynamic>),
  status: json['status'] as String,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  scheduledDate: json['scheduledDate'] == null
      ? null
      : DateTime.parse(json['scheduledDate'] as String),
  scheduledTimeWindow: json['scheduledTimeWindow'] as String?,
  actualDeliveryTime: json['actualDeliveryTime'] == null
      ? null
      : DateTime.parse(json['actualDeliveryTime'] as String),
  weight: (json['weight'] as num?)?.toDouble(),
  volume: (json['volume'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
  signature: json['signature'] as String?,
  photoUrls: (json['photoUrls'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'clientName': instance.clientName,
      'clientPhone': instance.clientPhone,
      'deliveryAddress': instance.deliveryAddress,
      'pickupAddress': instance.pickupAddress,
      'status': instance.status,
      'items': instance.items,
      'scheduledDate': instance.scheduledDate?.toIso8601String(),
      'scheduledTimeWindow': instance.scheduledTimeWindow,
      'actualDeliveryTime': instance.actualDeliveryTime?.toIso8601String(),
      'weight': instance.weight,
      'volume': instance.volume,
      'notes': instance.notes,
      'signature': instance.signature,
      'photoUrls': instance.photoUrls,
    };
