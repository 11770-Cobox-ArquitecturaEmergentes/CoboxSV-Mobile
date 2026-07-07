import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cobox_sv_mobile/core/utils/extensions.dart';
import 'package:cobox_sv_mobile/features/evidence/data/models/evidence_models.dart';
import 'package:cobox_sv_mobile/features/evidence/presentation/providers/evidence_provider.dart';

class EvidenceCapturePanel extends ConsumerWidget {
  const EvidenceCapturePanel({
    super.key,
    required this.evidences,
    required this.driverId,
    required this.orderId,
    required this.routeId,
    required this.type,
    required this.onChanged,
    this.maxItems = 3,
    this.title = 'Evidencia fotografica',
  });

  final List<EvidenceDraft> evidences;
  final int driverId;
  final int orderId;
  final int routeId;
  final String type;
  final ValueChanged<List<EvidenceDraft>> onChanged;
  final int maxItems;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.colorScheme;
    final canAdd = evidences.length < maxItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.titleSmall?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...evidences.map((draft) {
              return _EvidenceTile(
                draft: draft,
                onRemove: () => onChanged(
                  evidences
                      .where((item) => item.clientEvidenceId != draft.clientEvidenceId)
                      .toList(),
                ),
              );
            }),
            if (canAdd)
              _AddEvidenceTile(
                onTap: () => _showSourcePicker(context, ref),
              ),
          ],
        ),
      ],
    );
  }

  void _showSourcePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camara'),
              onTap: () {
                Navigator.pop(context);
                _capture(context, ref, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                _capture(context, ref, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _capture(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    final draft = await ref.read(evidenceCaptureServiceProvider).captureImage(
          source: source,
          driverId: driverId,
          orderId: orderId,
          routeId: routeId,
          type: type,
        );
    if (draft == null) return;
    onChanged([...evidences, draft]);
  }
}

class _EvidenceTile extends StatelessWidget {
  const _EvidenceTile({
    required this.draft,
    required this.onRemove,
  });

  final EvidenceDraft draft;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return SizedBox(
      width: 104,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(draft.filePath),
                  width: 104,
                  height: 104,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 104,
                    height: 104,
                    color: cs.surfaceContainerHighest,
                    child: Icon(Icons.broken_image_outlined, color: cs.onSurfaceVariant),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _EvidenceStatusChip(status: draft.status),
        ],
      ),
    );
  }
}

class _AddEvidenceTile extends StatelessWidget {
  const _AddEvidenceTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, color: cs.onSurfaceVariant),
              const SizedBox(height: 4),
              Text(
                'Agregar',
                style: context.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EvidenceStatusChip extends StatelessWidget {
  const _EvidenceStatusChip({required this.status});

  final EvidenceStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      EvidenceStatus.captured => ('Pendiente', Colors.blueGrey),
      EvidenceStatus.intentCreated => ('Preparada', Colors.indigo),
      EvidenceStatus.uploaded => ('Subida', Colors.blue),
      EvidenceStatus.confirmed => ('Confirmada', Colors.teal),
      EvidenceStatus.synced => ('Sincronizada', Colors.green),
      EvidenceStatus.failed => ('Fallida', Colors.red),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
