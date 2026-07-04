import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cobox_sv_mobile/app/colors.dart';
import 'package:cobox_sv_mobile/features/routes/domain/entities/route_entity.dart';
import 'package:cobox_sv_mobile/features/routes/domain/entities/stop_entity.dart';
import 'package:cobox_sv_mobile/features/routes/presentation/providers/route_provider.dart';

class RoutesPage extends ConsumerWidget {
  const RoutesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRouteAsync = ref.watch(activeRouteProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: const _DriverHeader(title: 'Ruta'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeRouteProvider);
          ref.invalidate(routesProvider(null));
        },
        child: activeRouteAsync.when(
          data: (route) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            child: route == null
                ? const _EmptyRouteState()
                : _RouteContent(route: route),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: const _EmptyRouteState(),
          ),
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

class _RouteContent extends ConsumerWidget {
  const _RouteContent({required this.route});

  final RouteEntity route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = route.progress == 0 ? 0.65 : route.progress;
    final currentStop = route.stops.firstWhere(
      (stop) => stop.status == 'IN_PROGRESS',
      orElse: () => route.stops.last,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ActiveRouteCard(route: route, progress: progress),
        const SizedBox(height: 14),
        _CurrentLocationCard(stop: currentStop),
        const SizedBox(height: 14),
        _SectionCard(
          title: 'Paradas (${route.stops.length})',
          child: Column(
            children: [
              for (var i = 0; i < route.stops.length; i++)
                _StopTimelineTile(
                  stop: route.stops[i],
                  isFirst: i == 0,
                  isLast: i == route.stops.length - 1,
                  onConfirm: route.stops[i].status == 'IN_PROGRESS'
                      ? () => ref
                          .read(routeNotifierProvider(route.id).notifier)
                          .completeStop(route.id, route.stops[i].id)
                      : null,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD9E2EC)),
          ),
          padding: const EdgeInsets.all(26),
          child: Column(
            children: const [
              Icon(
                Icons.location_on_outlined,
                size: 62,
                color: Color(0xFF64748B),
              ),
              SizedBox(height: 12),
              Text(
                'Mapa de ruta interactivo',
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Visualizacion de todas las paradas',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActiveRouteCard extends StatelessWidget {
  const _ActiveRouteCard({
    required this.route,
    required this.progress,
  });

  final RouteEntity route;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.secondary, AppColors.primary],
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ruta activa',
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'RT-2024-${route.id}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.near_me_outlined,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                'Progreso',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.white),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: AppColors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Salida: ${_formatTime(route.startTime ?? DateTime(2026, 6, 18, 8, 0))}',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.white),
              ),
              const Spacer(),
              Text(
                'Llegada est.: ${_formatTime(route.estimatedEndTime ?? DateTime(2026, 6, 18, 16, 30))}',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrentLocationCard extends StatelessWidget {
  const _CurrentLocationCard({required this.stop});

  final StopEntity stop;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: _surfaceDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFE7F6F4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.near_me_outlined,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ubicacion actual',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stop.address,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.near_me_outlined, size: 18),
              label: const Text('Abrir navegacion GPS'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: _surfaceDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          child,
        ],
      ),
    );
  }
}

class _StopTimelineTile extends StatelessWidget {
  const _StopTimelineTile({
    required this.stop,
    required this.isFirst,
    required this.isLast,
    this.onConfirm,
  });

  final StopEntity stop;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isCompleted = stop.status == 'COMPLETED';
    final isInProgress = stop.status == 'IN_PROGRESS';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF22C55E)
                        : isInProgress
                            ? AppColors.secondary
                            : const Color(0xFFD4DCE8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle_outline_rounded
                        : Icons.location_on_outlined,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 92,
                    color: isCompleted || isInProgress
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFD4DCE8),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MiniTag(
                        label: isFirst ? 'Recogida' : 'Entrega',
                        backgroundColor: isFirst
                            ? AppColors.secondary
                            : AppColors.primary,
                      ),
                      if (isInProgress)
                        const _MiniTag(
                          label: 'En progreso',
                          backgroundColor: AppColors.secondary,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    stop.clientName,
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stop.address,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(stop.scheduledTime ?? DateTime(2026, 6, 18, 14, 0)),
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),
                  if (isCompleted)
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: Color(0xFF22C55E),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Completada',
                          style: textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    )
                  else if (isInProgress) ...[
                    SizedBox(
                      width: double.infinity,
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
                        label: const Text('Llamar cliente'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onConfirm,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                        label: const Text('Confirmar entrega'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({
    required this.label,
    required this.backgroundColor,
  });

  final String label;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
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

class _EmptyRouteState extends StatelessWidget {
  const _EmptyRouteState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _surfaceDecoration(),
      child: Column(
        children: [
          const Icon(Icons.route_outlined, size: 60, color: AppColors.gray500),
          const SizedBox(height: 12),
          Text(
            'No hay ruta activa',
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cuando haya una ruta asignada aparecera aqui.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.gray500),
            textAlign: TextAlign.center,
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

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
