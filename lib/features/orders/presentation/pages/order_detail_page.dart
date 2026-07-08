import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cobox_sv_mobile/core/utils/extensions.dart';
import 'package:cobox_sv_mobile/core/utils/formatter.dart';
import 'package:cobox_sv_mobile/core/widgets/app_card.dart';
import 'package:cobox_sv_mobile/core/widgets/error.dart';
import 'package:cobox_sv_mobile/core/widgets/loading.dart';
import 'package:cobox_sv_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:cobox_sv_mobile/features/orders/presentation/providers/order_provider.dart';
import 'package:cobox_sv_mobile/features/orders/presentation/pages/update_order_status_page.dart';
import 'package:cobox_sv_mobile/features/orders/presentation/widgets/order_item_tile.dart';
import 'package:cobox_sv_mobile/features/orders/presentation/widgets/status_update_bottom_sheet.dart';
import 'package:cobox_sv_mobile/shared/enums/order_status.dart';

class OrderDetailPage extends ConsumerStatefulWidget {
  final String id;

  const OrderDetailPage({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  OrderEntity? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final order = await ref.read(ordersProvider.notifier).getOrderDetail(widget.id);
    setState(() {
      _order = order;
      _isLoading = false;
      if (order == null) _error = 'No se pudo cargar el pedido.';
    });
  }

  Future<void> _handleStatusUpdate(OrderStatus status, String? notes) async {
    final updated = await ref.read(ordersProvider.notifier).updateStatus(
          id: widget.id,
          status: status,
          notes: notes,
        );
    if (updated != null) {
      setState(() => _order = updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado actualizado a ${status.label}')),
        );
      }
    }
  }

  void _showStatusBottomSheet() {
    if (_order == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatusUpdateBottomSheet(
        currentStatus: _order!.status,
        onConfirm: _handleStatusUpdate,
      ),
    );
  }

  Future<void> _openCompleteOrderFlow() async {
    if (_order == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UpdateOrderStatusPage(order: _order!),
      ),
    );
    if (mounted) {
      await _loadOrder();
    }
  }

  Future<void> _callClient() async {
    if (_order?.clientPhone == null) return;
    final uri = Uri.parse('tel:${_order!.clientPhone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _messageClient() async {
    if (_order?.clientPhone == null) return;
    final uri = Uri.parse('sms:${_order!.clientPhone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openMap() {
    final addr = _order!.deliveryAddress;
    if (addr.latitude != null && addr.longitude != null) {
      final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${addr.latitude},${addr.longitude}',
      );
      launchUrl(uri);
    } else {
      final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(addr.fullAddress)}',
      );
      launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_order != null ? 'Pedido ${_order!.orderNumber}' : 'Detalle'),
      ),
      body: _buildBody(cs),
      bottomNavigationBar: _order != null && _order!.status.isActive
          && (_order!.status == OrderStatus.pending ||
              _order!.status == OrderStatus.assigned ||
              _order!.status == OrderStatus.inProgress)
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: _order!.status == OrderStatus.inProgress
                      ? _openCompleteOrderFlow
                      : _showStatusBottomSheet,
                  icon: Icon(_order!.status == OrderStatus.inProgress
                      ? Icons.fact_check_outlined
                      : Icons.update_rounded),
                  label: Text(_order!.status == OrderStatus.inProgress
                      ? 'Completar con evidencia'
                      : 'Actualizar Estado'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody(ColorScheme cs) {
    if (_isLoading) {
      return const LoadingWidget(message: 'Cargando pedido...');
    }

    if (_error != null) {
      return AppErrorWidget(
        message: _error,
        onRetry: _loadOrder,
      );
    }

    if (_order == null) {
      return const AppErrorWidget(message: 'Pedido no encontrado');
    }

    final order = _order!;

    return RefreshIndicator(
      onRefresh: _loadOrder,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusHeader(order: order, cs: cs),
            const SizedBox(height: 8),
            _ClientSection(
              order: order,
              cs: cs,
              onCall: _callClient,
              onMessage: _messageClient,
            ),
            const SizedBox(height: 8),
            _AddressSection(
              title: 'Dirección de Entrega',
              address: order.deliveryAddress.fullAddress,
              cs: cs,
              onMap: _openMap,
            ),
            if (order.pickupAddress != null) ...[
              const SizedBox(height: 8),
              _AddressSection(
                title: 'Dirección de Recogida',
                address: order.pickupAddress!.fullAddress,
                cs: cs,
              ),
            ],
            const SizedBox(height: 8),
            _ItemsSection(order: order, cs: cs),
            if (order.scheduledDate != null ||
                order.scheduledTimeWindow != null) ...[
              const SizedBox(height: 8),
              _ScheduleSection(order: order, cs: cs),
            ],
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _NotesSection(order: order, cs: cs),
            ],
            if (order.photoUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              _PhotosSection(order: order, cs: cs),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  final OrderEntity order;
  final ColorScheme cs;

  const _StatusHeader({required this.order, required this.cs});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido ${order.orderNumber}',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    if (order.clientName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          order.clientName,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: order.status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status.label,
                  style: TextStyle(
                    color: order.status.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (order.weight != null || order.volume != null) ...[
            const Divider(height: 24),
            Row(
              children: [
                if (order.weight != null) ...[
                  Icon(Icons.shopping_bag_outlined, size: 16, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    formatWeight(order.weight!),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (order.volume != null) ...[
                  Icon(Icons.square_foot, size: 16, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${order.volume!.toStringAsFixed(2)} m³',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ClientSection extends StatelessWidget {
  final OrderEntity order;
  final ColorScheme cs;
  final VoidCallback onCall;
  final VoidCallback onMessage;

  const _ClientSection({
    required this.order,
    required this.cs,
    required this.onCall,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cliente',
            style: context.textTheme.titleSmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: cs.primaryContainer,
                child: Text(
                  _getInitials(order.clientName),
                  style: TextStyle(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.clientName,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface,
                      ),
                    ),
                    if (order.clientPhone != null)
                      Text(
                        formatPhoneNumber(order.clientPhone!),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (order.clientPhone != null) ...[
                IconButton(
                  icon: Icon(Icons.phone_rounded, color: cs.primary),
                  onPressed: onCall,
                  tooltip: 'Llamar',
                ),
                IconButton(
                  icon: Icon(Icons.chat_rounded, color: cs.primary),
                  onPressed: onMessage,
                  tooltip: 'Enviar mensaje',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AddressSection extends StatelessWidget {
  final String title;
  final String address;
  final ColorScheme cs;
  final VoidCallback? onMap;

  const _AddressSection({
    required this.title,
    required this.address,
    required this.cs,
    this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.titleSmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined, size: 20, color: cs.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          if (onMap != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onMap,
                icon: const Icon(Icons.map_rounded, size: 18),
                label: const Text('Ver en mapa'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemsSection extends StatelessWidget {
  final OrderEntity order;
  final ColorScheme cs;

  const _ItemsSection({required this.order, required this.cs});

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
                'Artículos',
                style: context.textTheme.titleSmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${order.items.length} ${order.items.length == 1 ? 'artículo' : 'artículos'}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...order.items.map((item) => OrderItemTile(item: item)),
        ],
      ),
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  final OrderEntity order;
  final ColorScheme cs;

  const _ScheduleSection({required this.order, required this.cs});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Programación',
            style: context.textTheme.titleSmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (order.scheduledDate != null) ...[
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Fecha',
              value: formatDate(order.scheduledDate!),
              cs: cs,
            ),
            const SizedBox(height: 4),
          ],
          if (order.scheduledTimeWindow != null) ...[
            _InfoRow(
              icon: Icons.schedule_outlined,
              label: 'Horario',
              value: order.scheduledTimeWindow!,
              cs: cs,
            ),
          ],
          if (order.actualDeliveryTime != null) ...[
            const SizedBox(height: 4),
            _InfoRow(
              icon: Icons.check_circle_outlined,
              label: 'Entregado',
              value: formatDateTime(order.actualDeliveryTime!),
              cs: cs,
            ),
          ],
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  final OrderEntity order;
  final ColorScheme cs;

  const _NotesSection({required this.order, required this.cs});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notas',
            style: context.textTheme.titleSmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.notes!,
            style: context.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotosSection extends StatelessWidget {
  final OrderEntity order;
  final ColorScheme cs;

  const _PhotosSection({required this.order, required this.cs});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evidencia Fotográfica',
            style: context.textTheme.titleSmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: order.photoUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    order.photoUrls[index],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 100,
                      color: cs.surfaceContainerHighest,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _getInitials(String name) {
  if (name.isEmpty) return '';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
  return parts.first[0].toUpperCase();
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme cs;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
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
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}
