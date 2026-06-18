// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IncidentModel _$IncidentModelFromJson(Map<String, dynamic> json) =>
    IncidentModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String? ?? 'open',
      severity: json['severity'] as String? ?? 'medium',
      dateTime: DateTime.parse(json['dateTime'] as String),
      location: json['location'] == null
          ? null
          : AddressModel.fromJson(json['location'] as Map<String, dynamic>),
      orderId: json['orderId'] as String?,
      routeId: json['routeId'] as String?,
      evidenceUrls: (json['evidenceUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      reportedBy: json['reportedBy'] as String?,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      resolution: json['resolution'] as String?,
    );

Map<String, dynamic> _$IncidentModelToJson(IncidentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'status': instance.status,
      'severity': instance.severity,
      'dateTime': instance.dateTime.toIso8601String(),
      'location': instance.location,
      'orderId': instance.orderId,
      'routeId': instance.routeId,
      'evidenceUrls': instance.evidenceUrls,
      'reportedBy': instance.reportedBy,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'resolution': instance.resolution,
    };
