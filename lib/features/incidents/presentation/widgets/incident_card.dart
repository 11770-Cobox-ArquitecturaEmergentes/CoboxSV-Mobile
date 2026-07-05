import 'package:flutter/material.dart';
import 'package:cobox_sv_mobile/core/utils/extensions.dart';
import 'package:cobox_sv_mobile/core/utils/formatter.dart';
import 'package:cobox_sv_mobile/core/widgets/app_card.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/entities/incident_entity.dart';

class IncidentCard extends StatelessWidget {
  final IncidentEntity incident;
  final VoidCallback? onTap;

  const IncidentCard({
    super.key,
    required this.incident,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final severityColor = _severityColor(incident.severity, cs);
    final statusColor = _statusColor(incident.status, cs);

    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  incident.type.icon,
                  size: 20,
                  color: cs.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      incident.type.label,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _SeverityBadge(severity: incident.severity, color: severityColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            incident.description,
            style: context.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                formatDateTime(incident.dateTime),
                style: context.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  incident.status.label,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _severityColor(IncidentSeverity severity, ColorScheme cs) {
    switch (severity) {
      case IncidentSeverity.low:
        return Colors.green;
      case IncidentSeverity.medium:
        return Colors.orange;
      case IncidentSeverity.high:
        return Colors.deepOrange;
      case IncidentSeverity.critical:
        return cs.error;
    }
  }

  Color _statusColor(IncidentStatus status, ColorScheme cs) {
    switch (status) {
      case IncidentStatus.open:
        return cs.error;
      case IncidentStatus.inProgress:
        return Colors.blue;
      case IncidentStatus.escalated:
        return Colors.deepOrange;
      case IncidentStatus.resolved:
        return Colors.green;
      case IncidentStatus.closed:
        return Colors.grey;
    }
  }
}

class _SeverityBadge extends StatelessWidget {
  final IncidentSeverity severity;
  final Color color;

  const _SeverityBadge({required this.severity, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        severity.label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
