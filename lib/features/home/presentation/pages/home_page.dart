import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cobox_sv_mobile/app/colors.dart';
import 'package:cobox_sv_mobile/shared/widgets/app_bar_widget.dart';
import 'package:cobox_sv_mobile/shared/widgets/avatar_widget.dart';
import 'package:cobox_sv_mobile/shared/widgets/status_badge.dart';
import 'package:cobox_sv_mobile/shared/widgets/dashboard_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarWidget(
        title: 'Inicio',
        leading: const AvatarWidget(name: 'Carlos'),
        vehicleCode: 'ABC-1234',
        onMenuTap: () {},
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GreetingCard(),
              const SizedBox(height: 24),
              Text('Dashboard', style: textTheme.titleMedium),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2,
                children: const [
                  DashboardCard(
                    icon: Icons.check_circle_outline,
                    value: '12',
                    label: 'Completadas',
                    iconColor: AppColors.success,
                    backgroundColor: AppColors.successLight,
                  ),
                  DashboardCard(
                    icon: Icons.pending_outlined,
                    value: '5',
                    label: 'Pendientes',
                    iconColor: AppColors.warning,
                    backgroundColor: AppColors.warningLight,
                  ),
                  DashboardCard(
                    icon: Icons.route_outlined,
                    value: '145 km',
                    label: 'Distancia',
                    iconColor: AppColors.primary,
                    backgroundColor: AppColors.primaryLight,
                  ),
                  DashboardCard(
                    icon: Icons.access_time,
                    value: '6.5 h',
                    label: 'Horas',
                    iconColor: AppColors.secondary,
                    backgroundColor: AppColors.secondaryLight,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Actividad Reciente', style: textTheme.titleMedium),
              const SizedBox(height: 12),
              ..._buildActivityItems(textTheme),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActivityItems(TextTheme textTheme) {
    final activities = [
      _ActivityData(
        icon: Icons.check_circle,
        iconColor: AppColors.success,
        bgColor: AppColors.successLight,
        title: 'Entrega completada',
        description: 'Av. Belgrano 3200',
        time: '14:30',
      ),
      _ActivityData(
        icon: Icons.schedule,
        iconColor: AppColors.warning,
        bgColor: AppColors.warningLight,
        title: 'Pendiente de entrega',
        description: 'San Martín 850',
        time: '13:15',
      ),
      _ActivityData(
        icon: Icons.location_on,
        iconColor: AppColors.primary,
        bgColor: AppColors.primaryLight,
        title: 'Ruta iniciada',
        description: 'Ruta diaria #123',
        time: '11:00',
      ),
      _ActivityData(
        icon: Icons.warning,
        iconColor: AppColors.danger,
        bgColor: AppColors.dangerLight,
        title: 'Incidencia reportada',
        description: 'Falla mecánica menor',
        time: '09:45',
      ),
    ];

    return activities.map((a) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: a.bgColor,
                child: Icon(a.icon, color: a.iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      a.description,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                a.time,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola, Carlos!',
            style: textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.directions_car, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Vehículo: ABC-1234',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Estado',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 8),
              const StatusBadge(
                label: 'En servicio activo',
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityData {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String description;
  final String time;

  const _ActivityData({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.description,
    required this.time,
  });
}
