import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cobox_sv_mobile/core/utils/extensions.dart';
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
  final List<String> _photoUrls = [];
  bool _isSubmitting = false;

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

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.camera);
    if (xFile != null) {
      setState(() => _photoUrls.add(xFile.path));
    }
  }

  Future<void> _submit() async {
    if (_selectedStatus == null) return;

    setState(() => _isSubmitting = true);
    final result = await ref.read(ordersProvider.notifier).updateStatus(
          id: widget.order.id,
          status: _selectedStatus!,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          signature: _signature,
          photoUrls: _photoUrls.isNotEmpty ? _photoUrls : null,
        );

    setState(() => _isSubmitting = false);

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado actualizado a ${_selectedStatus!.label}')),
      );
      context.pop();
    }
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
            Text(
              'Evidencia Fotográfica',
              style: context.textTheme.titleSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._photoUrls.map((url) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(url),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => setState(() => _photoUrls.remove(url)),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  Material(
                    borderRadius: BorderRadius.circular(8),
                    color: cs.surfaceContainerHighest,
                    child: InkWell(
                      onTap: _pickPhoto,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: cs.outline.withValues(alpha: 0.5),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              color: cs.onSurfaceVariant,
                              size: 28,
                            ),
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
                  ),
                ],
              ),
            ),
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
