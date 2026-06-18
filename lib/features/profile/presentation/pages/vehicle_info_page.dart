import 'package:flutter/material.dart';

import 'package:cobox_sv_mobile/features/profile/domain/entities/vehicle_entity.dart';

class VehicleInfoPage extends StatelessWidget {
  final VehicleEntity vehicle;

  const VehicleInfoPage({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información del Vehículo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Datos Generales',
            Icons.info_outline_rounded,
            [
              _buildInfoRow(context, 'Placa', vehicle.plate),
              _buildInfoRow(context, 'Marca', vehicle.brand),
              _buildInfoRow(context, 'Modelo', vehicle.model),
              _buildInfoRow(context, 'Año', vehicle.year.toString()),
              _buildInfoRow(context, 'Tipo', _vehicleTypeLabel(vehicle.type)),
              _buildInfoRow(context, 'Color', vehicle.color),
            ],
          ),
          const SizedBox(height: 12),
          _buildSection(
            context,
            'Especificaciones',
            Icons.settings_outlined,
            [
              _buildInfoRow(
                context,
                'Capacidad de carga',
                '${vehicle.capacity} kg',
              ),
              _buildInfoRow(
                context,
                'Tipo de combustible',
                _fuelTypeLabel(vehicle.fuelType),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSection(
            context,
            'Mantenimiento',
            Icons.build_outlined,
            [
              _buildInfoRow(
                context,
                'Último mantenimiento',
                vehicle.lastMaintenance != null
                    ? _formatDate(vehicle.lastMaintenance!)
                    : 'Sin registro',
              ),
              _buildInfoRow(
                context,
                'Próximo mantenimiento',
                vehicle.nextMaintenance != null
                    ? _formatDate(vehicle.nextMaintenance!)
                    : 'No programado',
              ),
              if (vehicle.nextMaintenance != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _buildMaintenanceStatus(
                    context,
                    vehicle.nextMaintenance!,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSection(
            context,
            'Documentos',
            Icons.description_outlined,
            [
              _buildDocStatus(context, 'Tarjeta de circulación', true),
              _buildDocStatus(context, 'Seguro vigente', true),
              _buildDocStatus(context, 'Verificación', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.local_shipping_rounded,
                size: 40,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicle.brand} ${vehicle.model}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicle.plate,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vehicle.year.toString(),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceStatus(BuildContext context, DateTime next) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final daysLeft = next.difference(DateTime.now()).inDays;

    Color statusColor;
    String statusText;
    if (daysLeft < 0) {
      statusColor = colorScheme.error;
      statusText = 'Vencido hace ${-daysLeft} días';
    } else if (daysLeft <= 7) {
      statusColor = colorScheme.error;
      statusText = 'Vence en $daysLeft días';
    } else if (daysLeft <= 30) {
      statusColor = colorScheme.tertiary;
      statusText = 'Vence en $daysLeft días';
    } else {
      statusColor = colorScheme.primary;
      statusText = 'Vence en $daysLeft días';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.event_rounded, size: 18, color: statusColor),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocStatus(BuildContext context, String doc, bool isValid) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle_rounded : Icons.cancel_outlined,
            size: 20,
            color: isValid ? colorScheme.primary : colorScheme.error,
          ),
          const SizedBox(width: 10),
          Text(
            doc,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isValid
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isValid ? 'Vigente' : 'Vencido',
              style: textTheme.labelSmall?.copyWith(
                color: isValid ? colorScheme.primary : colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _vehicleTypeLabel(String type) {
    switch (type) {
      case 'TRUCK':
        return 'Camión';
      case 'VAN':
        return 'Camioneta';
      case 'TRAILER':
        return 'Tráiler';
      case 'PICKUP':
        return 'Pickup';
      case 'MOTORCYCLE':
        return 'Motocicleta';
      default:
        return type;
    }
  }

  String _fuelTypeLabel(String fuelType) {
    switch (fuelType) {
      case 'GASOLINE':
        return 'Gasolina';
      case 'DIESEL':
        return 'Diésel';
      case 'ELECTRIC':
        return 'Eléctrico';
      case 'HYBRID':
        return 'Híbrido';
      case 'GAS':
        return 'Gas';
      default:
        return fuelType;
    }
  }
}
