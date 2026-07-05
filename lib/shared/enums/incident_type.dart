import 'package:flutter/material.dart';

enum IncidentType {
  accident('Accidente', 'accident'),
  mechanicalFailure('Falla Mecánica', 'mechanical_failure'),
  traffic('Tráfico', 'traffic'),
  weather('Clima', 'weather'),
  delay('Retraso', 'delay'),
  other('Otro', 'other');

  const IncidentType(this.label, this.value);

  final String label;
  final String value;

  IconData get icon {
    switch (this) {
      case IncidentType.accident:
        return Icons.car_crash;
      case IncidentType.mechanicalFailure:
        return Icons.build;
      case IncidentType.traffic:
        return Icons.traffic;
      case IncidentType.weather:
        return Icons.wb_cloudy;
      case IncidentType.delay:
        return Icons.access_time;
      case IncidentType.other:
        return Icons.warning;
    }
  }

  static IncidentType fromValue(String value) {
    final normalized = value.toLowerCase();
    return IncidentType.values.firstWhere(
      (type) => type.value == normalized || type.name.toLowerCase() == normalized,
      orElse: () => IncidentType.other,
    );
  }
}
