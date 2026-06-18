import 'package:json_annotation/json_annotation.dart';

import 'package:cobox_sv_mobile/features/routes/domain/entities/stop_entity.dart';

part 'stop_model.g.dart';

@JsonSerializable()
class StopModel {
  final String id;
  @JsonKey(name: 'order_id')
  final String? orderId;
  final int sequence;
  final String address;
  @JsonKey(name: 'client_name')
  final String clientName;
  final String status;
  @JsonKey(name: 'scheduled_time')
  final DateTime? scheduledTime;
  @JsonKey(name: 'actual_arrival_time')
  final DateTime? actualArrivalTime;
  @JsonKey(name: 'actual_departure_time')
  final DateTime? actualDepartureTime;
  final String? notes;

  const StopModel({
    required this.id,
    this.orderId,
    required this.sequence,
    required this.address,
    required this.clientName,
    required this.status,
    this.scheduledTime,
    this.actualArrivalTime,
    this.actualDepartureTime,
    this.notes,
  });

  factory StopModel.fromJson(Map<String, dynamic> json) => _$StopModelFromJson(json);

  Map<String, dynamic> toJson() => _$StopModelToJson(this);

  StopEntity toEntity() {
    return StopEntity(
      id: id,
      orderId: orderId,
      sequence: sequence,
      address: address,
      clientName: clientName,
      status: status,
      scheduledTime: scheduledTime,
      actualArrivalTime: actualArrivalTime,
      actualDepartureTime: actualDepartureTime,
      notes: notes,
    );
  }

  factory StopModel.fromEntity(StopEntity entity) {
    return StopModel(
      id: entity.id,
      orderId: entity.orderId,
      sequence: entity.sequence,
      address: entity.address,
      clientName: entity.clientName,
      status: entity.status,
      scheduledTime: entity.scheduledTime,
      actualArrivalTime: entity.actualArrivalTime,
      actualDepartureTime: entity.actualDepartureTime,
      notes: entity.notes,
    );
  }
}
