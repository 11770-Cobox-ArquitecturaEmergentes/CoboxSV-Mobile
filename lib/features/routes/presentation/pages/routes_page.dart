import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cobox_sv_mobile/app/colors.dart';
import 'package:cobox_sv_mobile/core/utils/extensions.dart';
import 'package:cobox_sv_mobile/shared/widgets/primary_button.dart';
import 'package:cobox_sv_mobile/shared/widgets/status_badge.dart';

class RoutesPage extends ConsumerWidget {
  const RoutesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = context.textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi Ruta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MapSection(),
            const SizedBox(height: 20),
            _RouteInfoCards(),
            const SizedBox(height: 20),
            Text('Paradas', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            _StopsList(),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Finalizar Ruta',
              fullWidth: true,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _MapSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE8EDF2),
                    Color(0xFFB0C4DE),
                    Color(0xFF7BA3C7),
                    Color(0xFF5B8DB8),
                  ],
                ),
              ),
              child: CustomPaint(
                painter: _MapLinesPainter(),
                size: Size.infinite,
              ),
            ),
            Positioned(
              top: 40,
              left: 40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_pin,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 30,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 100,
              right: 60,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 2,
                    height: 30,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.danger,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 90,
              left: 64,
              right: 84,
              child: CustomPaint(
                painter: _DottedLinePainter(),
                size: const Size(double.infinity, 2),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('45 min', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.route, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('23 km', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = 0;
    while (startX < size.width) {
      final endX = (startX + dashWidth).clamp(0, size.width);
      canvas.drawLine(Offset(startX, 0), Offset(endX.toDouble(), 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RouteInfoCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            icon: Icons.schedule,
            label: 'Tiempo',
            value: '45 min',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            icon: Icons.route,
            label: 'Distancia',
            value: '23 km',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            icon: Icons.traffic,
            label: 'Tráfico',
            value: 'Moderado',
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _StopsList extends StatelessWidget {
  final List<_StopData> stops = const [
    _StopData(number: 1, client: 'Cliente 1', address: 'Dirección #1'),
    _StopData(number: 2, client: 'Cliente 2', address: 'Dirección #2'),
    _StopData(number: 3, client: 'Cliente 3', address: 'Dirección #3'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: stops.map((stop) {
        final isLast = stops.last == stop;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
          child: _StopItem(stop: stop, isCompleted: stop.number < 3),
        );
      }).toList(),
    );
  }
}

class _StopData {
  final int number;
  final String client;
  final String address;

  const _StopData({
    required this.number,
    required this.client,
    required this.address,
  });
}

class _StopItem extends StatelessWidget {
  final _StopData stop;
  final bool isCompleted;

  const _StopItem({
    required this.stop,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isCompleted ? AppColors.success : AppColors.primary,
              child: isCompleted
                  ? const Icon(Icons.check, size: 18, color: AppColors.white)
                  : Text(
                      '${stop.number}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stop.client,
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stop.address,
                    style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (isCompleted)
              StatusBadge(label: 'Completada', color: AppColors.statusCompleted)
            else
              StatusBadge(label: 'Pendiente', color: AppColors.statusPending),
          ],
        ),
      ),
    );
  }
}
