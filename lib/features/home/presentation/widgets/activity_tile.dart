import 'package:flutter/material.dart';

import 'package:cobox_sv_mobile/features/home/domain/entities/activity.dart';
import 'package:cobox_sv_mobile/features/home/presentation/widgets/status_badge.dart';

class ActivityTile extends StatelessWidget {
  final Activity activity;

  const ActivityTile({
    super.key,
    required this.activity,
  });

  IconData _icon() {
    switch (activity.type.toLowerCase()) {
      case 'order':
      case 'orden':
        return Icons.inventory_2_outlined;
      case 'route':
      case 'ruta':
        return Icons.route_outlined;
      case 'incident':
      case 'incidencia':
        return Icons.warning_amber_outlined;
      case 'system':
      case 'sistema':
        return Icons.settings_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  Color _iconColor(ColorScheme colorScheme) {
    switch (activity.type.toLowerCase()) {
      case 'order':
      case 'orden':
        return colorScheme.primary;
      case 'route':
      case 'ruta':
        return colorScheme.tertiary;
      case 'incident':
      case 'incidencia':
        return colorScheme.error;
      case 'system':
      case 'sistema':
        return colorScheme.secondary;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _timeAgo() {
    final now = DateTime.now();
    final diff = now.difference(activity.timestamp);

    if (diff.inSeconds < 60) return 'Ahora';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return 'Hace $m ${m == 1 ? 'min' : 'min'}';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return 'Hace $h ${h == 1 ? 'h' : 'h'}';
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return 'Hace $d ${d == 1 ? 'día' : 'días'}';
    }
    return '${activity.timestamp.day}/${activity.timestamp.month}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _iconColor(colorScheme).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _icon(),
                  size: 18,
                  color: _iconColor(colorScheme),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            activity.title,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: activity.status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activity.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _timeAgo(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
