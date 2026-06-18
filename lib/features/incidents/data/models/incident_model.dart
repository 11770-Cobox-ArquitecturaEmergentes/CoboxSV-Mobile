import 'package:json_annotation/json_annotation.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/entities/incident_entity.dart';
import 'package:cobox_sv_mobile/features/orders/domain/entities/address_entity.dart';
import 'package:cobox_sv_mobile/shared/enums/incident_type.dart';
import 'package:cobox_sv_mobile/shared/models/address_model.dart';

part 'incident_model.g.dart';

@JsonSerializable()
class IncidentModel {
  final String id;
  final String type;
  final String title;
  final String description;
  final String status;
  final String severity;
  final DateTime dateTime;
  final AddressModel? location;
  final String? orderId;
  final String? routeId;
  final List<String>? evidenceUrls;
  final String? reportedBy;
  final DateTime? resolvedAt;
  final String? resolution;

  const IncidentModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.status = 'open',
    this.severity = 'medium',
    required this.dateTime,
    this.location,
    this.orderId,
    this.routeId,
    this.evidenceUrls,
    this.reportedBy,
    this.resolvedAt,
    this.resolution,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) => _$IncidentModelFromJson(json);

  Map<String, dynamic> toJson() => _$IncidentModelToJson(this);

  IncidentEntity toEntity() {
    return IncidentEntity(
      id: id,
      type: IncidentType.fromValue(type),
      title: title,
      description: description,
      status: IncidentStatus.fromValue(status),
      severity: IncidentSeverity.fromValue(severity),
      dateTime: dateTime,
      location: location != null
          ? AddressEntity(
              street: location!.street,
              number: location!.number,
              colony: location!.colony,
              city: location!.city,
              state: location!.state,
              zipCode: location!.zipCode,
              latitude: location!.latitude,
              longitude: location!.longitude,
            )
          : null,
      orderId: orderId,
      routeId: routeId,
      evidenceUrls: evidenceUrls ?? [],
      reportedBy: reportedBy,
      resolvedAt: resolvedAt,
      resolution: resolution,
    );
  }

  factory IncidentModel.fromEntity(IncidentEntity entity) {
    return IncidentModel(
      id: entity.id,
      type: entity.type.value,
      title: entity.title,
      description: entity.description,
      status: entity.status.name,
      severity: entity.severity.name,
      dateTime: entity.dateTime,
      location: entity.location != null
          ? AddressModel(
              street: entity.location!.street,
              number: entity.location!.number,
              colony: entity.location!.colony,
              city: entity.location!.city,
              state: entity.location!.state,
              zipCode: entity.location!.zipCode,
              latitude: entity.location!.latitude,
              longitude: entity.location!.longitude,
            )
          : null,
      orderId: entity.orderId,
      routeId: entity.routeId,
      evidenceUrls: entity.evidenceUrls.isNotEmpty ? entity.evidenceUrls : null,
      reportedBy: entity.reportedBy,
      resolvedAt: entity.resolvedAt,
      resolution: entity.resolution,
    );
  }
}
