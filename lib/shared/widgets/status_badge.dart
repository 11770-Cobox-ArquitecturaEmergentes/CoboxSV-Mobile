import 'package:flutter/material.dart';
import 'package:cobox_sv_mobile/app/colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  factory StatusBadge.fromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pendiente':
      case 'pending':
        return StatusBadge(label: status, color: AppColors.statusPending);
      case 'en progreso':
      case 'in_progress':
      case 'in progress':
        return StatusBadge(label: status, color: AppColors.statusInProgress);
      case 'completado':
      case 'completed':
        return StatusBadge(label: status, color: AppColors.statusCompleted);
      case 'cancelado':
      case 'cancelled':
        return StatusBadge(label: status, color: AppColors.statusCancelled);
      default:
        return StatusBadge(label: status, color: AppColors.gray400);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
