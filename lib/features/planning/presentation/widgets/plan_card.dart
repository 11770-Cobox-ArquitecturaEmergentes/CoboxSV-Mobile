import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:cobox_sv_mobile/core/utils/formatter.dart';
import 'package:cobox_sv_mobile/features/planning/domain/entities/plan_entity.dart';

class PlanCard extends StatelessWidget {
  final PlanEntity plan;
  final VoidCallback? onTap;

  const PlanCard({
    super.key,
    required this.plan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ShiftBadge(shift: plan.shift),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      plan.title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusChip(status: plan.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.location_on_outlined,
                    label: '${plan.stopsCount} paradas',
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 16),
                  _InfoChip(
                    icon: Icons.straighten_outlined,
                    label: formatDistance(plan.totalDistance),
                    colorScheme: colorScheme,
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('dd/MM').format(plan.date),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShiftBadge extends StatelessWidget {
  final String shift;

  const _ShiftBadge({required this.shift});

  @override
  Widget build(BuildContext context) {
    final config = _shiftConfig(shift);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: config.color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  _ShiftConfig _shiftConfig(String shift) {
    switch (shift.toUpperCase()) {
      case 'MORNING':
        return _ShiftConfig(
          Icons.wb_sunny,
          'Matutino',
          Colors.orange.shade600,
        );
      case 'AFTERNOON':
        return _ShiftConfig(
          Icons.wb_twilight,
          'Vespertino',
          Colors.deepOrange.shade400,
        );
      case 'NIGHT':
        return _ShiftConfig(
          Icons.nightlight_round,
          'Nocturno',
          Colors.indigo.shade400,
        );
      default:
        return _ShiftConfig(
          Icons.schedule,
          shift,
          Colors.grey,
        );
    }
  }
}

class _ShiftConfig {
  final IconData icon;
  final String label;
  final Color color;

  const _ShiftConfig(this.icon, this.label, this.color);
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        config.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  _StatusConfig _statusConfig(String status) {
    switch (status.toUpperCase()) {
      case 'IN_PROGRESS':
        return _StatusConfig('En progreso', Colors.green);
      case 'PLANNED':
        return _StatusConfig('Planificada', Colors.orange);
      case 'COMPLETED':
        return _StatusConfig('Completada', Colors.blue);
      case 'CANCELLED':
        return _StatusConfig('Cancelado', Colors.red);
      default:
        return _StatusConfig(status, Colors.grey);
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;

  const _StatusConfig(this.label, this.color);
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
