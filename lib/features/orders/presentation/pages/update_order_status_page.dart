import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cobox_sv_mobile/core/utils/extensions.dart';
import 'package:cobox_sv_mobile/features/authentication/presentation/providers/auth_provider.dart';
import 'package:cobox_sv_mobile/features/evidence/data/models/evidence_models.dart';
import 'package:cobox_sv_mobile/features/evidence/presentation/providers/evidence_provider.dart';
import 'package:cobox_sv_mobile/features/evidence/presentation/widgets/evidence_capture_panel.dart';
import 'package:cobox_sv_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:cobox_sv_mobile/features/orders/presentation/providers/order_provider.dart';
import 'package:cobox_sv_mobile/shared/enums/order_status.dart';

class UpdateOrderStatusPage extends ConsumerStatefulWidget {
  final OrderEntity order;

  const UpdateOrderStatusPage({
    super.key,
    required this.order,
  });

  @override
  ConsumerState<UpdateOrderStatusPage> createState() => _UpdateOrderStatusPageState();
}

class _UpdateOrderStatusPageState extends ConsumerState<UpdateOrderStatusPage> {
  OrderStatus? _selectedStatus;
  final _notesController = TextEditingController();
  String? _signature;
  List<EvidenceDraft> _evidences = [];
  bool _isSubmitting = false;
  String? _submitError;

  List<OrderStatus> get _availableStatuses {
    switch (widget.order.status) {
      case OrderStatus.pending:
        return [OrderStatus.assigned];
      case OrderStatus.assigned:
        return [OrderStatus.inProgress];
      case OrderStatus.inProgress:
        return [OrderStatus.completed];
      case OrderStatus.completed:
        return const <OrderStatus>[];
      case OrderStatus.cancelled:
        return const <OrderStatus>[];
      case OrderStatus.onHold:
        return const <OrderStatus>[];
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedStatus == null) return;
    if (_selectedStatus == OrderStatus.completed && _evidences.isEmpty) {
      setState(() => _submitError = 'Agrega al menos una evidencia para completar la orden.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final routeId = int.tryParse(widget.order.routeId ?? '') ?? 0;
      var syncedEvidences = _evidences;

      if (_selectedStatus == OrderStatus.completed) {
        syncedEvidences = [];
        for (final evidence in _evidences) {
          final synced = await ref.read(evidenceWorkflowServiceProvider).uploadAndSync(
                draft: evidence,
                eventType: 'ORDER_DELIVERY_EVIDENCE',
                aggregateType: 'ORDER',
                aggregateId: widget.order.id,
                payload: {
                  'orderId': widget.order.id,
                  'routeId': routeId,
                  'status': _selectedStatus!.value,
                },
              );
          syncedEvidences.add(synced);
        }
        setState(() => _evidences = syncedEvidences);
      }

      final result = await ref.read(ordersProvider.notifier).updateStatus(
          id: widget.order.id,
          status: _selectedStatus!,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          signature: _signature,
          photoUrls: syncedEvidences
              .map((evidence) => evidence.objectKey)
              .whereType<String>()
              .toList(),
          routeId: routeId,
      );

      setState(() => _isSubmitting = false);

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado actualizado a ${_selectedStatus!.label}')),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      ref.read(evidenceSyncProvider.notifier).refreshPending();
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitError = 'No se pudo completar la evidencia. Quedo en cola para reintento.';
      });
    }
  }

  Future<int> _driverId() async {
    final user = await ref.read(authLocalDataSourceProvider).getUser();
    return int.tryParse(user?.id ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Actualizar Estado - ${widget.order.orderNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.order.status.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estado Actual',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.order.status.label,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: widget.order.status.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Selecciona el nuevo estado',
              style: context.textTheme.titleSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ..._availableStatuses.map((status) => _StatusOption(
                  status: status,
                  isSelected: _selectedStatus == status,
                  onTap: () => setState(() => _selectedStatus = status),
                )),
            const SizedBox(height: 24),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Notas',
                hintText: 'Agrega notas sobre el cambio de estado...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FutureBuilder<int>(
              future: _driverId(),
              builder: (context, snapshot) {
                final driverId = snapshot.data ?? 0;
                return EvidenceCapturePanel(
                  evidences: _evidences,
                  driverId: driverId,
                  orderId: int.tryParse(widget.order.id) ?? 0,
                  routeId: int.tryParse(widget.order.routeId ?? '') ?? 0,
                  type: 'DELIVERY_PHOTO',
                  maxItems: 3,
                  onChanged: (items) => setState(() => _evidences = items),
                );
              },
            ),
            if (_submitError != null) ...[
              const SizedBox(height: 12),
              Text(
                _submitError!,
                style: context.textTheme.bodySmall?.copyWith(color: cs.error),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _selectedStatus != null && !_isSubmitting ? _submit : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('Actualizar a ${_selectedStatus?.label ?? ''}'),
          ),
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final OrderStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusOption({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? status.color.withValues(alpha: 0.12)
            : cs.surfaceContainerHighest,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: status.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    status.label,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: status.color, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
