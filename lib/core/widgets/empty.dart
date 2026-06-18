import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum EmptyState {
  noData,
  noResults,
  noNotifications,
  noOrders,
  noIncidents,
}

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    required this.state,
    this.lottieAsset,
    this.icon,
    this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  final EmptyState state;
  final String? lottieAsset;
  final IconData? icon;
  final String? title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final config = _config(state);
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (lottieAsset != null)
              SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset(
                  lottieAsset!,
                  fit: BoxFit.contain,
                ),
              )
            else
              Icon(
                icon ?? config.icon,
                size: 80,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            const SizedBox(height: 24),
            Text(
              title ?? config.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (description != null || config.description != null) ...[
              const SizedBox(height: 8),
              Text(
                description ?? config.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _EmptyConfig _config(EmptyState state) {
    switch (state) {
      case EmptyState.noData:
        return _EmptyConfig(
          icon: Icons.inbox_outlined,
          title: 'Sin datos',
          description: 'No hay información disponible en este momento.',
        );
      case EmptyState.noResults:
        return _EmptyConfig(
          icon: Icons.search_off_rounded,
          title: 'Sin resultados',
          description: 'No se encontraron resultados para tu búsqueda.',
        );
      case EmptyState.noNotifications:
        return _EmptyConfig(
          icon: Icons.notifications_none_rounded,
          title: 'Sin notificaciones',
          description: 'No tienes notificaciones pendientes.',
        );
      case EmptyState.noOrders:
        return _EmptyConfig(
          icon: Icons.local_shipping_outlined,
          title: 'Sin pedidos',
          description: 'No hay pedidos asignados.',
        );
      case EmptyState.noIncidents:
        return _EmptyConfig(
          icon: Icons.check_circle_outline_rounded,
          title: 'Sin incidencias',
          description: 'No se han reportado incidencias.',
        );
    }
  }
}

class _EmptyConfig {
  const _EmptyConfig({
    required this.icon,
    required this.title,
    this.description,
  });

  final IconData icon;
  final String title;
  final String? description;
}
