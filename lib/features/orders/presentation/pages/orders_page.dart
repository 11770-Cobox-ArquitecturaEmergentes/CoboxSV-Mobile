import 'package:flutter/material.dart';
import 'package:cobox_sv_mobile/app/colors.dart';
import 'package:cobox_sv_mobile/shared/widgets/search_field.dart';
import 'package:cobox_sv_mobile/shared/widgets/status_badge.dart';
import 'package:cobox_sv_mobile/shared/widgets/secondary_button.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _orders = [
    _OrderSample(
      client: 'Juan Pérez',
      address: 'Av. Siempre Viva 123',
      status: 'Completado',
      statusColor: AppColors.statusCompleted,
      time: '10:30',
    ),
    _OrderSample(
      client: 'María García',
      address: 'San Martín 456',
      status: 'En Progreso',
      statusColor: AppColors.statusInProgress,
      time: '11:45',
    ),
    _OrderSample(
      client: 'Carlos López',
      address: 'Belgrano 789',
      status: 'Pendiente',
      statusColor: AppColors.statusPending,
      time: '14:00',
    ),
    _OrderSample(
      client: 'Ana Martínez',
      address: 'Rivadavia 321',
      status: 'Pendiente',
      statusColor: AppColors.statusPending,
      time: '15:30',
    ),
  ];

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes'),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SearchField(hintText: 'Buscar órdenes...'),
              const SizedBox(height: 16),
              ...List.generate(_orders.length, (i) {
                final order = _orders[i];
                return Padding(
                  padding: EdgeInsets.only(bottom: i < _orders.length - 1 ? 12 : 0),
                  child: _OrderCard(order: order, textTheme: textTheme),
                );
              }),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSample {
  final String client;
  final String address;
  final String status;
  final Color statusColor;
  final String time;

  const _OrderSample({
    required this.client,
    required this.address,
    required this.status,
    required this.statusColor,
    required this.time,
  });
}

class _OrderCard extends StatelessWidget {
  final _OrderSample order;
  final TextTheme textTheme;

  const _OrderCard({
    required this.order,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: order.statusColor.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.person_rounded,
                    size: 20,
                    color: order.statusColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cliente: ${order.client}',
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Dirección: ${order.address}',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          StatusBadge(
                            label: order.status,
                            color: order.statusColor,
                          ),
                          const Spacer(),
                          Text(
                            order.time,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: SecondaryButton(
                label: 'Ver detalle',
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
