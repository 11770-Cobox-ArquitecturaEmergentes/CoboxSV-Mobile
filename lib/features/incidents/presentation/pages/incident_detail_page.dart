import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cobox_sv_mobile/core/utils/extensions.dart';
import 'package:cobox_sv_mobile/core/utils/formatter.dart';
import 'package:cobox_sv_mobile/core/widgets/app_card.dart';
import 'package:cobox_sv_mobile/core/widgets/error.dart';
import 'package:cobox_sv_mobile/core/widgets/loading.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/entities/incident_entity.dart';
import 'package:cobox_sv_mobile/features/incidents/presentation/providers/incident_provider.dart';
import 'package:cobox_sv_mobile/features/incidents/presentation/widgets/evidence_grid.dart';

class IncidentDetailPage extends ConsumerStatefulWidget {
  final String id;

  const IncidentDetailPage({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<IncidentDetailPage> createState() => _IncidentDetailPageState();
}

class _IncidentDetailPageState extends ConsumerState<IncidentDetailPage> {
  IncidentEntity? _incident;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadIncident();
  }

  Future<void> _loadIncident() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final state = ref.read(incidentsProvider);
      final incident = state.incidents.where((i) => i.id == widget.id).firstOrNull;
      if (incident != null) {
        setState(() {
          _incident = incident;
          _isLoading = false;
        });
      } else {
        ref.read(incidentsProvider.notifier).loadIncidents().then((_) {
          final newState = ref.read(incidentsProvider);
          final found = newState.incidents.where((i) => i.id == widget.id).firstOrNull;
          setState(() {
            _incident = found;
            _isLoading = false;
            if (found == null) _error = 'Incidencia no encontrada.';
          });
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar la incidencia.';
        _isLoading = false;
      });
    }
  }

  void _openMap() {
    final loc = _incident!.location;
    if (loc == null) return;

    if (loc.latitude != null && loc.longitude != null) {
      final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${loc.latitude},${loc.longitude}',
      );
      launchUrl(uri);
    } else if (loc.fullAddress.isNotEmpty) {
      final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(loc.fullAddress)}',
      );
      launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_incident != null ? _incident!.title : 'Incidencia'),
      ),
      body: _buildBody(cs),
    );
  }

  Widget _buildBody(ColorScheme cs) {
    if (_isLoading) {
      return const LoadingWidget(message: 'Cargando incidencia...');
    }

    if (_error != null) {
      return AppErrorWidget(
        message: _error,
        onRetry: _loadIncident,
      );
    }

    if (_incident == null) {
      return const AppErrorWidget(message: 'Incidencia no encontrada');
    }

    final incident = _incident!;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusHeader(incident: incident, cs: cs),
          const SizedBox(height: 8),
          _DetailSection(
            title: 'Información',
            cs: cs,
            children: [
              _DetailRow(
                icon: incident.type.icon,
                label: 'Tipo',
                value: incident.type.label,
                cs: cs,
              ),
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.warning_amber_rounded,
                label: 'Severidad',
                value: incident.severity.label,
                valueColor: _severityColor(incident.severity),
                cs: cs,
              ),
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.flag_outlined,
                label: 'Estado',
                value: incident.status.label,
                valueColor: _statusColor(incident.status, cs),
                cs: cs,
              ),
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.access_time,
                label: 'Fecha',
                value: formatDateTime(incident.dateTime),
                cs: cs,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _DetailSection(
            title: 'Descripción',
            cs: cs,
            children: [
              Text(
                incident.description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
          if (incident.location != null) ...[
            const SizedBox(height: 8),
            _DetailSection(
              title: 'Ubicación',
              cs: cs,
              trailing: incident.location!.latitude != null
                  ? TextButton.icon(
                      onPressed: _openMap,
                      icon: const Icon(Icons.map_rounded, size: 18),
                      label: const Text('Ver mapa'),
                    )
                  : null,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined, size: 20, color: cs.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        incident.location!.fullAddress.isNotEmpty
                            ? incident.location!.fullAddress
                            : '${incident.location!.latitude?.toStringAsFixed(4) ?? ''}, '
                                '${incident.location!.longitude?.toStringAsFixed(4) ?? ''}',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
          if (incident.evidenceUrls.isNotEmpty) ...[
            const SizedBox(height: 8),
            _DetailSection(
              title: 'Evidencia Fotográfica',
              cs: cs,
              children: [
                EvidenceGrid(imageUrls: incident.evidenceUrls),
              ],
            ),
          ],
          if (incident.orderId != null || incident.routeId != null) ...[
            const SizedBox(height: 8),
            _DetailSection(
              title: 'Referencia',
              cs: cs,
              children: [
                if (incident.orderId != null)
                  _DetailRow(
                    icon: Icons.inventory_2_outlined,
                    label: 'Pedido',
                    value: incident.orderId!,
                    cs: cs,
                  ),
                if (incident.routeId != null) ...[
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.route_outlined,
                    label: 'Ruta',
                    value: incident.routeId!,
                    cs: cs,
                  ),
                ],
              ],
            ),
          ],
          if (incident.reportedBy != null) ...[
            const SizedBox(height: 8),
            _DetailSection(
              title: 'Reportado por',
              cs: cs,
              children: [
                Text(
                  incident.reportedBy!,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          if (incident.resolution != null) ...[
            const SizedBox(height: 8),
            _DetailSection(
              title: 'Resolución',
              cs: cs,
              children: [
                if (incident.resolvedAt != null)
                  _DetailRow(
                    icon: Icons.event,
                    label: 'Resuelto',
                    value: formatDateTime(incident.resolvedAt!),
                    cs: cs,
                  ),
                const SizedBox(height: 8),
                Text(
                  incident.resolution!,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _severityColor(IncidentSeverity severity) {
    switch (severity) {
      case IncidentSeverity.low:
        return Colors.green;
      case IncidentSeverity.medium:
        return Colors.orange;
      case IncidentSeverity.high:
        return Colors.deepOrange;
      case IncidentSeverity.critical:
        return Colors.red;
    }
  }

  Color _statusColor(IncidentStatus status, ColorScheme cs) {
    switch (status) {
      case IncidentStatus.open:
        return cs.error;
      case IncidentStatus.inProgress:
        return Colors.blue;
      case IncidentStatus.resolved:
        return Colors.green;
      case IncidentStatus.closed:
        return Colors.grey;
    }
  }
}

class _StatusHeader extends StatelessWidget {
  final IncidentEntity incident;
  final ColorScheme cs;

  const _StatusHeader({required this.incident, required this.cs});

  @override
  Widget build(BuildContext context) {
    final severityColor = _severityColor(incident.severity);

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              incident.type.icon,
              size: 32,
              color: severityColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  incident.title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: incident.status == IncidentStatus.open
                            ? cs.error.withValues(alpha: 0.12)
                            : Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        incident.status.label,
                        style: TextStyle(
                          color: incident.status == IncidentStatus.open
                              ? cs.error
                              : Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        incident.severity.label,
                        style: TextStyle(
                          color: severityColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _severityColor(IncidentSeverity severity) {
    switch (severity) {
      case IncidentSeverity.low:
        return Colors.green;
      case IncidentSeverity.medium:
        return Colors.orange;
      case IncidentSeverity.high:
        return Colors.deepOrange;
      case IncidentSeverity.critical:
        return Colors.red;
    }
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final ColorScheme cs;
  final List<Widget> children;
  final Widget? trailing;

  const _DetailSection({
    required this.title,
    required this.cs,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: context.textTheme.titleSmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final ColorScheme cs;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: context.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodySmall?.copyWith(
            color: valueColor ?? cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
