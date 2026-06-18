import 'package:flutter/material.dart';

enum OrderStatus {
  pending('Pendiente', 'pending'),
  assigned('Asignado', 'assigned'),
  inProgress('En Progreso', 'in_progress'),
  completed('Completado', 'completed'),
  cancelled('Cancelado', 'cancelled'),
  onHold('En Espera', 'on_hold');

  const OrderStatus(this.label, this.value);

  final String label;
  final String value;

  bool get isActive => this == pending || this == assigned || this == inProgress;

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.assigned:
        return Colors.blue;
      case OrderStatus.inProgress:
        return Colors.amber.shade700;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.onHold:
        return Colors.grey;
    }
  }

  static OrderStatus fromValue(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}
