import 'package:flutter/material.dart';

import 'package:cobox_sv_mobile/app/colors.dart';
import 'package:cobox_sv_mobile/shared/widgets/status_badge.dart';
import 'package:cobox_sv_mobile/shared/widgets/primary_button.dart';

class PlanningPage extends StatelessWidget {
  const PlanningPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planificación'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calendario', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
                  final dayNumbers = ['15', '16', '17', '18', '19', '20', '21'];
                  final isSelected = dayNumbers[index] == '15';

                  return Container(
                    width: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.gray200,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayNames[index],
                          style: textTheme.labelSmall?.copyWith(
                            color: isSelected ? AppColors.white : AppColors.gray500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dayNumbers[index],
                          style: textTheme.titleMedium?.copyWith(
                            color: isSelected ? AppColors.white : null,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text('Rutas Asignadas', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            _RouteCard(
              priority: 'Alta',
              priorityColor: AppColors.danger,
              title: 'Ruta Matutina',
              schedule: '08:00 - 12:00 | Conductor: Carlos',
              statusLabel: 'En curso',
              statusColor: AppColors.statusInProgress,
              distance: '45 km',
              stops: '8 paradas',
            ),
            const SizedBox(height: 12),
            _RouteCard(
              priority: 'Media',
              priorityColor: AppColors.warning,
              title: 'Ruta Vespertina',
              schedule: '14:00 - 18:00 | Conductor: Luis',
              statusLabel: 'Pendiente',
              statusColor: AppColors.statusPending,
              distance: '32 km',
              stops: '5 paradas',
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final String priority;
  final Color priorityColor;
  final String title;
  final String schedule;
  final String statusLabel;
  final Color statusColor;
  final String distance;
  final String stops;

  const _RouteCard({
    required this.priority,
    required this.priorityColor,
    required this.title,
    required this.schedule,
    required this.statusLabel,
    required this.statusColor,
    required this.distance,
    required this.stops,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      priority,
                      style: textTheme.labelSmall?.copyWith(
                        color: priorityColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      StatusBadge(label: statusLabel, color: statusColor),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              schedule,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.straighten,
                  label: distance,
                  textTheme: textTheme,
                ),
                const SizedBox(width: 16),
                _InfoChip(
                  icon: Icons.location_on_outlined,
                  label: stops,
                  textTheme: textTheme,
                ),
              ],
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Iniciar Ruta',
              fullWidth: true,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextTheme textTheme;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
