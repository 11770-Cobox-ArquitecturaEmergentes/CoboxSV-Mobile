import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cobox_sv_mobile/core/utils/formatter.dart';
import 'package:cobox_sv_mobile/core/widgets/error.dart';
import 'package:cobox_sv_mobile/features/routes/domain/entities/route_entity.dart';
import 'package:cobox_sv_mobile/features/routes/presentation/providers/route_provider.dart';
import 'package:cobox_sv_mobile/features/routes/presentation/widgets/route_card.dart';
import 'package:cobox_sv_mobile/features/routes/presentation/widgets/stop_tile.dart';

class RouteDetailPage extends ConsumerWidget {
  final String id;

  const RouteDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(routeDetailProvider(id));
    final notifier = ref.watch(routeNotifierProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Ruta $id'),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(routeDetailProvider(id)),
        ),
        data: (route) {
          final textTheme = Theme.of(context).textTheme;
          final canStart = route.status == 'PLANNED';

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(routeDetailProvider(id));
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RouteCard(
                    route: route,
                    prominent: route.status == 'IN_PROGRESS',
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _ProgressSection(route: route),
                  ),
                  const SizedBox(height: 16),
                  if (canStart)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: notifier.isLoading
                              ? null
                              : () => _startRoute(context, ref, route),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Iniciar Ruta'),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Paradas (${route.stops.length})',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildStopsList(context, route, ref),
                  ),
                  const SizedBox(height: 16),
                  if (route.notes != null && route.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _NotesSection(notes: route.notes!),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStopsList(BuildContext context, RouteEntity route, WidgetRef ref) {
    return Column(
      children: route.stops.map((stop) {
        final isLast = route.stops.last.id == stop.id;
        final isPending = stop.status == 'PENDING';
        return StopTile(
          stop: stop,
          isLast: isLast,
          onComplete: isPending
              ? () => _completeStop(context, ref, route.id, stop.id)
              : null,
        );
      }).toList(),
    );
  }

  Future<void> _startRoute(BuildContext context, WidgetRef ref, RouteEntity route) async {
    try {
      await ref.read(routeNotifierProvider(route.id).notifier).startRoute(route.id);
      ref.invalidate(routeDetailProvider(route.id));
      ref.invalidate(routesProvider(DateTime.now()));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ruta iniciada exitosamente')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _completeStop(
      BuildContext context, WidgetRef ref, String routeId, String stopId) async {
    try {
      await ref.read(routeNotifierProvider(routeId).notifier).completeStop(routeId, stopId);
      ref.invalidate(routeDetailProvider(routeId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parada completada')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _ProgressSection extends StatelessWidget {
  final RouteEntity route;

  const _ProgressSection({required this.route});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progreso',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${route.completedStops}/${route.stops.length} paradas',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: route.progress,
                minHeight: 10,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _ProgressMetric(
                  icon: Icons.location_on_outlined,
                  label: 'Origen',
                  value: route.origin,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(width: 16),
                _ProgressMetric(
                  icon: Icons.flag_outlined,
                  label: 'Destino',
                  value: route.destination,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ProgressMetric(
                  icon: Icons.straighten_outlined,
                  label: 'Distancia',
                  value: formatDistance(route.distance),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(width: 16),
                if (route.duration != null)
                  _ProgressMetric(
                    icon: Icons.timer_outlined,
                    label: 'Duración',
                    value: '${route.duration!.inHours}h ${route.duration!.inMinutes.remainder(60)}m',
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ProgressMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  final String notes;

  const _NotesSection({required this.notes});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notas',
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            notes,
            style: textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
