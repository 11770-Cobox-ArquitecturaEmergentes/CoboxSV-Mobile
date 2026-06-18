import 'package:flutter/material.dart';

import 'package:cobox_sv_mobile/core/utils/formatter.dart';
import 'package:cobox_sv_mobile/features/routes/domain/entities/route_entity.dart';

class RouteCard extends StatelessWidget {
  final RouteEntity route;
  final bool prominent;
  final VoidCallback? onTap;

  const RouteCard({
    super.key,
    required this.route,
    this.prominent = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: prominent ? 8 : 6,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: prominent
              ? BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.primary,
                      width: 3,
                    ),
                  ),
                )
              : null,
          child: Padding(
            padding: EdgeInsets.all(prominent ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (prominent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Ruta Activa',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (prominent) const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        route.name,
                        style: (prominent ? textTheme.titleMedium : textTheme.titleSmall)
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _StatusIndicator(status: route.status, prominent: prominent),
                  ],
                ),
                SizedBox(height: prominent ? 16 : 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${route.origin} → ${route.destination}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Metric(
                      icon: Icons.location_on_outlined,
                      label: '${route.stops.length} paradas',
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(width: 16),
                    _Metric(
                      icon: Icons.straighten_outlined,
                      label: formatDistance(route.distance),
                      colorScheme: colorScheme,
                    ),
                    const Spacer(),
                    if (route.completedStops > 0)
                      Text(
                        '${route.completedStops}/${route.stops.length}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                if (route.stops.isNotEmpty) ...[
                  SizedBox(height: prominent ? 12 : 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: route.progress,
                      minHeight: prominent ? 8 : 4,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String status;
  final bool prominent;

  const _StatusIndicator({required this.status, this.prominent = false});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: prominent ? 16 : 14,
            color: config.color,
          ),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: config.color,
                  fontWeight: FontWeight.w600,
                  fontSize: prominent ? 12 : 11,
                ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _statusConfig(String status) {
    switch (status.toUpperCase()) {
      case 'PLANNED':
        return _StatusConfig(Icons.schedule, 'Planificada', Colors.orange);
      case 'IN_PROGRESS':
        return _StatusConfig(Icons.play_circle_filled, 'En Progreso', Colors.blue);
      case 'COMPLETED':
        return _StatusConfig(Icons.check_circle, 'Completada', Colors.green);
      case 'CANCELLED':
        return _StatusConfig(Icons.cancel, 'Cancelada', Colors.red);
      default:
        return _StatusConfig(Icons.help, status, Colors.grey);
    }
  }
}

class _StatusConfig {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusConfig(this.icon, this.label, this.color);
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  const _Metric({
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
