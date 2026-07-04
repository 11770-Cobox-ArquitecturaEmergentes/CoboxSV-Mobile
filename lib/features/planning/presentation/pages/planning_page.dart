import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cobox_sv_mobile/app/colors.dart';
import 'package:cobox_sv_mobile/features/routes/domain/entities/route_entity.dart';
import 'package:cobox_sv_mobile/features/routes/presentation/providers/route_provider.dart';

class PlanningPage extends ConsumerWidget {
  const PlanningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(routesProvider(null));

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: const _DriverHeader(title: 'Planificar'),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.refresh(routesProvider(null).future);
        },
        child: routesAsync.when(
          loading: () => const _LoadingRoutesView(),
          error: (error, _) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            children: [
              const _TopPlanningCard(),
              const SizedBox(height: 16),
              _PlanningInfoCard(
                title: 'No se pudieron cargar las rutas',
                message: error.toString(),
              ),
            ],
          ),
          data: (routes) => _PlanningContent(routes: routes),
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
            'Rutas sincronizadas',
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

class _PlanningContent extends StatelessWidget {
  const _PlanningContent({required this.routes});

  final List<RouteEntity> routes;

  @override
  Widget build(BuildContext context) {
    final activeRoute = routes.cast<RouteEntity?>().firstWhere(
          (route) => route?.status == 'IN_PROGRESS',
          orElse: () => null,
        );
    final plannedCount =
        routes.where((route) => route.status == 'PLANNED').length;
    final completedCount =
        routes.where((route) => route.status == 'COMPLETED').length;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _TopPlanningCard(),
        const SizedBox(height: 16),
        _PlanningInfoCard(
          title: activeRoute != null ? 'Ruta en progreso' : 'Resumen operativo',
          message: activeRoute != null
              ? '${activeRoute.name} con ${activeRoute.stops.length} paradas.'
              : 'Tienes ${routes.length} rutas registradas en el backend.',
        ),
        const SizedBox(height: 16),
        _RouteSummaryCard(
          activeCount: activeRoute == null ? 0 : 1,
          plannedCount: plannedCount,
          completedCount: completedCount,
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Rutas disponibles (${routes.length})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(height: 12),
        if (routes.isEmpty)
          const _EmptyRoutesCard()
        else
          for (final route in routes) ...[
            _RouteOptionCard(route: route),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _LoadingRoutesView extends StatelessWidget {
  const _LoadingRoutesView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 180),
        Center(child: CircularProgressIndicator()),
      ],
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

class _PlanningInfoCard extends StatelessWidget {
  const _PlanningInfoCard({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

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
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    color: Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
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
  const _RouteSummaryCard({
    required this.activeCount,
    required this.plannedCount,
    required this.completedCount,
  });

  final int activeCount;
  final int plannedCount;
  final int completedCount;

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
                      'Estado de rutas',
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$activeCount activas, $plannedCount planificadas',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$completedCount completadas',
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
              children: [],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteOptionCard extends StatelessWidget {
  const _RouteOptionCard({required this.route});

  final RouteEntity route;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final selected = route.status == 'IN_PROGRESS';
    final tags = <String>[
      _statusLabel(route.status),
      '${route.stops.length} paradas',
    ];

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
                route.name,
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
                  value: '${route.distance.toStringAsFixed(0)} km',
                ),
              ),
              Expanded(
                child: _MetricBlock(
                  icon: Icons.access_time_filled_rounded,
                  label: 'Tiempo',
                  value: route.duration == null
                      ? '-'
                      : '${route.duration!.inMinutes} min',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in tags) _TrafficTag(label: tag),
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 6),
                child: Text(
                  'Pedidos: ${route.orderIds.length}',
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
                      for (var i = 0; i < route.stops.length; i++) ...[
                        _PointChip(label: 'Pedido ${route.stops[i].orderId ?? route.stops[i].id}'),
                        if (i != route.stops.length - 1) ...[
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
                LinearProgressIndicator(
                  value: route.progress,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE2E8F0),
                  color: selected ? AppColors.secondary : AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/routes/${route.id}'),
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
                Icons.visibility_outlined,
                size: 18,
                color: selected ? AppColors.white : AppColors.text,
              ),
              label: Text(
                selected ? 'Ver ruta activa' : 'Ver detalle',
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

class _EmptyRoutesCard extends StatelessWidget {
  const _EmptyRoutesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _surfaceDecoration(),
      padding: const EdgeInsets.all(18),
      child: const Text(
        'No hay rutas registradas para este conductor en el backend.',
        style: TextStyle(
          color: AppColors.gray500,
          fontSize: 15,
        ),
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
    final upper = label.toUpperCase();
    final isHeavy = upper == 'COMPLETED';
    final isToll = upper == 'PLANNED';
    final isModerate = upper == 'IN_PROGRESS';

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

String _statusLabel(String status) {
  switch (status.toUpperCase()) {
    case 'IN_PROGRESS':
      return 'IN_PROGRESS';
    case 'COMPLETED':
      return 'COMPLETED';
    case 'PLANNED':
      return 'PLANNED';
    default:
      return status.toUpperCase();
  }
}
