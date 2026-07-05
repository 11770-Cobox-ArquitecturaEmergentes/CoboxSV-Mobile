import 'package:json_annotation/json_annotation.dart';

import 'package:cobox_sv_mobile/features/routes/data/models/stop_model.dart';
import 'package:cobox_sv_mobile/features/routes/domain/entities/route_entity.dart';

part 'route_model.g.dart';

@JsonSerializable()
class RouteModel {
  final String id;
  final String name;
  final String origin;
  final String destination;
  final List<StopModel> stops;
  final String status;
  @JsonKey(name: 'start_time')
  final DateTime? startTime;
  @JsonKey(name: 'estimated_end_time')
  final DateTime? estimatedEndTime;
  @JsonKey(name: 'actual_end_time')
  final DateTime? actualEndTime;
  final double distance;
  final int? duration;
  @JsonKey(name: 'order_ids')
  final List<String> orderIds;
  final String? notes;

  const RouteModel({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.stops,
    required this.status,
    this.startTime,
    this.estimatedEndTime,
    this.actualEndTime,
    required this.distance,
    this.duration,
    required this.orderIds,
    this.notes,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    final orderIds = _parseOrderIds(json['ordersIds']);
    final finishedOrderIds = _parseOrderIds(json['finishedOrderIds']).toSet();

    return RouteModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? 'Ruta').toString(),
      origin: json['origin']?.toString() ?? 'Centro logístico',
      destination: json['destination']?.toString() ?? 'Destino asignado',
      stops: orderIds.asMap().entries.map((entry) {
        final orderId = entry.value;
        final isCompleted = finishedOrderIds.contains(orderId);
        final isInProgress = !isCompleted &&
            (json['routeStatus']?.toString() == 'IN_PROGRESS') &&
            finishedOrderIds.length == entry.key;

        return StopModel(
          id: orderId,
          orderId: orderId,
          sequence: entry.key + 1,
          address: 'Pedido #$orderId',
          clientName: 'Cliente $orderId',
          status: isCompleted
              ? 'COMPLETED'
              : isInProgress
                  ? 'IN_PROGRESS'
                  : 'PENDING',
          notes: null,
        );
      }).toList(),
      status: (json['status'] ?? json['routeStatus'] ?? 'PLANNED').toString(),
      startTime: _dateFromJson(json['start_time'] ?? json['startTime']),
      estimatedEndTime: _dateFromJson(
        json['estimated_end_time'] ?? json['estimatedEndTime'],
      ),
      actualEndTime: _dateFromJson(
        json['actual_end_time'] ?? json['actualEndTime'],
      ),
      distance: _doubleFromJson(json['distance']),
      duration: _intFromJson(json['duration']),
      orderIds: orderIds,
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'origin': origin,
        'destination': destination,
        'stops': stops.map((stop) => stop.toJson()).toList(),
        'status': status,
        'start_time': startTime?.toIso8601String(),
        'estimated_end_time': estimatedEndTime?.toIso8601String(),
        'actual_end_time': actualEndTime?.toIso8601String(),
        'distance': distance,
        'duration': duration,
        'order_ids': orderIds,
        'notes': notes,
      };

  RouteEntity toEntity() {
    return RouteEntity(
      id: id,
      name: name,
      origin: origin,
      destination: destination,
      stops: stops.map((s) => s.toEntity()).toList(),
      status: status,
      startTime: startTime,
      estimatedEndTime: estimatedEndTime,
      actualEndTime: actualEndTime,
      distance: distance,
      duration: duration != null ? Duration(minutes: duration!) : null,
      orderIds: orderIds,
      notes: notes,
    );
  }

  factory RouteModel.fromEntity(RouteEntity entity) {
    return RouteModel(
      id: entity.id,
      name: entity.name,
      origin: entity.origin,
      destination: entity.destination,
      stops: entity.stops.map((s) => StopModel.fromEntity(s)).toList(),
      status: entity.status,
      startTime: entity.startTime,
      estimatedEndTime: entity.estimatedEndTime,
      actualEndTime: entity.actualEndTime,
      distance: entity.distance,
      duration: entity.duration?.inMinutes,
      orderIds: entity.orderIds,
      notes: entity.notes,
    );
  }

  static List<String> _parseOrderIds(dynamic value) {
    if (value is! List) return const [];
    return value.map((entry) {
      if (entry is Map<String, dynamic>) {
        return (entry['orderId'] ?? '').toString();
      }
      return entry.toString();
    }).where((id) => id.isNotEmpty).toList();
  }

  static DateTime? _dateFromJson(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static double _doubleFromJson(dynamic value) {
    if (value is num) return value.toDouble();
    return 0;
  }

  static int? _intFromJson(dynamic value) {
    if (value is num) return value.toInt();
    return null;
  }
}
