import 'package:cobox_sv_mobile/features/incidents/domain/entities/incident_entity.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/repository/incident_repository.dart';
import 'package:cobox_sv_mobile/features/orders/domain/entities/address_entity.dart';
import 'package:cobox_sv_mobile/shared/enums/incident_type.dart';

class MockIncidentRepositoryImpl implements IncidentRepository {
  MockIncidentRepositoryImpl();

  final List<IncidentEntity> _incidents = [
    IncidentEntity(
      id: '45',
      type: IncidentType.accident,
      title: 'Accidente menor',
      description: 'Colision menor en estacionamiento',
      dateTime: DateTime(2026, 6, 5, 14, 30),
      status: IncidentStatus.resolved,
      severity: IncidentSeverity.medium,
      location: const AddressEntity(
        street: 'Av. Cordoba',
        number: '2450',
        city: 'Buenos Aires',
        state: 'CABA',
      ),
      routeId: '201',
      reportedBy: 'Carlos',
      resolution: 'Resuelto',
    ),
    IncidentEntity(
      id: '38',
      type: IncidentType.delay,
      title: 'Retraso en ruta',
      description: 'Trafico intenso en Av. Libertador',
      dateTime: DateTime(2026, 6, 3, 10, 15),
      status: IncidentStatus.inProgress,
      severity: IncidentSeverity.low,
      location: const AddressEntity(
        street: 'Av. Libertador',
        city: 'Buenos Aires',
        state: 'CABA',
      ),
      routeId: '201',
      reportedBy: 'Carlos',
    ),
  ];

  @override
  Future<({List<IncidentEntity> incidents, int total})> getIncidents({
    int page = 1,
    int limit = 20,
    IncidentType? type,
    IncidentStatus? status,
    String? search,
  }) async {
    var filtered = _incidents;
    if (type != null) {
      filtered = filtered.where((item) => item.type == type).toList();
    }
    if (status != null) {
      filtered = filtered.where((item) => item.status == status).toList();
    }
    if (search != null && search.isNotEmpty) {
      final query = search.toLowerCase();
      filtered = filtered.where((item) {
        return item.title.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query);
      }).toList();
    }
    return (incidents: filtered.take(limit).toList(), total: filtered.length);
  }

  @override
  Future<IncidentEntity> createIncident(IncidentEntity incident) async {
    final created = IncidentEntity(
      id: '${_incidents.length + 50}',
      type: incident.type,
      title: incident.title,
      description: incident.description,
      status: IncidentStatus.open,
      severity: incident.severity,
      dateTime: DateTime(2026, 6, 18, 16, 45),
      location: incident.location,
      orderId: incident.orderId,
      routeId: incident.routeId,
      evidenceUrls: incident.evidenceUrls,
      reportedBy: incident.reportedBy,
    );
    _incidents.insert(0, created);
    return created;
  }

  @override
  Future<IncidentEntity> getIncidentDetail(String id) async {
    return _incidents.firstWhere((item) => item.id == id);
  }

  @override
  Future<List<String>> uploadEvidence(List<String> filePaths) async {
    return filePaths.map((path) => 'mock://$path').toList();
  }
}
