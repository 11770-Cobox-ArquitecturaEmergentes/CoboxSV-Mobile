import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cobox_sv_mobile/app/providers.dart';
import 'package:cobox_sv_mobile/core/utils/responsive_layout.dart';
import 'package:cobox_sv_mobile/core/widgets/app_textfield.dart';
import 'package:cobox_sv_mobile/features/authentication/presentation/providers/auth_provider.dart';
import 'package:cobox_sv_mobile/features/evidence/data/models/evidence_models.dart';
import 'package:cobox_sv_mobile/features/evidence/presentation/providers/evidence_provider.dart';
import 'package:cobox_sv_mobile/features/evidence/presentation/widgets/evidence_capture_panel.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/entities/incident_entity.dart';
import 'package:cobox_sv_mobile/features/incidents/presentation/providers/incident_provider.dart';
import 'package:cobox_sv_mobile/shared/enums/incident_type.dart';
import 'package:cobox_sv_mobile/shared/widgets/primary_button.dart';

class CreateIncidentPage extends ConsumerStatefulWidget {
  const CreateIncidentPage({super.key});

  @override
  ConsumerState<CreateIncidentPage> createState() => _CreateIncidentPageState();
}

class _CreateIncidentPageState extends ConsumerState<CreateIncidentPage> {
  IncidentType _type = IncidentType.other;
  final _descriptionController = TextEditingController();
  List<EvidenceDraft> _evidences = [];
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      setState(() => _error = 'Describe los detalles de la incidencia.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final driverId = await _driverId();
    final incident = IncidentEntity(
      id: '',
      type: _type,
      title: _type.label,
      description: description,
      severity: IncidentSeverity.medium,
      dateTime: DateTime.now(),
      reportedBy: driverId.toString(),
    );

    try {
      final hasConnection = await ref.read(networkInfoProvider).checkConnectivity();
      if (!hasConnection) {
        await ref.read(incidentsProvider.notifier).queuePendingReport(
              incident: incident,
              evidences: _evidences,
              lastError: 'Sin conexion',
            );
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incidencia guardada. Se enviara al volver la conexion.'),
          ),
        );
        Navigator.of(context).pop();
        return;
      }

      final created = await ref.read(incidentsProvider.notifier).createIncident(incident);
      if (created == null) {
        await ref.read(incidentsProvider.notifier).queuePendingReport(
              incident: incident,
              evidences: _evidences,
              lastError: ref.read(incidentsProvider).error ?? 'Envio no confirmado',
            );
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incidencia guardada. Se enviara al volver la conexion.'),
          ),
        );
        Navigator.of(context).pop();
        return;
      }

      final synced = <EvidenceDraft>[];
      for (final evidence in _evidences) {
        try {
          synced.add(await ref.read(evidenceWorkflowServiceProvider).uploadAndSync(
                draft: evidence,
                eventType: 'INCIDENT_EVIDENCE',
                aggregateType: 'INCIDENT',
                aggregateId: created.id,
                payload: {
                  'incidentId': created.id,
                  'type': _type.value,
                  'description': description,
                },
              ));
        } catch (_) {
          synced.add(evidence.copyWith(
            status: EvidenceStatus.failed,
            syncEventType: 'INCIDENT_EVIDENCE',
            syncAggregateType: 'INCIDENT',
            syncAggregateId: created.id,
            syncPayload: {
              'incidentId': created.id,
              'type': _type.value,
              'description': description,
            },
          ));
        }
      }

      setState(() {
        _evidences = synced;
        _isSubmitting = false;
      });

      if (!mounted) return;
      final hasPendingEvidence = synced.any((item) => item.status == EvidenceStatus.failed);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasPendingEvidence
                ? 'Incidencia reportada. Algunas evidencias quedaron en cola.'
                : 'Incidencia reportada',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (error) {
      final syncNotifier = ref.read(evidenceSyncProvider.notifier);
      syncNotifier.refreshPending();
      final queuedIds = ref
          .read(evidenceSyncProvider)
          .pending
          .map((item) => item.clientEvidenceId)
          .toSet();
      for (final evidence in _evidences) {
        if (!queuedIds.contains(evidence.clientEvidenceId)) {
          await syncNotifier.queue(evidence.copyWith(
            status: EvidenceStatus.failed,
            lastError: error.toString(),
          ));
        }
      }
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = 'No se pudo reportar la incidencia. Revisa tu conexion e intenta nuevamente.';
      });
    }
  }

  Future<int> _driverId() async {
    final user = await ref.read(authLocalDataSourceProvider).getUser();
    return int.tryParse(user?.id ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Incidencia'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = adaptivePagePadding(constraints.maxWidth);

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipo de Incidencia',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: IncidentType.values.map((type) {
                    final isSelected = _type == type;
                    return ChoiceChip(
                      selected: isSelected,
                      showCheckmark: false,
                      backgroundColor: cs.surface,
                      selectedColor: cs.primaryContainer,
                      side: BorderSide(
                        color: isSelected ? cs.primary : cs.outlineVariant,
                      ),
                      labelStyle: theme.textTheme.labelLarge?.copyWith(
                        color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type.icon,
                            size: 18,
                            color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                          ),
                          const SizedBox(width: 6),
                          Text(type.label),
                        ],
                      ),
                      onSelected: (_) => setState(() => _type = type),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                AppTextfield(
                  controller: _descriptionController,
                  label: 'Descripcion',
                  hint: 'Describe los detalles de la incidencia...',
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                FutureBuilder<int>(
                  future: _driverId(),
                  builder: (context, snapshot) {
                    return EvidenceCapturePanel(
                      evidences: _evidences,
                      driverId: snapshot.data ?? 0,
                      orderId: 0,
                      routeId: 0,
                      type: 'INCIDENT_PHOTO',
                      maxItems: 3,
                      onChanged: (items) => setState(() => _evidences = items),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.my_location, color: cs.primary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ubicacion actual',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _locationLabel(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Fecha',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
                  ),
                  const SizedBox(height: 12),
                ],
                PrimaryButton(
                  label: 'Reportar Incidencia',
                  fullWidth: true,
                  loading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _submit,
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  String _locationLabel() {
    if (_evidences.isEmpty ||
        _evidences.first.latitude == null ||
        _evidences.first.longitude == null) {
      return 'Se capturara al adjuntar evidencia';
    }
    return '${_evidences.first.latitude}, ${_evidences.first.longitude}';
  }
}
