import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cobox_sv_mobile/app/colors.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/entities/incident_entity.dart';
import 'package:cobox_sv_mobile/shared/enums/incident_type.dart';
import 'package:cobox_sv_mobile/shared/widgets/status_badge.dart';

class IncidentsPage extends StatelessWidget {
  const IncidentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sampleIncidents = [
      IncidentEntity(
        id: '1',
        type: IncidentType.accident,
        title: 'Colisión leve en ruta 5',
        description: 'Impacto menor con vehículo particular en intersección.',
        dateTime: DateTime(2026, 6, 15, 14, 30),
        status: IncidentStatus.open,
        severity: IncidentSeverity.high,
      ),
      IncidentEntity(
        id: '2',
        type: IncidentType.mechanicalFailure,
        title: 'Falla en motor de arranque',
        description: 'El vehículo no enciende. Se requiere grúa para traslado al taller.',
        dateTime: DateTime(2026, 6, 16, 9, 15),
        status: IncidentStatus.inProgress,
        severity: IncidentSeverity.medium,
      ),
      IncidentEntity(
        id: '3',
        type: IncidentType.traffic,
        title: 'Congestión vehicular',
        description: 'Tráfico intenso por accidente en autopista. Retraso estimado de 45 min.',
        dateTime: DateTime(2026, 6, 17, 8, 0),
        status: IncidentStatus.resolved,
        severity: IncidentSeverity.low,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidencias'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SizedBox(
              width: 36,
              height: 36,
              child: FloatingActionButton.small(
                onPressed: () => context.push('/incidents/create'),
                child: const Icon(Icons.add, size: 20),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/incidents/create'),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: sampleIncidents.length,
        itemBuilder: (context, index) {
          final incident = sampleIncidents[index];
          return _IncidentCard(incident: incident);
        },
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final IncidentEntity incident;

  const _IncidentCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = _typeColor(incident.type);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(incident.type.icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.type.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      incident.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${incident.dateTime.day.toString().padLeft(2, '0')}/'
                      '${incident.dateTime.month.toString().padLeft(2, '0')}/'
                      '${incident.dateTime.year}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                label: incident.status.label,
                color: _badgeColor(incident.status),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _typeColor(IncidentType type) {
    switch (type) {
      case IncidentType.accident:
        return AppColors.danger;
      case IncidentType.mechanicalFailure:
        return AppColors.warning;
      case IncidentType.traffic:
        return AppColors.statusInProgress;
      case IncidentType.weather:
        return AppColors.secondary;
      case IncidentType.delay:
        return AppColors.warning;
      case IncidentType.other:
        return AppColors.textSecondary;
    }
  }

  Color _badgeColor(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.open:
        return AppColors.statusPending;
      case IncidentStatus.inProgress:
        return AppColors.statusInProgress;
      case IncidentStatus.resolved:
        return AppColors.statusCompleted;
      case IncidentStatus.closed:
        return AppColors.gray400;
    }
  }
}
