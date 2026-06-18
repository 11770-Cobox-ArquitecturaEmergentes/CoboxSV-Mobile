import 'package:flutter/material.dart';

import 'package:cobox_sv_mobile/features/home/domain/entities/dashboard.dart';
import 'package:cobox_sv_mobile/features/home/presentation/widgets/dashboard_card.dart';

class StatisticsGrid extends StatelessWidget {
  final Dashboard dashboard;

  const StatisticsGrid({
    super.key,
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spacing = 12.0;
          final itemWidth = (constraints.maxWidth - spacing) / 2;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              SizedBox(
                width: itemWidth,
                child: DashboardCard(
                  icon: Icons.inventory_2_rounded,
                  label: 'Pedidos Activos',
                  value: dashboard.activeOrders.toString(),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(
                width: itemWidth,
                child: DashboardCard(
                  icon: Icons.route_rounded,
                  label: 'Rutas Hoy',
                  value: dashboard.totalStops.toString(),
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              SizedBox(
                width: itemWidth,
                child: DashboardCard(
                  icon: Icons.warning_amber_rounded,
                  label: 'Incidencias',
                  value: dashboard.incidentsReported.toString(),
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              SizedBox(
                width: itemWidth,
                child: DashboardCard(
                  icon: Icons.speed_rounded,
                  label: 'Eficiencia',
                  value: '${dashboard.efficiency.toStringAsFixed(1)}%',
                  color: Colors.green,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
