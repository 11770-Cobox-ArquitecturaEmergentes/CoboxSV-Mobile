import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
  });

  Color _bgColor(ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pendiente':
        return Colors.amber;
      case 'in_progress':
      case 'inprogress':
      case 'en_progreso':
      case 'en progreso':
        return Colors.blue;
      case 'completed':
      case 'completado':
      case 'completedo':
        return Colors.green;
      case 'cancelled':
      case 'cancelado':
        return Colors.red;
      default:
        return colorScheme.secondary;
    }
  }

  Color _textColor() {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pendiente':
        return const Color(0xFF78350F);
      case 'in_progress':
      case 'inprogress':
      case 'en_progreso':
      case 'en progreso':
        return const Color(0xFF1E3A5F);
      case 'completed':
      case 'completado':
      case 'completedo':
        return const Color(0xFF14532D);
      case 'cancelled':
      case 'cancelado':
        return const Color(0xFF7F1D1D);
      default:
        return Colors.white;
    }
  }

  String _label() {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pendiente':
        return 'Pendiente';
      case 'in_progress':
      case 'inprogress':
      case 'en_progreso':
      case 'en progreso':
        return 'En Progreso';
      case 'completed':
      case 'completado':
      case 'completedo':
        return 'Completado';
      case 'cancelled':
      case 'cancelado':
        return 'Cancelado';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = _bgColor(colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _label(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: _textColor(),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
