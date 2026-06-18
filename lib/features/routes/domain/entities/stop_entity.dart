import 'package:equatable/equatable.dart';

class StopEntity extends Equatable {
  final String id;
  final String? orderId;
  final int sequence;
  final String address;
  final String clientName;
  final String status;
  final DateTime? scheduledTime;
  final DateTime? actualArrivalTime;
  final DateTime? actualDepartureTime;
  final String? notes;

  const StopEntity({
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

  StopEntity copyWith({
    String? id,
    String? orderId,
    int? sequence,
    String? address,
    String? clientName,
    String? status,
    DateTime? scheduledTime,
    DateTime? actualArrivalTime,
    DateTime? actualDepartureTime,
    String? notes,
  }) {
    return StopEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      sequence: sequence ?? this.sequence,
      address: address ?? this.address,
      clientName: clientName ?? this.clientName,
      status: status ?? this.status,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      actualArrivalTime: actualArrivalTime ?? this.actualArrivalTime,
      actualDepartureTime: actualDepartureTime ?? this.actualDepartureTime,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        sequence,
        address,
        clientName,
        status,
        scheduledTime,
        actualArrivalTime,
        actualDepartureTime,
        notes,
      ];
}
