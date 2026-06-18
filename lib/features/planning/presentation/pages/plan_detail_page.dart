import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:cobox_sv_mobile/core/utils/formatter.dart';
import 'package:cobox_sv_mobile/core/widgets/error.dart';
import 'package:cobox_sv_mobile/features/planning/presentation/providers/planning_provider.dart';
import 'package:cobox_sv_mobile/features/planning/presentation/widgets/plan_card.dart';

class PlanDetailPage extends ConsumerWidget {
  final String id;

  const PlanDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(planDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Plan'),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(planDetailProvider(id)),
        ),
        data: (plan) {
          final colorScheme = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlanCard(plan: plan),
                const SizedBox(height: 24),
                Text(
                  'Información del Plan',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  label: 'Fecha',
                  value: DateFormat('dd/MM/yyyy').format(plan.date),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                _DetailRow(
                  label: 'Turno',
                  value: _shiftLabel(plan.shift),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                _DetailRow(
                  label: 'Estado',
                  value: plan.status,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                _DetailRow(
                  label: 'Paradas',
                  value: '${plan.stopsCount}',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                _DetailRow(
                  label: 'Distancia Total',
                  value: formatDistance(plan.totalDistance),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                _DetailRow(
                  label: 'Duración Estimada',
                  value: '${plan.estimatedDuration.inHours}h ${plan.estimatedDuration.inMinutes.remainder(60)}m',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                if (plan.routeIds.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Rutas Asociadas',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...plan.routeIds.map((routeId) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Chip(
                          label: Text('Ruta: $routeId'),
                          avatar: const Icon(Icons.route_outlined, size: 18),
                        ),
                      )),
                ],
                if (plan.notes != null && plan.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
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
                      plan.notes!,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _shiftLabel(String shift) {
    switch (shift.toUpperCase()) {
      case 'MORNING':
        return 'Matutino';
      case 'AFTERNOON':
        return 'Vespertino';
      case 'NIGHT':
        return 'Nocturno';
      default:
        return shift;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
