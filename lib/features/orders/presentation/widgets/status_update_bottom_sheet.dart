import 'package:flutter/material.dart';
import 'package:cobox_sv_mobile/core/utils/extensions.dart';
import 'package:cobox_sv_mobile/shared/enums/order_status.dart';

class StatusUpdateBottomSheet extends StatefulWidget {
  final OrderStatus currentStatus;
  final Function(OrderStatus status, String? notes) onConfirm;

  const StatusUpdateBottomSheet({
    super.key,
    required this.currentStatus,
    required this.onConfirm,
  });

  @override
  State<StatusUpdateBottomSheet> createState() => _StatusUpdateBottomSheetState();
}

class _StatusUpdateBottomSheetState extends State<StatusUpdateBottomSheet> {
  OrderStatus? _selectedStatus;
  final _notesController = TextEditingController();

  List<OrderStatus> get _availableStatuses {
    switch (widget.currentStatus) {
      case OrderStatus.pending:
        return [OrderStatus.assigned, OrderStatus.cancelled];
      case OrderStatus.assigned:
        return [OrderStatus.inProgress, OrderStatus.cancelled, OrderStatus.onHold];
      case OrderStatus.inProgress:
        return [OrderStatus.completed, OrderStatus.onHold, OrderStatus.cancelled];
      case OrderStatus.completed:
        return [OrderStatus.inProgress];
      case OrderStatus.cancelled:
        return [OrderStatus.pending];
      case OrderStatus.onHold:
        return [OrderStatus.inProgress, OrderStatus.cancelled];
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actualizar Estado',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Estado actual: ${widget.currentStatus.label}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nuevo estado',
              style: context.textTheme.titleSmall?.copyWith(
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ..._availableStatuses.map((status) => _StatusOption(
                  status: status,
                  isSelected: _selectedStatus == status,
                  onTap: () => setState(() => _selectedStatus = status),
                )),
            const SizedBox(height: 20),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Motivo del cambio de estado...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _selectedStatus != null
                  ? () {
                      widget.onConfirm(
                        _selectedStatus!,
                        _notesController.text.isNotEmpty
                            ? _notesController.text
                            : null,
                      );
                      Navigator.of(context).pop();
                    }
                  : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
              child: const Text('Actualizar Estado'),
            ),
          ],
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
