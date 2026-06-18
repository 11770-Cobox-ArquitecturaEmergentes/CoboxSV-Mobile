import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:cobox_sv_mobile/features/notifications/domain/entities/notification_entity.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: colorScheme.error,
        child: Icon(Icons.delete_outline_rounded, color: colorScheme.onError),
      ),
      onDismissed: (_) => onDismiss?.call(),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _iconColor(colorScheme).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _notificationIcon,
                  size: 22,
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
                            notification.title,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight:
                                  notification.isRead ? FontWeight.w400 : FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(context),
                      style: textTheme.labelSmall?.copyWith(
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

  IconData get _notificationIcon {
    switch (notification.type) {
      case 'order':
      case 'order_status':
        return Icons.local_shipping_rounded;
      case 'route':
      case 'route_update':
        return Icons.route_rounded;
      case 'incident':
        return Icons.warning_amber_rounded;
      case 'system':
        return Icons.settings_rounded;
      case 'message':
        return Icons.chat_rounded;
      case 'document':
        return Icons.description_rounded;
      case 'payment':
        return Icons.payments_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _iconColor(ColorScheme colorScheme) {
    switch (notification.type) {
      case 'order':
      case 'order_status':
        return colorScheme.primary;
      case 'route':
      case 'route_update':
        return colorScheme.secondary;
      case 'incident':
        return colorScheme.error;
      case 'system':
        return colorScheme.tertiary;
      case 'message':
        return colorScheme.secondary;
      case 'document':
        return colorScheme.primary;
      case 'payment':
        return Colors.green;
      default:
        return colorScheme.primary;
    }
  }

  String _formatTime(BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(notification.createdAt);

    if (diff.inMinutes < 1) {
      return 'Ahora';
    } else if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} h';
    } else if (diff.inDays == 1) {
      return 'Ayer ${DateFormat('HH:mm').format(notification.createdAt)}';
    } else if (diff.inDays < 7) {
      final days = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return '${days[notification.createdAt.weekday]} ${DateFormat('HH:mm').format(notification.createdAt)}';
    } else {
      return DateFormat('dd/MM/yy HH:mm').format(notification.createdAt);
    }
  }
}
