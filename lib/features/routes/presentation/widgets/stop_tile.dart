import 'package:flutter/material.dart';
import 'package:cobox_sv_mobile/features/routes/domain/entities/stop_entity.dart';

class StopTile extends StatelessWidget {
  final StopEntity stop;
  final bool isLast;
  final VoidCallback? onComplete;

  const StopTile({
    super.key,
    required this.stop,
    this.isLast = false,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isCompleted = stop.status == 'COMPLETED';
    final isInProgress = stop.status == 'IN_PROGRESS';
    final isPending = stop.status == 'PENDING';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? colorScheme.primary
                        : isInProgress
                            ? colorScheme.tertiary
                            : colorScheme.surfaceContainerHighest,
                    border: !isCompleted
                        ? Border.all(
                            color: isInProgress
                                ? colorScheme.tertiary
                                : colorScheme.outlineVariant,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: colorScheme.onPrimary,
                          )
                        : Text(
                            '${stop.sequence}',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isInProgress
                                  ? colorScheme.onTertiary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isInProgress
                    ? colorScheme.tertiaryContainer.withValues(alpha: 0.3)
                    : colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: isInProgress
                    ? Border.all(color: colorScheme.tertiary, width: 1.5)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          stop.clientName,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _StopStatusBadge(status: stop.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          stop.address,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (stop.scheduledTime != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Programado: ${stop.scheduledTime!.formattedTime()}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (isPending && onComplete != null) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: onComplete,
                        child: const Text('Completar Parada'),
                      ),
                    ),
                  ],
                  if (isCompleted && stop.actualArrivalTime != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Llegada: ${stop.actualArrivalTime!.formattedTime()}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StopStatusBadge extends StatelessWidget {
  final String status;

  const _StopStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _config(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        config.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
      ),
    );
  }

  _Config _config(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return _Config('Pendiente', Colors.orange);
      case 'IN_PROGRESS':
        return _Config('En Progreso', Colors.blue);
      case 'COMPLETED':
        return _Config('Completada', Colors.green);
      case 'SKIPPED':
        return _Config('Saltada', Colors.grey);
      default:
        return _Config(status, Colors.grey);
    }
  }
}

class _Config {
  final String label;
  final Color color;

  const _Config(this.label, this.color);
}

extension on DateTime {
  String formattedTime() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
