import 'package:flutter/material.dart';

import 'package:cobox_sv_mobile/app/colors.dart';

class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  bool _hasCalculatedRoute = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: const _DriverHeader(title: 'Planificar'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TopPlanningCard(),
            const SizedBox(height: 16),
            _PlanningFormCard(
              onCalculate: () {
                setState(() {
                  _hasCalculatedRoute = true;
                });
              },
            ),
            const SizedBox(height: 16),
            _MapPreviewCard(hasRoute: _hasCalculatedRoute),
            const SizedBox(height: 16),
            const _PlanningInfoCard(),
            if (_hasCalculatedRoute) ...[
              const SizedBox(height: 18),
              const _RouteSummaryCard(),
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Rutas disponibles (3)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const _RouteOptionCard(
                title: 'Ruta Rapida',
                distance: '24.5 km',
                time: '28 min',
                trafficTags: ['Trafico ligero'],
                fuel: '\$450',
                selected: true,
                points: ['Inicio', 'Av. Libertador', 'Av. Cordoba'],
              ),
              const SizedBox(height: 12),
              const _RouteOptionCard(
                title: 'Ruta Economica',
                distance: '26.8 km',
                time: '35 min',
                trafficTags: ['Trafico moderado'],
                fuel: '\$420',
                points: ['Inicio', 'Av. Belgrano', 'Av. Rivadavia'],
              ),
              const SizedBox(height: 12),
              const _RouteOptionCard(
                title: 'Autopista',
                distance: '22.1 km',
                time: '25 min',
                trafficTags: ['Trafico pesado', 'Con peaje'],
                fuel: '\$480',
                points: ['Inicio', 'Autopista 25 de Mayo', 'Autopista Sur'],
              ),
            ],
          ],
        ),
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
            'ABC-1234',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.gray500,
            ),
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

class _TopPlanningCard extends StatelessWidget {
  const _TopPlanningCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.secondary, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.alt_route_rounded,
              color: AppColors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Planificar ruta',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Calcula la mejor ruta a tu destino',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanningFormCard extends StatelessWidget {
  const _PlanningFormCard({required this.onCalculate});

  final VoidCallback onCalculate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: _surfaceDecoration(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Origen',
            style: textTheme.titleSmall?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const _InputBox(
            icon: Icons.location_on_outlined,
            iconColor: AppColors.gray500,
            text: 'Ingresa direccion de origen',
          ),
          const SizedBox(height: 8),
          const _SecondaryGhostButton(
            icon: Icons.near_me_outlined,
            label: 'Usar mi ubicacion actual',
          ),
          const SizedBox(height: 14),
          Text(
            'Destino',
            style: textTheme.titleSmall?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const _InputBox(
            icon: Icons.location_on_outlined,
            iconColor: AppColors.danger,
            text: 'Ingresa direccion de destino',
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCalculate,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.alt_route_rounded, size: 18),
              label: const Text('Calcular ruta optima'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPreviewCard extends StatelessWidget {
  const _MapPreviewCard({required this.hasRoute});

  final bool hasRoute;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1F8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD9E2EC)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.open_in_full_rounded,
                size: 18,
                color: AppColors.gray500,
              ),
            ),
          ),
          SizedBox(
            height: 150,
            child: Center(
              child: hasRoute ? const _MapRouteIllustration() : const _MapPlaceholder(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 64,
          color: Color(0xFFA6B4C8),
        ),
        const SizedBox(height: 10),
        Text(
          'Vista previa del mapa',
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.gray500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Ingresa los datos para calcular la ruta',
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }
}

class _MapRouteIllustration extends StatelessWidget {
  const _MapRouteIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomPaint(
        painter: _RoutePainter(),
      ),
    );
  }
}

class _PlanningInfoCard extends StatelessWidget {
  const _PlanningInfoCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB5D1FF)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Planificacion inteligente',
                  style: textTheme.titleSmall?.copyWith(
                    color: Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Nuestro sistema calculara automaticamente la ruta mas eficiente considerando trafico en tiempo real, peajes y consumo de combustible.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Color(0xFF1D4ED8),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteSummaryCard extends StatelessWidget {
  const _RouteSummaryCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF08C444),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ruta calculada',
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '08:24 p. m.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Nueva ruta',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: const Column(
              children: [
                _MiniRouteMetric(
                  icon: Icons.location_on_outlined,
                  value: '321',
                ),
                SizedBox(height: 8),
                _MiniRouteMetric(
                  icon: Icons.near_me_outlined,
                  value: '213',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniRouteMetric extends StatelessWidget {
  const _MiniRouteMetric({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, color: AppColors.white, size: 16),
        const SizedBox(width: 8),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}

class _RouteOptionCard extends StatelessWidget {
  const _RouteOptionCard({
    required this.title,
    required this.distance,
    required this.time,
    required this.trafficTags,
    required this.fuel,
    required this.points,
    this.selected = false,
  });

  final String title;
  final String distance;
  final String time;
  final List<String> trafficTags;
  final String fuel;
  final List<String> points;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? AppColors.secondary : const Color(0xFFD9E2EC),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selected)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Recomendada',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Row(
            children: [
              const Icon(
                Icons.alt_route_rounded,
                color: AppColors.secondary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricBlock(
                  icon: Icons.near_me_outlined,
                  label: 'Distancia',
                  value: distance,
                ),
              ),
              Expanded(
                child: _MetricBlock(
                  icon: Icons.access_time_filled_rounded,
                  label: 'Tiempo',
                  value: time,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in trafficTags) _TrafficTag(label: tag),
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 6),
                child: Text(
                  'Combustible: $fuel',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Puntos de ruta:',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var i = 0; i < points.length; i++) ...[
                        _PointChip(label: points[i]),
                        if (i != points.length - 1) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.near_me_outlined,
                            size: 14,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 6),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2E2E),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_left,
                        color: AppColors.white,
                        size: 14,
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 132,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFBDBDBD),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_right,
                        color: AppColors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: selected ? AppColors.white : AppColors.text,
                backgroundColor: selected ? AppColors.secondary : AppColors.white,
                side: BorderSide(
                  color: selected ? AppColors.secondary : const Color(0xFFD9E2EC),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                Icons.check_circle_outline_rounded,
                size: 18,
                color: selected ? AppColors.white : AppColors.text,
              ),
              label: Text(
                'Seleccionar esta ruta',
                style: textTheme.titleSmall?.copyWith(
                  color: selected ? AppColors.white : AppColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Color(0xFFEAF2FF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.gray500,
              ),
            ),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrafficTag extends StatelessWidget {
  const _TrafficTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isHeavy = label == 'Trafico pesado';
    final isToll = label == 'Con peaje';
    final isModerate = label == 'Trafico moderado';

    Color textColor = const Color(0xFF16A34A);
    Color bgColor = const Color(0xFFE8F8EF);

    if (isHeavy) {
      textColor = const Color(0xFFEF4444);
      bgColor = const Color(0xFFFEE2E2);
    } else if (isToll) {
      textColor = const Color(0xFFF97316);
      bgColor = const Color(0xFFFFEDD5);
    } else if (isModerate) {
      textColor = const Color(0xFFD97706);
      bgColor = const Color(0xFFFEF3C7);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PointChip extends StatelessWidget {
  const _PointChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E2EC)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryGhostButton extends StatelessWidget {
  const _SecondaryGhostButton({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E2EC)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.text, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
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

class _RoutePainter extends CustomPainter {
  const _RoutePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startPaint = Paint()..color = const Color(0xFF22C55E);
    final endPaint = Paint()..color = const Color(0xFFEF4444);

    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.32,
        size.height * 0.56,
        size.width * 0.48,
        size.height * 0.48,
      )
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.34,
        size.width * 0.72,
        size.height * 0.14,
      );

    canvas.drawPath(path, routePaint);
    canvas.drawCircle(Offset(size.width * 0.22, size.height * 0.78), 8, startPaint);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.14), 8, endPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
