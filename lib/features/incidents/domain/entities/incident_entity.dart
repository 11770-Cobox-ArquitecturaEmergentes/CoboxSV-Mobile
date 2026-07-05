import 'package:equatable/equatable.dart';
import 'package:cobox_sv_mobile/shared/enums/incident_type.dart';
import 'package:cobox_sv_mobile/features/orders/domain/entities/address_entity.dart';

class IncidentEntity extends Equatable {
  final String id;
  final IncidentType type;
  final String title;
  final String description;
  final IncidentStatus status;
  final IncidentSeverity severity;
  final DateTime dateTime;
  final AddressEntity? location;
  final String? orderId;
  final String? routeId;
  final List<String> evidenceUrls;
  final String? reportedBy;
  final DateTime? resolvedAt;
  final String? resolution;

  const IncidentEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.status = IncidentStatus.open,
    this.severity = IncidentSeverity.medium,
    required this.dateTime,
    this.location,
    this.orderId,
    this.routeId,
    this.evidenceUrls = const [],
    this.reportedBy,
    this.resolvedAt,
    this.resolution,
  });

  @override
  List<Object?> get props => [
    id, type, title, description, status, severity, dateTime,
    location, orderId, routeId, evidenceUrls, reportedBy,
    resolvedAt, resolution,
  ];
}

enum IncidentSeverity {
  low('Baja'),
  medium('Media'),
  high('Alta'),
  critical('Crítica');

  const IncidentSeverity(this.label);
  final String label;

  static IncidentSeverity fromValue(String value) {
    final normalized = value.toLowerCase();
    return IncidentSeverity.values.firstWhere(
      (s) => s.name == normalized,
      orElse: () => IncidentSeverity.medium,
    );
  }
}

enum IncidentStatus {
  open('Abierta'),
  inProgress('En Progreso'),
  escalated('Escalada'),
  resolved('Resuelta'),
  closed('Cerrada');

  const IncidentStatus(this.label);
  final String label;

  static IncidentStatus fromValue(String value) {
    final normalized = switch (value.toUpperCase()) {
      'IN_PROGRESS' => 'inProgress',
      'ESCALATED' => 'escalated',
      'RESOLVED' => 'resolved',
      'CLOSED' => 'closed',
      'OPEN' => 'open',
      _ => value,
    };
    return IncidentStatus.values.firstWhere(
      (s) => s.name == normalized || s.label == value,
      orElse: () => IncidentStatus.open,
    );
  }
}
