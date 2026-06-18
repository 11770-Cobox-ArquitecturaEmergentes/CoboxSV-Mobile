import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cobox_sv_mobile/core/widgets/empty.dart';
import 'package:cobox_sv_mobile/core/widgets/error.dart';
import 'package:cobox_sv_mobile/core/widgets/loading.dart';
import 'package:cobox_sv_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:cobox_sv_mobile/features/notifications/presentation/providers/notification_provider.dart';
import 'package:cobox_sv_mobile/features/notifications/presentation/widgets/notification_group.dart';
import 'package:cobox_sv_mobile/features/notifications/presentation/widgets/notification_tile.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (state.notifications.isNotEmpty)
            TextButton(
              onPressed: state.status == NotificationsStatus.loading
                  ? null
                  : _markAllRead,
              child: const Text('Leer todas'),
            ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(NotificationsState state) {
    switch (state.status) {
      case NotificationsStatus.initial:
        return const SizedBox.shrink();
      case NotificationsStatus.loading:
        return const LoadingWidget();
      case NotificationsStatus.error:
        return AppErrorWidget(
          message: state.error,
          onRetry: () => ref.read(notificationsProvider.notifier).loadNotifications(),
        );
      case NotificationsStatus.loaded:
        if (state.notifications.isEmpty) {
          return const EmptyWidget(state: EmptyState.noNotifications);
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(notificationsProvider.notifier).loadNotifications(),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: _buildGroups(state.notifications),
          ),
        );
    }
  }

  List<Widget> _buildGroups(List<NotificationEntity> notifications) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    final weekStart = todayStart.subtract(const Duration(days: 7));

    final today = <NotificationEntity>[];
    final yesterday = <NotificationEntity>[];
    final thisWeek = <NotificationEntity>[];
    final earlier = <NotificationEntity>[];

    for (final n in notifications) {
      if (n.createdAt.isAfter(todayStart)) {
        today.add(n);
      } else if (n.createdAt.isAfter(yesterdayStart)) {
        yesterday.add(n);
      } else if (n.createdAt.isAfter(weekStart)) {
        thisWeek.add(n);
      } else {
        earlier.add(n);
      }
    }

    final groups = <Widget>[];

    if (today.isNotEmpty) {
      groups.add(
        NotificationGroup(
          title: 'Hoy',
          children: today.map(_buildTile).toList(),
        ),
      );
    }
    if (yesterday.isNotEmpty) {
      groups.add(
        NotificationGroup(
          title: 'Ayer',
          children: yesterday.map(_buildTile).toList(),
        ),
      );
    }
    if (thisWeek.isNotEmpty) {
      groups.add(
        NotificationGroup(
          title: 'Esta semana',
          children: thisWeek.map(_buildTile).toList(),
        ),
      );
    }
    if (earlier.isNotEmpty) {
      groups.add(
        NotificationGroup(
          title: 'Anterior',
          children: earlier.map(_buildTile).toList(),
        ),
      );
    }

    return groups;
  }

  Widget _buildTile(NotificationEntity notification) {
    return NotificationTile(
      notification: notification,
      onTap: () => _onTapNotification(notification),
      onDismiss: () =>
          ref.read(notificationsProvider.notifier).removeNotification(notification.id),
    );
  }

  void _onTapNotification(NotificationEntity notification) {
    if (!notification.isRead) {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    }
  }

  Future<void> _markAllRead() async {
    await ref.read(notificationsProvider.notifier).markAllAsRead();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todas las notificaciones marcadas como leídas')),
      );
    }
  }
}
