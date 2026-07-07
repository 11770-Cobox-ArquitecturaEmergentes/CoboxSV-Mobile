import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cobox_sv_mobile/app/colors.dart';
import 'package:cobox_sv_mobile/core/utils/responsive_layout.dart';
import 'package:cobox_sv_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:cobox_sv_mobile/features/orders/presentation/providers/order_provider.dart';
import 'package:cobox_sv_mobile/shared/enums/order_status.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(ordersProvider.notifier).loadOrders());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersProvider);
    final notifier = ref.read(ordersProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: const _DriverHeader(title: 'Ordenes'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              adaptivePagePadding(constraints.maxWidth);

          return RefreshIndicator(
            onRefresh: notifier.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding:
                  EdgeInsets.fromLTRB(horizontalPadding, 14, horizontalPadding, 24),
              child: Column(
                children: [
                  _OrdersSummaryCard(orders: state.orders),
                  const SizedBox(height: 14),
                  if (state.isLoading && state.orders.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: LinearProgressIndicator(),
                    ),
                  if (state.orders.isEmpty && !state.isLoading)
                    const _EmptyOrdersState()
                  else
                    ...List.generate(state.orders.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == state.orders.length - 1 ? 0 : 14,
                        ),
                        child: _OrderCard(
                          order: state.orders[index],
                          onPrimaryAction: () async {
                            final nextStatus = switch (state.orders[index].status) {
                              OrderStatus.pending => OrderStatus.assigned,
                              OrderStatus.assigned => OrderStatus.inProgress,
                              OrderStatus.inProgress => OrderStatus.inProgress,
                              _ => state.orders[index].status,
                            };
                            if (nextStatus == state.orders[index].status) return;
                            await notifier.updateStatus(
                              id: state.orders[index].id,
                              status: nextStatus,
                              notes: state.orders[index].notes,
                            );
                          },
                        ),
                      );
                    }),
                ],
              ),
            ),
          );
        },
      ),
    );
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
            'Backend sincronizado',
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

class _OrdersSummaryCard extends StatelessWidget {
  const _OrdersSummaryCard({required this.orders});

  final List<OrderEntity> orders;

  @override
  Widget build(BuildContext context) {
    final completed = orders.where((o) => o.status == OrderStatus.completed).length;
    final inProgress = orders.where((o) => o.status == OrderStatus.inProgress).length;
    final pending = orders
        .where((o) => o.status == OrderStatus.pending || o.status == OrderStatus.assigned)
        .length;

    return Container(
      width: double.infinity,
      decoration: _surfaceDecoration(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mis ordenes asignadas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SummaryBox(
                  value: completed.toString(),
                  label: 'Completadas',
                  color: const Color(0xFF22C55E),
                  backgroundColor: const Color(0xFFE9F9EF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryBox(
                  value: inProgress.toString(),
                  label: 'En progreso',
                  color: const Color(0xFF2563EB),
                  backgroundColor: const Color(0xFFEAF2FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryBox(
                  value: pending.toString(),
                  label: 'Pendientes',
                  color: const Color(0xFFF97316),
                  backgroundColor: const Color(0xFFFFF1E8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.value,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String value;
  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.onPrimaryAction,
  });

  final OrderEntity order;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = _accentColor(order.status);
    final actionLabel = switch (order.status) {
      OrderStatus.completed => null,
      OrderStatus.inProgress => null,
      OrderStatus.pending => 'Preparar despacho',
      OrderStatus.assigned => 'Iniciar entrega',
      _ => null,
    };

    return Container(
      decoration: BoxDecoration(
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
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border(left: BorderSide(color: accent, width: 3)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'ORD-2026-${order.id.padLeft(3, '0')}',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                _StatusPill(status: order.status),
                const Spacer(),
                const Icon(Icons.access_time_rounded, size: 18, color: AppColors.gray500),
                const SizedBox(width: 6),
                Text(
                  _timeForOrder(order),
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.gray500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              order.clientName,
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _companyForOrder(order),
              style: textTheme.bodyMedium?.copyWith(color: AppColors.gray500),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.gray600),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _cargoTitle(order),
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _cargoMeta(order),
                        style: textTheme.bodySmall?.copyWith(color: AppColors.gray500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: AppColors.gray600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.deliveryAddress.fullAddress,
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.text),
                  ),
                ),
              ],
            ),
            if ((order.notes ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.notes!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.text,
                      side: const BorderSide(color: Color(0xFFD9E2EC)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.call_outlined, size: 18),
                    label: const Text('Llamar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.text,
                      side: const BorderSide(color: Color(0xFFD9E2EC)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: const Text('Mensaje'),
                  ),
                ),
              ],
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onPrimaryAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: order.status == OrderStatus.pending ||
                            order.status == OrderStatus.assigned
                        ? AppColors.primary
                        : AppColors.secondary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    order.status == OrderStatus.inProgress
                        ? Icons.check_circle_outline_rounded
                        : Icons.inventory_2_outlined,
                    size: 18,
                  ),
                  label: Text(actionLabel),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _companyForOrder(OrderEntity order) {
    return switch (order.id) {
      '101' => 'Distribuidora del Norte S.A.',
      '102' => 'Alimentos Premium Ltda.',
      '103' => 'Construcciones del Sur',
      _ => 'Cliente asignado',
    };
  }

  String _cargoTitle(OrderEntity order) {
    return switch (order.id) {
      '101' => 'Electronica',
      '102' => 'Alimentos perecederos',
      '103' => 'Materiales de construccion',
      _ => 'Mercancia general',
    };
  }

  String _cargoMeta(OrderEntity order) {
    return switch (order.id) {
      '101' => '500 kg • 25 cajas',
      '102' => '800 kg • 40 cajas',
      '103' => '2,500 kg • 100 unidades',
      _ => '${(order.weight ?? 0).toStringAsFixed(0)} kg',
    };
  }

  String _timeForOrder(OrderEntity order) {
    final time = order.scheduledDate ?? order.actualDeliveryTime ?? DateTime(2026, 6, 18, 16, 30);
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Color _accentColor(OrderStatus status) {
    return switch (status) {
      OrderStatus.completed => const Color(0xFFF97316),
      OrderStatus.inProgress => const Color(0xFFEF4444),
      OrderStatus.pending || OrderStatus.assigned => const Color(0xFFF59E0B),
      _ => AppColors.gray500,
    };
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      OrderStatus.completed => ('Completada', const Color(0xFF22C55E)),
      OrderStatus.inProgress => ('En progreso', AppColors.secondary),
      OrderStatus.pending => ('Pendiente', AppColors.primary),
      OrderStatus.assigned => ('Lista para despacho', const Color(0xFF2563EB)),
      _ => (status.label, AppColors.gray500),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyOrdersState extends StatelessWidget {
  const _EmptyOrdersState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: _surfaceDecoration(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined, size: 56, color: AppColors.gray500),
          const SizedBox(height: 12),
          Text(
            'No hay ordenes asignadas',
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cuando lleguen nuevas ordenes apareceran en esta seccion.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.gray500),
          ),
        ],
      ),
    );
  }
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
