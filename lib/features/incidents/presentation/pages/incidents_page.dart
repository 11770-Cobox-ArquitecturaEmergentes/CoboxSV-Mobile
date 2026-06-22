import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cobox_sv_mobile/app/colors.dart';
import 'package:cobox_sv_mobile/features/incidents/domain/entities/incident_entity.dart';
import 'package:cobox_sv_mobile/features/incidents/presentation/providers/incident_provider.dart';
import 'package:cobox_sv_mobile/features/orders/domain/entities/address_entity.dart';
import 'package:cobox_sv_mobile/shared/enums/incident_type.dart';

class IncidentsPage extends ConsumerStatefulWidget {
  const IncidentsPage({super.key});

  @override
  ConsumerState<IncidentsPage> createState() => _IncidentsPageState();
}

class _IncidentsPageState extends ConsumerState<IncidentsPage> {
  bool _showForm = false;
  IncidentType? _selectedType;
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(incidentsProvider.notifier).loadIncidents());
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedType == null ||
        _locationController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      return;
    }

    final created = await ref.read(incidentsProvider.notifier).createIncident(
          IncidentEntity(
            id: '0',
            type: _selectedType!,
            title: _titleForType(_selectedType!),
            description: _descriptionController.text.trim(),
            dateTime: DateTime.now(),
            location: AddressEntity(
              street: _locationController.text.trim(),
              city: 'Buenos Aires',
              state: 'CABA',
            ),
            severity: IncidentSeverity.medium,
            routeId: '201',
            reportedBy: 'Carlos',
          ),
        );

    if (created != null && mounted) {
      setState(() {
        _showForm = false;
        _selectedType = null;
        _locationController.clear();
        _descriptionController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(incidentsProvider);
    final notifier = ref.read(incidentsProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: const _DriverHeader(title: 'Incidentes'),
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_showForm)
                _ReportEntryCard(
                  onTap: () {
                    setState(() {
                      _showForm = true;
                    });
                  },
                )
              else
                _ReportFormCard(
                  selectedType: _selectedType,
                  locationController: _locationController,
                  descriptionController: _descriptionController,
                  onTypeChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                  onCancel: () {
                    setState(() {
                      _showForm = false;
                    });
                  },
                  onSubmit: _submit,
                ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Mis incidentes reportados',
                child: Column(
                  children: [
                    if (state.isLoading && state.incidents.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: LinearProgressIndicator(),
                      )
                    else if (state.incidents.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: _EmptyIncidents(),
                      )
                    else
                      for (var i = 0; i < state.incidents.length; i++) ...[
                        _IncidentListTile(incident: state.incidents[i]),
                        if (i != state.incidents.length - 1)
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _titleForType(IncidentType type) {
    return switch (type) {
      IncidentType.traffic => 'Accidente de transito',
      IncidentType.mechanicalFailure => 'Falla mecanica',
      IncidentType.delay => 'Retraso en ruta',
      IncidentType.accident => 'Accidente de transito',
      IncidentType.other => 'Otro',
      IncidentType.weather => 'Otro',
    };
  }
}

class _DriverHeader extends StatelessWidget implements PreferredSizeWidget {
  const _DriverHeader({required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(74);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      toolbarHeight: 74,
      elevation: 0,
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 66,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
        child: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            'C',
            style: textTheme.titleSmall?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'ABC-1234',
            style: textTheme.bodySmall?.copyWith(color: AppColors.gray500),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu_rounded),
          color: AppColors.gray700,
        ),
        const SizedBox(width: 8),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: Color(0xFFE5EAF1)),
      ),
    );
  }
}

class _ReportEntryCard extends StatelessWidget {
  const _ReportEntryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: _surfaceDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reportar incidente',
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Informa cualquier problema durante tu ruta',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Reportar nuevo incidente'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportFormCard extends StatelessWidget {
  const _ReportFormCard({
    required this.selectedType,
    required this.locationController,
    required this.descriptionController,
    required this.onTypeChanged,
    required this.onCancel,
    required this.onSubmit,
  });

  final IncidentType? selectedType;
  final TextEditingController locationController;
  final TextEditingController descriptionController;
  final ValueChanged<IncidentType?> onTypeChanged;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: _surfaceDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Reportar incidente',
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: onCancel,
                child: const Text('Cancelar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _FieldLabel(label: 'Tipo de incidente *'),
          const SizedBox(height: 8),
          DropdownButtonFormField<IncidentType>(
            value: selectedType,
            decoration: _inputDecoration(),
            hint: const Text('Selecciona un tipo'),
            items: const [
              DropdownMenuItem(
                value: IncidentType.traffic,
                child: Text('Accidente de transito'),
              ),
              DropdownMenuItem(
                value: IncidentType.mechanicalFailure,
                child: Text('Falla mecanica'),
              ),
              DropdownMenuItem(
                value: IncidentType.delay,
                child: Text('Retraso en ruta'),
              ),
              DropdownMenuItem(
                value: IncidentType.other,
                child: Text('Otro'),
              ),
            ],
            onChanged: onTypeChanged,
          ),
          const SizedBox(height: 14),
          _FieldLabel(label: 'Ubicacion *'),
          const SizedBox(height: 8),
          TextFormField(
            controller: locationController,
            decoration: _inputDecoration(
              hintText: 'Ej: Av. Cordoba 2450',
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                locationController.text = 'Av. Cordoba 2450';
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.text,
                side: const BorderSide(color: Color(0xFFD9E2EC)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.my_location_rounded, size: 18),
              label: const Text('Usar mi ubicacion actual'),
            ),
          ),
          const SizedBox(height: 14),
          _FieldLabel(label: 'Descripcion del incidente *'),
          const SizedBox(height: 8),
          TextFormField(
            controller: descriptionController,
            minLines: 3,
            maxLines: 3,
            decoration: _inputDecoration(
              hintText: 'Describe lo que sucedio...',
            ),
          ),
          const SizedBox(height: 14),
          _FieldLabel(label: 'Evidencia fotografica (opcional)'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFD9E2EC),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.photo_camera_outlined, size: 52, color: AppColors.gray500),
                const SizedBox(height: 12),
                Text(
                  'Toma fotos del incidente para adjuntar al reporte',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.gray500),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.photo_camera_outlined, size: 18),
                  label: const Text('Abrir camara'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Importante',
                        style: textTheme.titleSmall?.copyWith(
                          color: const Color(0xFFB45309),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Este reporte se enviara inmediatamente al centro de operaciones. En caso de emergencia, llama al numero de emergencias.',
                        style: textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFB45309),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.warning_amber_rounded, size: 18),
              label: const Text('Enviar reporte'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: _surfaceDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          child,
        ],
      ),
    );
  }
}

class _IncidentListTile extends StatelessWidget {
  const _IncidentListTile({required this.incident});

  final IncidentEntity incident;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'INC-2026-${incident.id.padLeft(3, '0')}',
                style: textTheme.titleLarge?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _IncidentStatusPill(status: incident.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            incident.title,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            incident.description,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.gray500),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.gray500),
              const SizedBox(width: 6),
              Text(
                _formatDate(incident.dateTime),
                style: textTheme.bodySmall?.copyWith(color: AppColors.gray500),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_rounded, size: 14, color: AppColors.gray500),
              const SizedBox(width: 6),
              Text(
                _formatTime(incident.dateTime),
                style: textTheme.bodySmall?.copyWith(color: AppColors.gray500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IncidentStatusPill extends StatelessWidget {
  const _IncidentStatusPill({required this.status});

  final IncidentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      IncidentStatus.resolved => ('Resuelto', const Color(0xFFE8F8EF), const Color(0xFF16A34A)),
      IncidentStatus.inProgress => ('En revision', const Color(0xFFFEF3C7), const Color(0xFFD97706)),
      IncidentStatus.open => ('Abierto', const Color(0xFFEAF2FF), const Color(0xFF2563EB)),
      IncidentStatus.closed => ('Cerrado', const Color(0xFFF1F5F9), const Color(0xFF64748B)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyIncidents extends StatelessWidget {
  const _EmptyIncidents();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.inbox_outlined, color: AppColors.gray500, size: 18),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'No hay incidentes reportados.',
            style: TextStyle(color: AppColors.gray500),
          ),
        ),
      ],
    );
  }
}

InputDecoration _inputDecoration({
  String? hintText,
  Widget? prefixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    prefixIcon: prefixIcon,
    filled: true,
    fillColor: AppColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD9E2EC)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
    ),
  );
}

BoxDecoration _surfaceDecoration() {
  return BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: const Color(0xFFD9E2EC)),
    boxShadow: [
      BoxShadow(
        color: AppColors.black.withValues(alpha: 0.04),
        blurRadius: 12,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

String _formatDate(DateTime dateTime) {
  final year = dateTime.year.toString().padLeft(4, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
