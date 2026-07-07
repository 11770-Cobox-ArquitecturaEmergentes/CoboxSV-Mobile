import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cobox_sv_mobile/app/colors.dart';
import 'package:cobox_sv_mobile/app/providers.dart';
import 'package:cobox_sv_mobile/features/authentication/presentation/providers/auth_provider.dart';
import 'package:cobox_sv_mobile/features/profile/presentation/providers/profile_provider.dart';
import 'package:cobox_sv_mobile/features/supervisor/presentation/providers/supervisor_provider.dart';

enum _SupervisorSection {
  dashboard('Dashboard', Icons.grid_view_rounded),
  smartVision('SmartVision IA', Icons.psychology_alt_outlined),
  vehicles('Vehiculos', Icons.local_shipping_outlined),
  drivers('Conductores', Icons.people_outline_rounded),
  orders('Ordenes', Icons.description_outlined),
  routes('Rutas', Icons.map_outlined),
  incidents('Incidentes', Icons.warning_amber_rounded),
  maintenance('Mantenimiento', Icons.build_outlined),
  reports('Reportes', Icons.insert_chart_outlined),
  logout('Cerrar sesion', Icons.logout_rounded);

  const _SupervisorSection(this.label, this.icon);

  final String label;
  final IconData icon;
}

class SupervisorDashboardPage extends ConsumerStatefulWidget {
  const SupervisorDashboardPage({super.key});

  @override
  ConsumerState<SupervisorDashboardPage> createState() =>
      _SupervisorDashboardPageState();
}

class _SupervisorDashboardPageState
    extends ConsumerState<SupervisorDashboardPage> {
  _SupervisorSection _selectedSection = _SupervisorSection.dashboard;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currentUser = ref.watch(authNotifierProvider).user;
    final userName = currentUser?.name ?? 'Administrador';
    final userRole = currentUser?.role ?? 'admin';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'A';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 760;

            if (isMobile) {
              return Column(
                children: [
                  _SupervisorTopBar(
                    onMenuTap: _openMenuSheet,
                    onProfileTap: _openProfileSheet,
                    isMobile: true,
                    userName: userName,
                    userRole: _roleLabel(userRole),
                    userInitial: userInitial,
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _buildSectionView(textTheme),
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                _SupervisorRail(
                  selectedSection: _selectedSection,
                  onSelected: _handleSectionTap,
                ),
                Expanded(
                  child: Column(
                    children: [
                      _SupervisorTopBar(
                        onMenuTap: _openMenuSheet,
                        onProfileTap: _openProfileSheet,
                        isMobile: false,
                        userName: userName,
                        userRole: _roleLabel(userRole),
                        userInitial: userInitial,
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: _buildSectionView(textTheme),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openMenuSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _SupervisorMenuSheet(
          selectedSection: _selectedSection,
          onSelected: (section) {
            Navigator.of(context).pop();
            _handleSectionTap(section);
          },
        );
      },
    );
  }

  Future<void> _openProfileSheet() async {
    ref.read(profileProvider.notifier).loadProfile();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _SupervisorProfileSheet(),
    );
  }

  void _handleSectionTap(_SupervisorSection section) {
    if (section == _SupervisorSection.logout) {
      ref.read(authNotifierProvider.notifier).logout();
      ref.read(authStatusProvider.notifier).state = AuthStatus.unauthenticated;
      return;
    }

    setState(() {
      _selectedSection = section;
    });
  }

  Widget _buildSectionView(TextTheme textTheme) {
    switch (_selectedSection) {
      case _SupervisorSection.dashboard:
        return const _SupervisorDashboardView();
      case _SupervisorSection.smartVision:
        return const _SupervisorSmartVisionView(
          key: ValueKey(_SupervisorSection.smartVision),
        );
      case _SupervisorSection.vehicles:
        return const _SupervisorVehiclesView(
          key: ValueKey(_SupervisorSection.vehicles),
        );
      case _SupervisorSection.drivers:
        return const _SupervisorDriversView(
          key: ValueKey(_SupervisorSection.drivers),
        );
      case _SupervisorSection.orders:
        return const _SupervisorOrdersView(
          key: ValueKey(_SupervisorSection.orders),
        );
      case _SupervisorSection.routes:
        return const _SupervisorRoutesView(
          key: ValueKey(_SupervisorSection.routes),
        );
      case _SupervisorSection.incidents:
        return const _SupervisorIncidentsView(
          key: ValueKey(_SupervisorSection.incidents),
        );
      case _SupervisorSection.maintenance:
        return const _SupervisorMaintenanceView(
          key: ValueKey(_SupervisorSection.maintenance),
        );
      case _SupervisorSection.reports:
        return const _SupervisorReportsView(
          key: ValueKey(_SupervisorSection.reports),
        );
      default:
        return _SupervisorPlaceholderView(
          key: ValueKey(_selectedSection),
          section: _selectedSection,
          textTheme: textTheme,
        );
    }
  }
}

String _roleLabel(String role) {
  switch (role.toLowerCase()) {
    case 'supervisor':
      return 'Supervisor';
    case 'admin':
      return 'Administrador';
    case 'driver':
      return 'Conductor';
    default:
      return role;
  }
}

class _SupervisorRail extends StatelessWidget {
  const _SupervisorRail({
    required this.selectedSection,
    required this.onSelected,
  });

  final _SupervisorSection selectedSection;
  final ValueChanged<_SupervisorSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(right: BorderSide(color: Color(0xFFDCE5EF))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.local_shipping_outlined, color: Colors.white),
          ),
          const SizedBox(height: 18),
          for (final section in _SupervisorSection.values
              .where((section) => section != _SupervisorSection.logout))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RailButton(
                icon: section.icon,
                selected: selectedSection == section,
                onTap: () => onSelected(section),
              ),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _RailButton(
              icon: _SupervisorSection.logout.icon,
              selected: false,
              onTap: () => onSelected(_SupervisorSection.logout),
            ),
          ),
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: selected ? AppColors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: selected ? AppColors.white : AppColors.gray700,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _SupervisorTopBar extends StatelessWidget {
  const _SupervisorTopBar({
    required this.onMenuTap,
    required this.onProfileTap,
    required this.isMobile,
    required this.userName,
    required this.userRole,
    required this.userInitial,
  });

  final VoidCallback onMenuTap;
  final VoidCallback onProfileTap;
  final bool isMobile;
  final String userName;
  final String userRole;
  final String userInitial;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: isMobile ? 74 : 84,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFDCE5EF))),
      ),
      child: Row(
        children: [
          _TopIconButton(
            icon: isMobile ? Icons.menu_rounded : Icons.chevron_right_rounded,
            onTap: onMenuTap,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: isMobile
                ? Row(
                    children: const [
                      _TopIconButton(icon: Icons.search_rounded),
                      SizedBox(width: 10),
                      _TopIconButton(
                        icon: Icons.notifications_none_rounded,
                        hasBadge: true,
                      ),
                      SizedBox(width: 10),
                      _TopIconButton(icon: Icons.settings_outlined),
                    ],
                  )
                : const Row(
                    children: [
                      _TopIconButton(icon: Icons.search_rounded),
                      SizedBox(width: 10),
                      _TopIconButton(
                        icon: Icons.notifications_none_rounded,
                        hasBadge: true,
                      ),
                      SizedBox(width: 10),
                      _TopIconButton(icon: Icons.settings_outlined),
                    ],
                  ),
          ),
          if (!isMobile) ...[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                Text(
                  userName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userRole,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.gray500),
                ),
              ],
            ),
            const SizedBox(width: 10),
          ],
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onProfileTap,
              customBorder: const CircleBorder(),
              child: Container(
                width: isMobile ? 38 : 40,
                height: isMobile ? 38 : 40,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  userInitial,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({
    required this.icon,
    this.onTap,
    this.hasBadge = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool hasBadge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD7E2EE)),
            ),
            child: Icon(icon, color: AppColors.gray700, size: 20),
          ),
          if (hasBadge)
            Positioned(
              top: 7,
              right: 7,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SupervisorDashboardView extends ConsumerWidget {
  const _SupervisorDashboardView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(supervisorOverviewProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vista general de tu flota en tiempo real',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.gray600,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 20),
          overviewAsync.when(
            data: (overview) => _StatsGrid(overview: overview),
            loading: () => const _DashboardLoadingCard(),
            error: (error, _) => _DashboardErrorCard(message: error.toString()),
          ),
          const SizedBox(height: 18),
          const _LineChartCard(),
          const SizedBox(height: 18),
          const _BarChartCard(),
          const SizedBox(height: 18),
          const _VehicleHealthCard(),
          const SizedBox(height: 18),
          overviewAsync.maybeWhen(
            data: (overview) => _RouteEfficiencyCard(overview: overview),
            orElse: () => const _RouteEfficiencyCard(),
          ),
          const SizedBox(height: 18),
          overviewAsync.maybeWhen(
            data: (overview) => _LiveMapCard(overview: overview),
            orElse: () => const _LiveMapCard(),
          ),
        ],
      ),
    );
  }
}

class _SupervisorProfileSheet extends ConsumerWidget {
  const _SupervisorProfileSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authNotifierProvider).user;
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;
    final displayName = profile?.name ?? authUser?.name ?? 'Usuario';
    final displayRole = _roleLabel(profile?.role ?? authUser?.role ?? 'admin');
    final displayEmail = profile?.email ?? authUser?.email ?? '-';
    final displayPhone = profile?.phone ?? authUser?.phone ?? '-';
    final vehicle = profile?.vehicle;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.secondary,
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.text,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayRole,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.gray500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (profileState.status == ProfileStateStatus.loading && profile == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                _ProfileInfoTile(
                  icon: Icons.email_outlined,
                  label: 'Correo',
                  value: displayEmail,
                ),
                const SizedBox(height: 10),
                _ProfileInfoTile(
                  icon: Icons.call_outlined,
                  label: 'Telefono',
                  value: displayPhone,
                ),
                const SizedBox(height: 10),
                _ProfileInfoTile(
                  icon: Icons.badge_outlined,
                  label: 'Licencia',
                  value: profile?.licenseNumber ?? '-',
                ),
                const SizedBox(height: 10),
                _ProfileInfoTile(
                  icon: Icons.local_shipping_outlined,
                  label: 'Vehiculo',
                  value: vehicle == null
                      ? '-'
                      : '${vehicle.plate} · ${vehicle.brand} ${vehicle.model}',
                ),
              ],
              if (profileState.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  profileState.error!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.danger,
                      ),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.read(profileProvider.notifier).loadProfile();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.text,
                        side: const BorderSide(color: Color(0xFFDCE5EF)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Recargar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await ref.read(authNotifierProvider.notifier).logout();
                        ref.read(authStatusProvider.notifier).state =
                            AuthStatus.unauthenticated;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Cerrar sesion'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.secondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.gray500,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
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

class _SupervisorSmartVisionView extends StatelessWidget {
  const _SupervisorSmartVisionView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SupervisorSmartVisionContent();
  }
}

class _SupervisorSmartVisionContent extends StatelessWidget {
  const _SupervisorSmartVisionContent();

  @override
  Widget build(BuildContext context) {
    const riskItems = [
      _RiskEvent(
        title: 'Uso de telefono',
        driver: 'Ana Garcia',
        plate: 'DEF-5678',
        location: 'Autopista Panamericana, Km 58',
        timeAgo: 'Hace 12 min',
        level: 'Critico',
        levelColor: AppColors.danger,
        icon: Icons.phone_in_talk_outlined,
      ),
      _RiskEvent(
        title: 'Conduccion agresiva',
        driver: 'Miguel Torres',
        plate: 'GHI-9012',
        location: 'Av. Libertador 3400',
        timeAgo: 'Hace 18 min',
        level: 'Advertencia',
        levelColor: AppColors.warning,
        icon: Icons.flash_on_outlined,
      ),
      _RiskEvent(
        title: 'Exceso de velocidad',
        driver: 'Laura Ruiz',
        plate: 'JKL-3456',
        location: 'Ruta Provincial 6, Km 78',
        timeAgo: 'Hace 25 min',
        level: 'Critico',
        levelColor: AppColors.danger,
        icon: Icons.trending_up_rounded,
      ),
      _RiskEvent(
        title: 'Frenado brusco',
        driver: 'Carlos Mendez',
        plate: 'ABC-1234',
        location: 'Ruta Nacional 9, Km 145',
        timeAgo: 'Hace 35 min',
        level: 'Advertencia',
        levelColor: AppColors.warning,
        icon: Icons.warning_amber_rounded,
      ),
    ];

    const categoryStats = [
      _CategoryStat('Uso de telefono', 12, 0.5, AppColors.danger, Icons.phone_in_talk_outlined),
      _CategoryStat('Exceso de velocidad', 15, 0.64, AppColors.danger, Icons.trending_up_rounded),
      _CategoryStat('Conduccion agresiva', 6, 0.26, AppColors.warning, Icons.flash_on_outlined),
      _CategoryStat('Frenados bruscos', 8, 0.32, AppColors.warning, Icons.warning_amber_rounded),
      _CategoryStat('Riesgo de colision', 4, 0.14, AppColors.danger, Icons.error_outline_rounded),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology_alt_outlined,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SmartVision AI',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Centro de operaciones con inteligencia artificial',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.gray600,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _StatCard(
            title: 'Nivel de seguridad',
            value: '94%',
            trend: 'Excelente',
            icon: Icons.shield_outlined,
            accentBg: Color(0xFFE7F7F4),
            accent: AppColors.secondary,
          ),
          const SizedBox(height: 14),
          const _StatCard(
            title: 'Vehiculos monitoreados',
            value: '42',
            trend: 'Seguimiento GPS activo',
            icon: Icons.monitor_heart_outlined,
            accentBg: Color(0xFFE8FBF6),
            accent: Color(0xFF14B8A6),
          ),
          const SizedBox(height: 14),
          const _StatCard(
            title: 'Alertas hoy',
            value: '24',
            trend: '18% vs. ayer',
            icon: Icons.info_outline_rounded,
            accentBg: Color(0xFFFFF4E5),
            accent: AppColors.warning,
          ),
          const SizedBox(height: 14),
          const _StatCard(
            title: 'Eventos criticos',
            value: '3',
            trend: 'Requieren atencion inmediata',
            icon: Icons.warning_amber_rounded,
            accentBg: Color(0xFFFFECEB),
            accent: AppColors.danger,
          ),
          const SizedBox(height: 18),
          _DashboardCard(
            title: 'Deteccion de riesgos en tiempo real',
            child: Column(
              children: riskItems
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _RiskEventCard(event: item),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          _DashboardCard(
            title: 'Deteccion por categoria',
            child: Column(
              children: categoryStats
                  .map(
                    (stat) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _CategoryProgressRow(stat: stat),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupervisorVehiclesView extends StatelessWidget {
  const _SupervisorVehiclesView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SupervisorVehiclesContent();
  }
}

class _SupervisorVehiclesContent extends StatelessWidget {
  const _SupervisorVehiclesContent();

  @override
  Widget build(BuildContext context) {
    const vehicles = [
      _VehicleRow(
        plate: 'ABC-1234',
        type: 'Camion de carga',
        capacity: '5,000 kg',
        status: 'Operativo',
        statusColor: Color(0xFF10B981),
        lastMaintenance: '2026-05-15',
      ),
      _VehicleRow(
        plate: 'DEF-5678',
        type: 'Trailer',
        capacity: '20,000 kg',
        status: 'Operativo',
        statusColor: Color(0xFF10B981),
        lastMaintenance: '2026-05-20',
      ),
      _VehicleRow(
        plate: 'GHI-9012',
        type: 'Camioneta',
        capacity: '1,500 kg',
        status: 'Mantenimiento',
        statusColor: AppColors.warning,
        lastMaintenance: '2026-04-10',
      ),
      _VehicleRow(
        plate: 'JKL-3456',
        type: 'Furgoneta',
        capacity: '2,500 kg',
        status: 'Operativo',
        statusColor: Color(0xFF10B981),
        lastMaintenance: '2026-05-28',
      ),
      _VehicleRow(
        plate: 'MNO-7890',
        type: 'Camion de carga',
        capacity: '8,000 kg',
        status: 'Fuera de servicio',
        statusColor: AppColors.danger,
        lastMaintenance: '2026-03-05',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestion de Vehiculos',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Administra tu flota de vehiculos de transporte',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.gray600,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 20),
          const _StatCard(
            title: 'Total de vehiculos',
            value: '5',
            trend: null,
            icon: Icons.local_shipping_outlined,
            accentBg: Color(0xFFE7F7F4),
            accent: AppColors.secondary,
          ),
          const SizedBox(height: 14),
          const _StatCard(
            title: 'Vehiculos operativos',
            value: '3',
            trend: null,
            icon: Icons.trending_up_rounded,
            accentBg: Color(0xFFE8FBF0),
            accent: Color(0xFF10B981),
          ),
          const SizedBox(height: 14),
          const _StatCard(
            title: 'En mantenimiento',
            value: '1',
            trend: null,
            icon: Icons.build_outlined,
            accentBg: Color(0xFFFFF4E5),
            accent: AppColors.warning,
          ),
          const SizedBox(height: 14),
          const _StatCard(
            title: 'Capacidad disponible',
            value: '27.5t',
            trend: null,
            icon: Icons.inventory_2_outlined,
            accentBg: Color(0xFFEEF3FF),
            accent: AppColors.primary,
          ),
          const SizedBox(height: 18),
          const _VehicleFilterCard(),
          const SizedBox(height: 18),
          _DashboardCard(
            title: 'Flota registrada',
            child: _SimpleDataTable(
              headers: const ['Matricula', 'Tipo de vehiculo', 'Capacidad', 'Estado'],
              rows: vehicles
                  .map(
                    (vehicle) => [
                      _TableTextCell(vehicle.plate, emphasized: true),
                      _TableTextCell(vehicle.type),
                      _TableTextCell(vehicle.capacity),
                      _StatusPill(vehicle.status, vehicle.statusColor),
                    ],
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          _DashboardCard(
            title: 'Mantenimiento y acciones',
            child: _SimpleDataTable(
              headers: const ['Ultimo mantenimiento', 'Matricula', 'Acciones'],
              rows: vehicles
                  .map(
                    (vehicle) => [
                      _TableTextCell(vehicle.lastMaintenance),
                      _TableTextCell(vehicle.plate, emphasized: true),
                      const _ActionButtonsCell(),
                    ],
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupervisorDriversView extends StatelessWidget {
  const _SupervisorDriversView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SupervisorDriversContent();
  }
}

class _SupervisorDriversContent extends StatefulWidget {
  const _SupervisorDriversContent();

  @override
  State<_SupervisorDriversContent> createState() =>
      _SupervisorDriversContentState();
}

class _SupervisorDriversContentState extends State<_SupervisorDriversContent> {
  String _selectedStatus = 'Todos los estados';

  @override
  Widget build(BuildContext context) {
    const drivers = [
      _DriverRecord(
        name: 'Carlos Mendez',
        license: 'B1234567',
        phone: '+54 9 11 1234-5678',
        vehicle: 'ABC-1234',
        assignment: 'RT-2024-156',
        location: 'Ruta Nacional 9, Km 145',
        status: 'En ruta',
        statusColor: AppColors.primary,
        deliveriesToday: 8,
        efficiency: 95,
      ),
      _DriverRecord(
        name: 'Ana Garcia',
        license: 'B2345678',
        phone: '+54 9 11 2345-6789',
        vehicle: 'DEF-5678',
        assignment: 'Centro de distribucion',
        location: 'Base operativa Norte',
        status: 'Disponible',
        statusColor: Color(0xFF10B981),
        deliveriesToday: 12,
        efficiency: 98,
      ),
      _DriverRecord(
        name: 'Miguel Torres',
        license: 'B3456789',
        phone: '+54 9 11 3456-7890',
        vehicle: 'GHI-9012',
        assignment: 'RT-2024-157',
        location: 'Autopista Panamericana, Km 58',
        status: 'En ruta',
        statusColor: AppColors.primary,
        deliveriesToday: 6,
        efficiency: 87,
      ),
      _DriverRecord(
        name: 'Laura Ruiz',
        license: 'B4567890',
        phone: '+54 9 11 4567-8901',
        vehicle: 'JKL-3456',
        assignment: 'Area de servicio - Km 120',
        location: 'Corredor logistico Sur',
        status: 'Descansando',
        statusColor: AppColors.warning,
        deliveriesToday: 10,
        efficiency: 92,
      ),
      _DriverRecord(
        name: 'Roberto Fernandez',
        license: 'B5678901',
        phone: '+54 9 11 5678-9012',
        vehicle: 'MNO-7890',
        assignment: 'Sin ruta asignada',
        location: 'Ultima ubicacion: Centro',
        status: 'Offline',
        statusColor: AppColors.gray400,
        deliveriesToday: 0,
        efficiency: 0,
      ),
      _DriverRecord(
        name: 'Patricia Lopez',
        license: 'B6789012',
        phone: '+54 9 11 6789-0123',
        vehicle: 'PQR-1234',
        assignment: 'RT-2024-158',
        location: 'Av. Libertador 3400',
        status: 'En ruta',
        statusColor: AppColors.primary,
        deliveriesToday: 9,
        efficiency: 94,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestion de conductores',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Administra y monitorea tu equipo de conductores',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.gray600,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 20),
          const _DriverStatsGrid(),
          const SizedBox(height: 18),
          _DashboardCard(
            title: 'Busqueda y filtros',
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, licencia o telefono...',
                    hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.gray400,
                        ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.gray400,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFDCE5EF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.secondary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(
                      value: 'Todos los estados',
                      child: Text('Todos los estados'),
                    ),
                    DropdownMenuItem(
                      value: 'Disponible',
                      child: Text('Disponible'),
                    ),
                    DropdownMenuItem(
                      value: 'En ruta',
                      child: Text('En ruta'),
                    ),
                    DropdownMenuItem(
                      value: 'Descansando',
                      child: Text('Descansando'),
                    ),
                    DropdownMenuItem(
                      value: 'Offline',
                      child: Text('Offline'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFDCE5EF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.secondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...drivers.map(
            (driver) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _DriverCard(driver: driver),
            ),
          ),
          const SizedBox(height: 18),
          const _DriversMapCard(),
        ],
      ),
    );
  }
}

class _DriverStatsGrid extends StatelessWidget {
  const _DriverStatsGrid();

  @override
  Widget build(BuildContext context) {
    const stats = [
      ('Total', '6', null, Icons.people_outline_rounded, Color(0xFFE9F7F7), AppColors.secondary),
      ('Disponibles', '1', null, Icons.trending_up_rounded, Color(0xFFEAFBF0), Color(0xFF10B981)),
      ('En ruta', '3', null, Icons.navigation_outlined, Color(0xFFEEF3FF), AppColors.primary),
      ('Offline', '1', null, Icons.signal_wifi_off_rounded, Color(0xFFF3F4F6), AppColors.gray500),
      ('Entregas hoy', '45', null, Icons.inventory_2_outlined, Color(0xFFFFF5E7), AppColors.warning),
      ('Eficiencia', '78%', null, Icons.monitor_heart_outlined, Color(0xFFE8FBF6), Color(0xFF14B8A6)),
    ];

    return Column(
      children: stats
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DriverMetricCard(
                label: item.$1,
                value: item.$2,
                icon: item.$4,
                accentBg: item.$5,
                accent: item.$6,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DriverMetricCard extends StatelessWidget {
  const _DriverMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentBg,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentBg;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE5EF)),
        gradient: LinearGradient(
          colors: [
            accentBg.withValues(alpha: 0.9),
            AppColors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
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

class _DriverRecord {
  const _DriverRecord({
    required this.name,
    required this.license,
    required this.phone,
    required this.vehicle,
    required this.assignment,
    required this.location,
    required this.status,
    required this.statusColor,
    required this.deliveriesToday,
    required this.efficiency,
  });

  final String name;
  final String license;
  final String phone;
  final String vehicle;
  final String assignment;
  final String location;
  final String status;
  final Color statusColor;
  final int deliveriesToday;
  final int efficiency;
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.driver});

  final _DriverRecord driver;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCE5EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lic. ${driver.license}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(driver.status, driver.statusColor),
            ],
          ),
          const SizedBox(height: 14),
          _DriverInfoRow(
            icon: Icons.phone_outlined,
            text: driver.phone,
          ),
          const SizedBox(height: 10),
          _DriverInfoRow(
            icon: Icons.local_shipping_outlined,
            text: driver.vehicle,
          ),
          const SizedBox(height: 10),
          _DriverInfoRow(
            icon: Icons.navigation_outlined,
            text: driver.assignment,
          ),
          const SizedBox(height: 10),
          _DriverInfoRow(
            icon: Icons.location_on_outlined,
            text: driver.location,
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFDCE5EF)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Entregas hoy: ${driver.deliveriesToday}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ),
              Text(
                'Eficiencia: ${driver.efficiency}%',
                style: textTheme.bodyMedium?.copyWith(
                  color: driver.efficiency == 0
                      ? AppColors.danger
                      : const Color(0xFF10B981),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DriverInfoRow extends StatelessWidget {
  const _DriverInfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.gray500),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.text,
                  height: 1.35,
                ),
          ),
        ),
      ],
    );
  }
}

class _DriversMapCard extends StatelessWidget {
  const _DriversMapCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Mapa de conductores',
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: const Color(0xFFFBFDFF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE8EEF5)),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 62,
                  color: AppColors.gray500,
                ),
                const SizedBox(height: 14),
                Text(
                  'Mapa de conductores',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Visualizacion GPS en tiempo real de 3 conductores activos',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.gray600,
                        height: 1.45,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SupervisorOrdersView extends StatelessWidget {
  const _SupervisorOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SupervisorOrdersContent();
  }
}

class _SupervisorOrdersContent extends StatefulWidget {
  const _SupervisorOrdersContent();

  @override
  State<_SupervisorOrdersContent> createState() =>
      _SupervisorOrdersContentState();
}

class _SupervisorOrdersContentState extends State<_SupervisorOrdersContent> {
  String _selectedStatus = 'Todos los estados';

  @override
  Widget build(BuildContext context) {
    const orders = [
      _SupervisorOrder(
        id: 'ORD-2026-001',
        client: 'Juan Perez',
        company: 'Distribuidora del Norte S.A.',
        cargoType: 'Electronica',
        cargoDetail: '500 kg • 25 cajas',
        origin: 'Av. Libertador 1500, CABA',
        destination: 'Av. Belgrano 3200, Cordoba',
        route: 'RT-2024-156',
        driver: 'Carlos Mendez',
        deliveryDate: '2026-06-09',
        status: 'En transito',
        statusColor: AppColors.secondary,
      ),
      _SupervisorOrder(
        id: 'ORD-2026-002',
        client: 'Maria Gonzalez',
        company: 'Alimentos Premium Ltda.',
        cargoType: 'Alimentos perecederos',
        cargoDetail: '800 kg • 40 cajas',
        origin: 'Calle Corrientes 2340, CABA',
        destination: 'Av. Santa Fe 4567, Rosario',
        route: 'RT-2024-157',
        driver: 'Ana Garcia',
        deliveryDate: '2026-06-08',
        status: 'Retrasada',
        statusColor: AppColors.danger,
      ),
      _SupervisorOrder(
        id: 'ORD-2026-003',
        client: 'Roberto Fernandez',
        company: 'Construcciones del Sur',
        cargoType: 'Materiales de construccion',
        cargoDetail: '2,500 kg • 100 unidades',
        origin: 'Av. Rivadavia 5678, CABA',
        destination: 'Calle Florida 890, Mendoza',
        route: 'Sin asignar',
        driver: 'Sin asignar',
        deliveryDate: '2026-06-12',
        status: 'Pendiente',
        statusColor: AppColors.primary,
      ),
      _SupervisorOrder(
        id: 'ORD-2026-004',
        client: 'Laura Ruiz',
        company: 'Textiles Modernos S.R.L.',
        cargoType: 'Textiles',
        cargoDetail: '350 kg • 50 rollos',
        origin: 'Av. 9 de Julio 1200, CABA',
        destination: 'Av. Cordoba 3400, La Plata',
        route: 'RT-2024-159',
        driver: 'Laura Ruiz',
        deliveryDate: '2026-06-07',
        status: 'Entregada',
        statusColor: Color(0xFF10B981),
      ),
      _SupervisorOrder(
        id: 'ORD-2026-005',
        client: 'Diego Martinez',
        company: 'Farmacia Central',
        cargoType: 'Medicamentos',
        cargoDetail: '150 kg • 30 cajas',
        origin: 'Calle Lavalle 4567, CABA',
        destination: 'Av. Del Libertador 8900, San Nicolas',
        route: 'RT-2024-160',
        driver: 'Miguel Torres',
        deliveryDate: '2026-06-11',
        status: 'Asignada',
        statusColor: Color(0xFF0F766E),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestion de Ordenes',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Administra solicitudes de transporte de carga',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.gray600,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 18),
          _OrderActions(
            onAnalytics: () {},
            onNewOrder: () {},
          ),
          const SizedBox(height: 18),
          const _OrderStatsGrid(),
          const SizedBox(height: 18),
          _DashboardCard(
            title: 'Busqueda y filtros',
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por orden, cliente, empresa o tipo de carga...',
                    hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.gray400,
                        ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.gray400,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFDCE5EF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.secondary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(
                      value: 'Todos los estados',
                      child: Text('Todos los estados'),
                    ),
                    DropdownMenuItem(
                      value: 'Pendiente',
                      child: Text('Pendiente'),
                    ),
                    DropdownMenuItem(
                      value: 'Asignada',
                      child: Text('Asignada'),
                    ),
                    DropdownMenuItem(
                      value: 'En transito',
                      child: Text('En transito'),
                    ),
                    DropdownMenuItem(
                      value: 'Entregada',
                      child: Text('Entregada'),
                    ),
                    DropdownMenuItem(
                      value: 'Retrasada',
                      child: Text('Retrasada'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFDCE5EF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.secondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...orders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _SupervisorOrderCard(order: order),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderActions extends StatelessWidget {
  const _OrderActions({
    required this.onAnalytics,
    required this.onNewOrder,
  });

  final VoidCallback onAnalytics;
  final VoidCallback onNewOrder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton(
          onPressed: onAnalytics,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.text,
            side: const BorderSide(color: Color(0xFFDCE5EF)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Ver analiticas'),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: onNewOrder,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Nueva orden'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}

class _OrderStatsGrid extends StatelessWidget {
  const _OrderStatsGrid();

  @override
  Widget build(BuildContext context) {
    const stats = [
      ('Total de ordenes', '5', Icons.inventory_2_outlined, Color(0xFFE8FBF6), AppColors.secondary),
      ('Pendientes', '1', Icons.schedule_outlined, Color(0xFFF3F4F6), AppColors.gray500),
      ('Asignadas', '1', Icons.inventory_2_rounded, Color(0xFFEEF3FF), AppColors.primary),
      ('En transito', '1', Icons.location_on_outlined, Color(0xFFE9F7F7), AppColors.secondary),
      ('Entregadas', '1', Icons.check_circle_outline_rounded, Color(0xFFEAFBF0), Color(0xFF10B981)),
      ('Retrasadas', '1', Icons.error_outline_rounded, Color(0xFFFFECEB), AppColors.danger),
    ];

    return Column(
      children: stats
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OrderMetricCard(
                label: item.$1,
                value: item.$2,
                icon: item.$3,
                accentBg: item.$4,
                accent: item.$5,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _OrderMetricCard extends StatelessWidget {
  const _OrderMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentBg,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentBg;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE5EF)),
        gradient: LinearGradient(
          colors: [
            accentBg.withValues(alpha: 0.9),
            AppColors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
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

class _SupervisorOrder {
  const _SupervisorOrder({
    required this.id,
    required this.client,
    required this.company,
    required this.cargoType,
    required this.cargoDetail,
    required this.origin,
    required this.destination,
    required this.route,
    required this.driver,
    required this.deliveryDate,
    required this.status,
    required this.statusColor,
  });

  final String id;
  final String client;
  final String company;
  final String cargoType;
  final String cargoDetail;
  final String origin;
  final String destination;
  final String route;
  final String driver;
  final String deliveryDate;
  final String status;
  final Color statusColor;
}

class _SupervisorOrderCard extends StatelessWidget {
  const _SupervisorOrderCard({required this.order});

  final _SupervisorOrder order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCE5EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.id,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.client,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.company,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(order.status, order.statusColor),
            ],
          ),
          const SizedBox(height: 14),
          _OrderInfoBlock(
            icon: Icons.inventory_2_outlined,
            title: order.cargoType,
            subtitle: order.cargoDetail,
          ),
          const SizedBox(height: 10),
          _OrderInfoBlock(
            icon: Icons.upload_rounded,
            title: 'Origen',
            subtitle: order.origin,
          ),
          const SizedBox(height: 10),
          _OrderInfoBlock(
            icon: Icons.download_rounded,
            title: 'Destino',
            subtitle: order.destination,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _OrderInfoBlock(
                  icon: Icons.route_outlined,
                  title: 'Ruta asignada',
                  subtitle: order.route,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OrderInfoBlock(
                  icon: Icons.person_outline_rounded,
                  title: 'Conductor',
                  subtitle: order.driver,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _OrderInfoBlock(
            icon: Icons.event_outlined,
            title: 'Fecha entrega',
            subtitle: order.deliveryDate,
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFDCE5EF)),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: Color(0xFFDCE5EF)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Ver detalles'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text('Editar orden'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderInfoBlock extends StatelessWidget {
  const _OrderInfoBlock({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.gray500),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gray500,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.text,
                      height: 1.35,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SupervisorRoutesView extends StatelessWidget {
  const _SupervisorRoutesView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SupervisorRoutesContent();
  }
}

class _SupervisorRoutesContent extends StatefulWidget {
  const _SupervisorRoutesContent();

  @override
  State<_SupervisorRoutesContent> createState() =>
      _SupervisorRoutesContentState();
}

class _SupervisorRoutesContentState extends State<_SupervisorRoutesContent> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    const alerts = [
      _RouteAlert(
        title: 'Vehiculo ABC-1234 se ha desviado de la ruta planificada',
        routeId: 'RT-2024-156',
        timeAgo: 'Hace 5 min',
        color: AppColors.danger,
        background: Color(0xFFFFF0EF),
        icon: Icons.navigation_outlined,
      ),
      _RouteAlert(
        title: 'Vehiculo DEF-5678 ha ingresado al area de destino',
        routeId: 'RT-2024-157',
        timeAgo: 'Hace 12 min',
        color: AppColors.primary,
        background: Color(0xFFF0F5FF),
        icon: Icons.location_on_outlined,
      ),
      _RouteAlert(
        title: 'Parada prolongada detectada en vehiculo GHI-9012',
        routeId: 'RT-2024-158',
        timeAgo: 'Hace 18 min',
        color: AppColors.warning,
        background: Color(0xFFFFF6E9),
        icon: Icons.warning_amber_rounded,
      ),
      _RouteAlert(
        title: 'Entrega completada - Vehiculo JKL-3456',
        routeId: 'RT-2024-159',
        timeAgo: 'Hace 25 min',
        color: AppColors.primary,
        background: Color(0xFFF0F5FF),
        icon: Icons.check_circle_outline_rounded,
      ),
    ];

    const stops = [
      _RouteStop(
        title: 'Centro de distribucion - Av. Libertador 1500',
        subtitle: 'Origen',
        detail: 'Llegada: 08:00   Salida: 08:15',
        state: 'GPS',
        color: Color(0xFF10B981),
        icon: Icons.check_circle_outline_rounded,
      ),
      _RouteStop(
        title: 'Cliente A - Calle Corrientes 2340',
        subtitle: 'Punto de entrega',
        detail: 'Llegada: 09:45   Salida: 10:00',
        state: 'GPS',
        color: Color(0xFF10B981),
        icon: Icons.check_circle_outline_rounded,
      ),
      _RouteStop(
        title: 'Cliente B - Av. Santa Fe 4567',
        subtitle: 'Punto de entrega',
        detail: 'Llegada: 11:20',
        state: null,
        color: AppColors.primary,
        icon: Icons.navigation_outlined,
      ),
      _RouteStop(
        title: 'Cliente C - Calle Florida 890',
        subtitle: 'Punto de entrega',
        detail: null,
        state: null,
        color: AppColors.primary,
        icon: Icons.navigation_outlined,
      ),
      _RouteStop(
        title: 'Almacen final - Av. Belgrano 3200',
        subtitle: 'Destino',
        detail: null,
        state: null,
        color: AppColors.danger,
        icon: Icons.location_on_outlined,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RoutesHeader(
            selectedTab: _selectedTab,
            onTabSelected: (index) {
              setState(() {
                _selectedTab = index;
              });
            },
          ),
          const SizedBox(height: 18),
          const _RoutesStatsGrid(),
          const SizedBox(height: 18),
          const _RoutesMapCard(),
          const SizedBox(height: 18),
          _DashboardCard(
            title: 'Alertas de geolocalizacion',
            child: Column(
              children: [
                ...alerts.map(
                  (alert) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RouteAlertCard(alert: alert),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.text,
                      side: const BorderSide(color: Color(0xFFDCE5EF)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Ver todas las alertas'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _DashboardCard(
            title: 'Puntos de entrega',
            child: Column(
              children: [
                for (var index = 0; index < stops.length; index++)
                  _RouteStopTile(
                    stop: stops[index],
                    isLast: index == stops.length - 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutesHeader extends StatelessWidget {
  const _RoutesHeader({
    required this.selectedTab,
    required this.onTabSelected,
  });

  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.list_rounded, size: 18),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ver todas las rutas'),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text('5'),
              ),
            ],
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _RouteTabButton(
                label: 'Monitoreo GPS',
                icon: Icons.location_on_outlined,
                selected: selectedTab == 0,
                onTap: () => onTabSelected(0),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RouteTabButton(
                label: 'Optimizacion y Comunicacion',
                icon: Icons.psychology_alt_outlined,
                selected: selectedTab == 1,
                onTap: () => onTabSelected(1),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RouteTabButton extends StatelessWidget {
  const _RouteTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : AppColors.gray50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.secondary : const Color(0xFFDCE5EF),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.white : AppColors.gray500,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: selected ? AppColors.white : AppColors.gray600,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutesStatsGrid extends StatelessWidget {
  const _RoutesStatsGrid();

  @override
  Widget build(BuildContext context) {
    const stats = [
      ('Rutas activas', '4', Icons.navigation_outlined, Color(0xFFE9F7F7), AppColors.secondary),
      ('A tiempo', '2', Icons.trending_up_rounded, Color(0xFFEAFBF0), Color(0xFF10B981)),
      ('Con retraso', '1', Icons.access_time_rounded, Color(0xFFFFF6E9), AppColors.warning),
    ];

    return Column(
      children: stats
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RouteMetricCard(
                label: item.$1,
                value: item.$2,
                icon: item.$3,
                accentBg: item.$4,
                accent: item.$5,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _RouteMetricCard extends StatelessWidget {
  const _RouteMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentBg,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentBg;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE5EF)),
        gradient: LinearGradient(
          colors: [
            accentBg.withValues(alpha: 0.9),
            AppColors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
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

class _RoutesMapCard extends StatelessWidget {
  const _RoutesMapCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Mapa interactivo GPS',
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: const Color(0xFFFBFDFF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE8EEF5)),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 62,
                  color: AppColors.gray500,
                ),
                const SizedBox(height: 14),
                Text(
                  'Mapa interactivo GPS',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Seguimiento en tiempo real de 4 vehiculos activos',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.gray600,
                        height: 1.45,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecciona una ruta para ver detalles en el mapa',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray500,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteAlert {
  const _RouteAlert({
    required this.title,
    required this.routeId,
    required this.timeAgo,
    required this.color,
    required this.background,
    required this.icon,
  });

  final String title;
  final String routeId;
  final String timeAgo;
  final Color color;
  final Color background;
  final IconData icon;
}

class _RouteAlertCard extends StatelessWidget {
  const _RouteAlertCard({required this.alert});

  final _RouteAlert alert;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alert.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: alert.color.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(alert.icon, size: 20, color: alert.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: textTheme.titleMedium?.copyWith(
                    color: alert.color,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  alert.routeId,
                  style: textTheme.bodyMedium?.copyWith(
                    color: alert.color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            alert.timeAgo,
            style: textTheme.bodyMedium?.copyWith(
              color: alert.color.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteStop {
  const _RouteStop({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.state,
    required this.color,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String? detail;
  final String? state;
  final Color color;
  final IconData icon;
}

class _RouteStopTile extends StatelessWidget {
  const _RouteStopTile({
    required this.stop,
    required this.isLast,
  });

  final _RouteStop stop;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: stop.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: stop.color.withValues(alpha: 0.26)),
                ),
                child: Icon(stop.icon, color: stop.color, size: 22),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: const Color(0xFFDCE5EF),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          stop.title,
                          style: textTheme.titleLarge?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (stop.state != null) ...[
                        const SizedBox(width: 8),
                        _StatusPill(stop.state!, Color(0xFF10B981)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stop.subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                  if (stop.detail != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      stop.detail!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray600,
                        height: 1.4,
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

class _SupervisorIncidentsView extends StatelessWidget {
  const _SupervisorIncidentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SupervisorIncidentsContent();
  }
}

class _SupervisorIncidentsContent extends StatefulWidget {
  const _SupervisorIncidentsContent();

  @override
  State<_SupervisorIncidentsContent> createState() =>
      _SupervisorIncidentsContentState();
}

class _SupervisorIncidentsContentState
    extends State<_SupervisorIncidentsContent> {
  String _selectedStatus = 'Todos los estados';

  @override
  Widget build(BuildContext context) {
    const incidents = [
      _SupervisorIncident(
        title: 'Vehiculo averiado en Ruta Nacional 9',
        id: 'INC-2024-001',
        driver: 'Carlos Mendez',
        vehicle: 'ABC-1234',
        location: 'Ruta Nacional 9, Km 145',
        dateTime: '06 Jun 2026, 14:20',
        severity: 'Critica',
        severityColor: AppColors.danger,
        status: 'En progreso',
        statusColor: AppColors.warning,
        icon: Icons.error_outline_rounded,
      ),
      _SupervisorIncident(
        title: 'Retraso por congestion de trafico',
        id: 'INC-2024-002',
        driver: 'Ana Garcia',
        vehicle: 'DEF-5678',
        location: 'Autopista Panamericana, Km 58',
        dateTime: '06 Jun 2026, 13:45',
        severity: 'Media',
        severityColor: AppColors.primary,
        status: 'Asignado',
        statusColor: Color(0xFF9333EA),
        icon: Icons.warning_amber_rounded,
      ),
      _SupervisorIncident(
        title: 'Desviacion no autorizada de ruta',
        id: 'INC-2024-003',
        driver: 'Miguel Torres',
        vehicle: 'GHI-9012',
        location: 'Av. Libertador 3400',
        dateTime: '06 Jun 2026, 12:30',
        severity: 'Alta',
        severityColor: AppColors.warning,
        status: 'Reportado',
        statusColor: AppColors.primary,
        icon: Icons.warning_amber_rounded,
      ),
      _SupervisorIncident(
        title: 'Problema con carga - embalaje danado',
        id: 'INC-2024-004',
        driver: 'Laura Ruiz',
        vehicle: 'JKL-3456',
        location: 'Centro de distribucion',
        dateTime: '06 Jun 2026, 11:15',
        severity: 'Media',
        severityColor: AppColors.primary,
        status: 'En revision',
        statusColor: AppColors.warning,
        icon: Icons.inventory_2_outlined,
      ),
      _SupervisorIncident(
        title: 'Entrega completada con retraso',
        id: 'INC-2024-005',
        driver: 'Roberto Fernandez',
        vehicle: 'MNO-7890',
        location: 'Cliente Final - Calle Florida 890',
        dateTime: '06 Jun 2026, 10:00',
        severity: 'Baja',
        severityColor: AppColors.gray500,
        status: 'Resuelto',
        statusColor: Color(0xFF10B981),
        icon: Icons.check_circle_outline_rounded,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _IncidentsStatsGrid(),
          const SizedBox(height: 18),
          _DashboardCard(
            title: 'Acciones y filtros',
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Reportar incidente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar incidentes...',
                    hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.gray400,
                        ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.gray400,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFDCE5EF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.secondary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(
                      value: 'Todos los estados',
                      child: Text('Todos los estados'),
                    ),
                    DropdownMenuItem(
                      value: 'Reportado',
                      child: Text('Reportado'),
                    ),
                    DropdownMenuItem(
                      value: 'Asignado',
                      child: Text('Asignado'),
                    ),
                    DropdownMenuItem(
                      value: 'En progreso',
                      child: Text('En progreso'),
                    ),
                    DropdownMenuItem(
                      value: 'En revision',
                      child: Text('En revision'),
                    ),
                    DropdownMenuItem(
                      value: 'Resuelto',
                      child: Text('Resuelto'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFDCE5EF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.secondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...incidents.map(
            (incident) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _SupervisorIncidentCard(incident: incident),
            ),
          ),
          const SizedBox(height: 18),
          const _IncidentsMapCard(),
        ],
      ),
    );
  }
}

class _IncidentsStatsGrid extends StatelessWidget {
  const _IncidentsStatsGrid();

  @override
  Widget build(BuildContext context) {
    const stats = [
      ('Abiertos', '5', Icons.warning_amber_rounded, Color(0xFFF0F5FF), AppColors.primary),
      ('En progreso', '1', Icons.access_time_rounded, Color(0xFFFFF6E9), AppColors.warning),
      ('Resueltos', '1', Icons.trending_up_rounded, Color(0xFFEAFBF0), Color(0xFF10B981)),
      ('Criticos', '1', Icons.shield_outlined, Color(0xFFFFF0EF), AppColors.danger),
    ];

    return Column(
      children: stats
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _IncidentMetricCard(
                label: item.$1,
                value: item.$2,
                icon: item.$3,
                accentBg: item.$4,
                accent: item.$5,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _IncidentMetricCard extends StatelessWidget {
  const _IncidentMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentBg,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentBg;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE5EF)),
        gradient: LinearGradient(
          colors: [
            accentBg.withValues(alpha: 0.9),
            AppColors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
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

class _SupervisorIncident {
  const _SupervisorIncident({
    required this.title,
    required this.id,
    required this.driver,
    required this.vehicle,
    required this.location,
    required this.dateTime,
    required this.severity,
    required this.severityColor,
    required this.status,
    required this.statusColor,
    required this.icon,
  });

  final String title;
  final String id;
  final String driver;
  final String vehicle;
  final String location;
  final String dateTime;
  final String severity;
  final Color severityColor;
  final String status;
  final Color statusColor;
  final IconData icon;
}

class _SupervisorIncidentCard extends StatelessWidget {
  const _SupervisorIncidentCard({required this.incident});

  final _SupervisorIncident incident;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCE5EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: incident.severityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  incident.icon,
                  color: incident.severityColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      incident.id,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(incident.severity, incident.severityColor),
            ],
          ),
          const SizedBox(height: 14),
          _DriverInfoRow(
            icon: Icons.person_outline_rounded,
            text: incident.driver,
          ),
          const SizedBox(height: 10),
          _DriverInfoRow(
            icon: Icons.local_shipping_outlined,
            text: incident.vehicle,
          ),
          const SizedBox(height: 10),
          _DriverInfoRow(
            icon: Icons.location_on_outlined,
            text: incident.location,
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFDCE5EF)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  incident.dateTime,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ),
              _StatusPill(incident.status, incident.statusColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _IncidentsMapCard extends StatelessWidget {
  const _IncidentsMapCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Mapa de incidentes',
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: const Color(0xFFFBFDFF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE8EEF5)),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 62,
                  color: AppColors.gray500,
                ),
                const SizedBox(height: 14),
                Text(
                  'Mapa de incidentes',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Visualizacion de ubicaciones de incidentes en tiempo real',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.gray600,
                        height: 1.45,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SupervisorMaintenanceView extends StatelessWidget {
  const _SupervisorMaintenanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SupervisorMaintenanceContent();
  }
}

class _SupervisorMaintenanceContent extends StatefulWidget {
  const _SupervisorMaintenanceContent();

  @override
  State<_SupervisorMaintenanceContent> createState() =>
      _SupervisorMaintenanceContentState();
}

class _SupervisorMaintenanceContentState
    extends State<_SupervisorMaintenanceContent> {
  int _selectedTab = 0;
  String _selectedStatus = 'Todos los estados';

  @override
  Widget build(BuildContext context) {
    const maintenances = [
      _MaintenanceRecord(
        id: 'MNT-2026-001',
        plate: 'ABC-1234',
        vehicleType: 'Camion de carga',
        maintenanceType: 'Preventivo',
        scheduledDate: '2026-06-08',
        technician: 'Roberto Martinez',
        priority: 'Media',
        priorityColor: AppColors.warning,
        status: 'Programado',
        statusColor: AppColors.primary,
      ),
      _MaintenanceRecord(
        id: 'MNT-2026-002',
        plate: 'DEF-5678',
        vehicleType: 'Trailer',
        maintenanceType: 'Cambio de aceite',
        scheduledDate: '2026-06-07',
        technician: 'Carlos Lopez',
        priority: 'Alta',
        priorityColor: AppColors.warning,
        status: 'En progreso',
        statusColor: AppColors.secondary,
      ),
      _MaintenanceRecord(
        id: 'MNT-2026-003',
        plate: 'GHI-9012',
        vehicleType: 'Camioneta',
        maintenanceType: 'Servicio de frenos',
        scheduledDate: '2026-06-05',
        technician: 'Juan Ramirez',
        priority: 'Critica',
        priorityColor: AppColors.danger,
        status: 'Completado',
        statusColor: Color(0xFF10B981),
      ),
      _MaintenanceRecord(
        id: 'MNT-2026-004',
        plate: 'JKL-3456',
        vehicleType: 'Furgoneta',
        maintenanceType: 'Inspeccion',
        scheduledDate: '2026-06-04',
        technician: 'Miguel Torres',
        priority: 'Baja',
        priorityColor: AppColors.primary,
        status: 'Vencido',
        statusColor: AppColors.danger,
      ),
      _MaintenanceRecord(
        id: 'MNT-2026-005',
        plate: 'MNO-7890',
        vehicleType: 'Camion de carga',
        maintenanceType: 'Cambio de neumaticos',
        scheduledDate: '2026-06-09',
        technician: 'Diego Fernandez',
        priority: 'Alta',
        priorityColor: AppColors.warning,
        status: 'Pendiente',
        statusColor: AppColors.gray500,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestion de Mantenimiento',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Administra el mantenimiento de tu flota vehicular',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.gray600,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Programar mantenimiento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const _MaintenanceStatsGrid(),
          const SizedBox(height: 18),
          _DashboardCard(
            title: 'Vista',
            child: Row(
              children: [
                Expanded(
                  child: _RouteTabButton(
                    label: 'Lista',
                    icon: Icons.list_alt_rounded,
                    selected: _selectedTab == 0,
                    onTap: () {
                      setState(() {
                        _selectedTab = 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _RouteTabButton(
                    label: 'Calendario',
                    icon: Icons.calendar_month_rounded,
                    selected: _selectedTab == 1,
                    onTap: () {
                      setState(() {
                        _selectedTab = 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _RouteTabButton(
                    label: 'Analiticas',
                    icon: Icons.insert_chart_outlined,
                    selected: _selectedTab == 2,
                    onTap: () {
                      setState(() {
                        _selectedTab = 2;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _DashboardCard(
            title: 'Busqueda y filtros',
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por ID, placa o tecnico...',
                    hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.gray400,
                        ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.gray400,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFDCE5EF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.secondary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(
                      value: 'Todos los estados',
                      child: Text('Todos los estados'),
                    ),
                    DropdownMenuItem(
                      value: 'Programado',
                      child: Text('Programado'),
                    ),
                    DropdownMenuItem(
                      value: 'En progreso',
                      child: Text('En progreso'),
                    ),
                    DropdownMenuItem(
                      value: 'Completado',
                      child: Text('Completado'),
                    ),
                    DropdownMenuItem(
                      value: 'Vencido',
                      child: Text('Vencido'),
                    ),
                    DropdownMenuItem(
                      value: 'Pendiente',
                      child: Text('Pendiente'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFDCE5EF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.secondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (_selectedTab == 0) ...[
            ...maintenances.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _MaintenanceCard(record: record),
              ),
            ),
          ] else if (_selectedTab == 1) ...[
            const _MaintenanceCalendarCard(),
          ] else ...[
            const _MaintenanceAnalyticsCard(),
          ],
        ],
      ),
    );
  }
}

class _MaintenanceStatsGrid extends StatelessWidget {
  const _MaintenanceStatsGrid();

  @override
  Widget build(BuildContext context) {
    const stats = [
      ('Total de vehiculos', '25', Icons.local_shipping_outlined, Color(0xFFE8FBF6), AppColors.secondary),
      ('Vehiculos disponibles', '20', Icons.check_circle_outline_rounded, Color(0xFFEAFBF0), Color(0xFF10B981)),
      ('En mantenimiento', '1', Icons.build_outlined, Color(0xFFE9F7F7), AppColors.secondary),
      ('Programados', '1', Icons.calendar_month_rounded, Color(0xFFEEF3FF), AppColors.primary),
      ('Vencidos', '1', Icons.error_outline_rounded, Color(0xFFFFF0EF), AppColors.danger),
      ('Disponibilidad', '80.0%', Icons.trending_up_rounded, Color(0xFFEAFBF0), Color(0xFF10B981)),
    ];

    return Column(
      children: stats
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MaintenanceMetricCard(
                label: item.$1,
                value: item.$2,
                icon: item.$3,
                accentBg: item.$4,
                accent: item.$5,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MaintenanceMetricCard extends StatelessWidget {
  const _MaintenanceMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentBg,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentBg;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE5EF)),
        gradient: LinearGradient(
          colors: [
            accentBg.withValues(alpha: 0.9),
            AppColors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
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

class _MaintenanceRecord {
  const _MaintenanceRecord({
    required this.id,
    required this.plate,
    required this.vehicleType,
    required this.maintenanceType,
    required this.scheduledDate,
    required this.technician,
    required this.priority,
    required this.priorityColor,
    required this.status,
    required this.statusColor,
  });

  final String id;
  final String plate;
  final String vehicleType;
  final String maintenanceType;
  final String scheduledDate;
  final String technician;
  final String priority;
  final Color priorityColor;
  final String status;
  final Color statusColor;
}

class _MaintenanceCard extends StatelessWidget {
  const _MaintenanceCard({required this.record});

  final _MaintenanceRecord record;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCE5EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.id,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.plate,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.vehicleType,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(record.priority, record.priorityColor),
            ],
          ),
          const SizedBox(height: 14),
          _OrderInfoBlock(
            icon: Icons.build_outlined,
            title: 'Tipo de mantenimiento',
            subtitle: record.maintenanceType,
          ),
          const SizedBox(height: 10),
          _OrderInfoBlock(
            icon: Icons.event_outlined,
            title: 'Fecha programada',
            subtitle: record.scheduledDate,
          ),
          const SizedBox(height: 10),
          _OrderInfoBlock(
            icon: Icons.person_outline_rounded,
            title: 'Tecnico asignado',
            subtitle: record.technician,
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFDCE5EF)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatusPill(record.status, record.statusColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: Color(0xFFDCE5EF)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Ver detalles'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text('Editar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MaintenanceCalendarCard extends StatelessWidget {
  const _MaintenanceCalendarCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Calendario de mantenimiento',
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          color: const Color(0xFFFBFDFF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE8EEF5)),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 58,
                  color: AppColors.gray500,
                ),
                const SizedBox(height: 14),
                Text(
                  'Vista calendario',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Programacion visual de mantenimientos por fecha y prioridad',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.gray600,
                        height: 1.45,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MaintenanceAnalyticsCard extends StatelessWidget {
  const _MaintenanceAnalyticsCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Analiticas de mantenimiento',
      child: Column(
        children: const [
          _MaintenanceInsightRow(
            label: 'Mantenimientos completados este mes',
            value: '18',
            color: Color(0xFF10B981),
          ),
          SizedBox(height: 12),
          _MaintenanceInsightRow(
            label: 'Promedio de duracion por servicio',
            value: '2.4 h',
            color: AppColors.primary,
          ),
          SizedBox(height: 12),
          _MaintenanceInsightRow(
            label: 'Servicios vencidos',
            value: '1',
            color: AppColors.danger,
          ),
        ],
      ),
    );
  }
}

class _MaintenanceInsightRow extends StatelessWidget {
  const _MaintenanceInsightRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _SupervisorReportsView extends StatelessWidget {
  const _SupervisorReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SupervisorReportsContent();
  }
}

class _SupervisorReportsContent extends StatefulWidget {
  const _SupervisorReportsContent();

  @override
  State<_SupervisorReportsContent> createState() =>
      _SupervisorReportsContentState();
}

class _SupervisorReportsContentState extends State<_SupervisorReportsContent> {
  String _selectedPeriod = 'Ultimos 30 dias';

  @override
  Widget build(BuildContext context) {
    const reports = [
      _SupervisorReportItem(
        title: 'Rendimiento de flota',
        subtitle: 'Resumen de productividad, eficiencia y disponibilidad',
        period: 'Junio 2026',
        accent: AppColors.secondary,
        icon: Icons.local_shipping_outlined,
      ),
      _SupervisorReportItem(
        title: 'Entregas y cumplimiento',
        subtitle: 'Indicadores de entregas a tiempo y retrasos',
        period: 'Semana actual',
        accent: AppColors.primary,
        icon: Icons.inventory_2_outlined,
      ),
      _SupervisorReportItem(
        title: 'Seguridad e incidencias',
        subtitle: 'Eventos criticos, alertas y tiempos de respuesta',
        period: 'Ultimos 15 dias',
        accent: AppColors.danger,
        icon: Icons.warning_amber_rounded,
      ),
      _SupervisorReportItem(
        title: 'Mantenimiento preventivo',
        subtitle: 'Estado de servicios programados y vencimientos',
        period: 'Junio 2026',
        accent: AppColors.warning,
        icon: Icons.build_outlined,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reportes',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Consulta indicadores operativos y exporta resúmenes de gestión',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.gray600,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.file_download_outlined, size: 18),
              label: const Text('Exportar reporte general'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const _ReportsStatsGrid(),
          const SizedBox(height: 18),
          _DashboardCard(
            title: 'Filtros de reporte',
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedPeriod,
                  items: const [
                    DropdownMenuItem(
                      value: 'Ultimos 7 dias',
                      child: Text('Ultimos 7 dias'),
                    ),
                    DropdownMenuItem(
                      value: 'Ultimos 30 dias',
                      child: Text('Ultimos 30 dias'),
                    ),
                    DropdownMenuItem(
                      value: 'Este mes',
                      child: Text('Este mes'),
                    ),
                    DropdownMenuItem(
                      value: 'Trimestre',
                      child: Text('Trimestre'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedPeriod = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFDCE5EF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.secondary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar reporte o indicador...',
                    hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.gray400,
                        ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.gray400,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFDCE5EF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.secondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...reports.map(
            (report) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ReportCard(report: report),
            ),
          ),
          const SizedBox(height: 18),
          const _ReportsHighlightsCard(),
          const SizedBox(height: 18),
          const _ReportsPerformanceCard(),
        ],
      ),
    );
  }
}

class _ReportsStatsGrid extends StatelessWidget {
  const _ReportsStatsGrid();

  @override
  Widget build(BuildContext context) {
    const stats = [
      ('Reportes generados', '18', Icons.description_outlined, Color(0xFFE8FBF6), AppColors.secondary),
      ('Indicadores activos', '24', Icons.analytics_outlined, Color(0xFFEEF3FF), AppColors.primary),
      ('Alertas incluidas', '9', Icons.warning_amber_rounded, Color(0xFFFFF6E9), AppColors.warning),
      ('Cobertura operativa', '92%', Icons.trending_up_rounded, Color(0xFFEAFBF0), Color(0xFF10B981)),
    ];

    return Column(
      children: stats
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReportMetricCard(
                label: item.$1,
                value: item.$2,
                icon: item.$3,
                accentBg: item.$4,
                accent: item.$5,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ReportMetricCard extends StatelessWidget {
  const _ReportMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentBg,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentBg;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE5EF)),
        gradient: LinearGradient(
          colors: [
            accentBg.withValues(alpha: 0.9),
            AppColors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
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

class _SupervisorReportItem {
  const _SupervisorReportItem({
    required this.title,
    required this.subtitle,
    required this.period,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String period;
  final Color accent;
  final IconData icon;
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final _SupervisorReportItem report;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCE5EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: report.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(report.icon, color: report.accent, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.gray600,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDCE5EF)),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 18, color: AppColors.gray500),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    report.period,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray600,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: Color(0xFFDCE5EF)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Ver resumen'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text('Exportar PDF'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportsHighlightsCard extends StatelessWidget {
  const _ReportsHighlightsCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Hallazgos destacados',
      child: Column(
        children: const [
          _MaintenanceInsightRow(
            label: 'Mejora de puntualidad respecto al periodo anterior',
            value: '+8%',
            color: Color(0xFF10B981),
          ),
          SizedBox(height: 12),
          _MaintenanceInsightRow(
            label: 'Reduccion de incidentes en ruta',
            value: '-12%',
            color: AppColors.primary,
          ),
          SizedBox(height: 12),
          _MaintenanceInsightRow(
            label: 'Costo operativo promedio por entrega',
            value: '\$42',
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _ReportsPerformanceCard extends StatelessWidget {
  const _ReportsPerformanceCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Estado de indicadores',
      child: Column(
        children: const [
          _ReportProgressRow(
            label: 'Puntualidad',
            value: 0.92,
            color: Color(0xFF10B981),
          ),
          SizedBox(height: 14),
          _ReportProgressRow(
            label: 'Disponibilidad de flota',
            value: 0.80,
            color: AppColors.primary,
          ),
          SizedBox(height: 14),
          _ReportProgressRow(
            label: 'Cumplimiento de mantenimiento',
            value: 0.74,
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _ReportProgressRow extends StatelessWidget {
  const _ReportProgressRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: const Color(0xFFE9EFF6),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.overview});

  final SupervisorOverview overview;

  @override
  Widget build(BuildContext context) {
    final utilization = overview.totalVehicles == 0
        ? 0
        : ((overview.activeVehicles / overview.totalVehicles) * 100).round();

    final items = [
      ('Total de vehiculos', '${overview.totalVehicles}', null, Icons.local_shipping_outlined, const Color(0xFFE7F7F4), AppColors.secondary),
      ('Vehiculos activos', '${overview.activeVehicles}', '$utilization%', Icons.trending_up_rounded, const Color(0xFFE8FBF0), const Color(0xFF10B981)),
      ('En mantenimiento', '${overview.maintenanceVehicles}', null, Icons.build_outlined, const Color(0xFFFFF4E5), AppColors.warning),
      ('Conductores activos', '${overview.activeDrivers}', null, Icons.people_outline_rounded, const Color(0xFFEEF4FF), AppColors.primary),
      ('Ordenes activas', '${overview.activeOrders}', null, Icons.inventory_2_outlined, const Color(0xFFE8FBF6), const Color(0xFF14B8A6)),
      ('Rutas totales', '${overview.totalRoutes}', null, Icons.map_outlined, const Color(0xFFEEF3FF), const Color(0xFF3B82F6)),
      ('Rutas en progreso', '${overview.routesInProgress}', null, Icons.alt_route_rounded, const Color(0xFFEAF8F4), AppColors.secondary),
    ];

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _StatCard(
                title: item.$1,
                value: item.$2,
                trend: item.$3,
                icon: item.$4,
                accentBg: item.$5,
                accent: item.$6,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.accentBg,
    required this.accent,
  });

  final String title;
  final String value;
  final String? trend;
  final IconData icon;
  final Color accentBg;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCE5EF)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.gray600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  value,
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                if (trend != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '↑ $trend',
                    style: textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent, size: 28),
          ),
        ],
      ),
    );
  }
}

class _LineChartCard extends StatelessWidget {
  const _LineChartCard();

  @override
  Widget build(BuildContext context) {
    return const _DashboardCard(
      title: 'Rendimiento de flota',
      child: SizedBox(
        height: 220,
        child: CustomPaint(painter: _LineChartPainter()),
      ),
    );
  }
}

class _BarChartCard extends StatelessWidget {
  const _BarChartCard();

  @override
  Widget build(BuildContext context) {
    return const _DashboardCard(
      title: 'Consumo de combustible',
      child: SizedBox(
        height: 240,
        child: CustomPaint(painter: _BarChartPainter()),
      ),
    );
  }
}

class _VehicleHealthCard extends StatelessWidget {
  const _VehicleHealthCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Salud de vehiculos',
      child: Column(
        children: [
          const SizedBox(
            height: 220,
            child: Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: CustomPaint(painter: _DonutPainter()),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 18,
            runSpacing: 10,
            children: const [
              _LegendDot(label: 'Optimo: 65%', color: Color(0xFF10B981)),
              _LegendDot(label: 'Atencion: 25%', color: Color(0xFFF59E0B)),
              _LegendDot(label: 'Critico: 10%', color: Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteEfficiencyCard extends StatelessWidget {
  const _RouteEfficiencyCard({this.overview});

  final SupervisorOverview? overview;

  @override
  Widget build(BuildContext context) {
    final items = overview?.routeMetrics ??
        const [
          SupervisorRouteMetric(label: 'R-001', efficiency: 92),
          SupervisorRouteMetric(label: 'R-002', efficiency: 85),
          SupervisorRouteMetric(label: 'R-003', efficiency: 88),
          SupervisorRouteMetric(label: 'R-004', efficiency: 76),
          SupervisorRouteMetric(label: 'R-005', efficiency: 82),
        ];

    return _DashboardCard(
      title: 'Eficiencia de rutas',
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: Text(
                        item.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.gray600,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 38,
                          value: item.efficiency / 100,
                          backgroundColor: const Color(0xFFF2F6FB),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 38,
                      child: Text(
                        '${item.efficiency.toInt()}',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.gray600,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _LiveMapCard extends StatelessWidget {
  const _LiveMapCard({this.overview});

  final SupervisorOverview? overview;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Mapa de flota en tiempo real',
      trailing: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: const [
          _LegendDot(label: 'En ruta', color: Color(0xFF10B981)),
          _LegendDot(label: 'En pausa', color: Color(0xFFF59E0B)),
          _LegendDot(label: 'Estacionado', color: Color(0xFF3B82F6)),
        ],
      ),
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          color: const Color(0xFFFBFDFF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE8EEF5)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 58,
                color: AppColors.gray500,
              ),
              const SizedBox(height: 14),
              Text(
                'Mapa interactivo de flota',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.gray600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${overview?.activeVehicles ?? 0} vehiculos en seguimiento activo',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardLoadingCard extends StatelessWidget {
  const _DashboardLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _DashboardErrorCard extends StatelessWidget {
  const _DashboardErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'No se pudo cargar el dashboard',
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.danger,
            ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCE5EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trailing == null)
            Text(
              title,
              style: textTheme.headlineSmall?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.headlineSmall?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(child: trailing!),
              ],
            ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.gray600,
              ),
        ),
      ],
    );
  }
}

class _RiskEvent {
  const _RiskEvent({
    required this.title,
    required this.driver,
    required this.plate,
    required this.location,
    required this.timeAgo,
    required this.level,
    required this.levelColor,
    required this.icon,
  });

  final String title;
  final String driver;
  final String plate;
  final String location;
  final String timeAgo;
  final String level;
  final Color levelColor;
  final IconData icon;
}

class _RiskEventCard extends StatelessWidget {
  const _RiskEventCard({required this.event});

  final _RiskEvent event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE5EF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: event.levelColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(event.icon, color: event.levelColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusPill(event.level, event.levelColor),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${event.driver} • ${event.plate}',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        event.location,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray600,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      event.timeAgo,
                      style: textTheme.bodyMedium?.copyWith(
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
    );
  }
}

class _CategoryStat {
  const _CategoryStat(
    this.label,
    this.count,
    this.progress,
    this.color,
    this.icon,
  );

  final String label;
  final int count;
  final double progress;
  final Color color;
  final IconData icon;
}

class _CategoryProgressRow extends StatelessWidget {
  const _CategoryProgressRow({required this.stat});

  final _CategoryStat stat;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          children: [
            Icon(stat.icon, size: 18, color: AppColors.gray500),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                stat.label,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${stat.count}',
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: stat.progress,
            minHeight: 7,
            backgroundColor: const Color(0xFFE9EFF6),
            valueColor: AlwaysStoppedAnimation<Color>(stat.color),
          ),
        ),
      ],
    );
  }
}

class _VehicleRow {
  const _VehicleRow({
    required this.plate,
    required this.type,
    required this.capacity,
    required this.status,
    required this.statusColor,
    required this.lastMaintenance,
  });

  final String plate;
  final String type;
  final String capacity;
  final String status;
  final Color statusColor;
  final String lastMaintenance;
}

class _VehicleFilterCard extends StatefulWidget {
  const _VehicleFilterCard();

  @override
  State<_VehicleFilterCard> createState() => _VehicleFilterCardState();
}

class _VehicleFilterCardState extends State<_VehicleFilterCard> {
  String _selectedStatus = 'Todos los estados';

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Filtros y registro',
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por matricula o tipo',
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.gray400,
                  ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFDCE5EF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.secondary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            items: const [
              DropdownMenuItem(
                value: 'Todos los estados',
                child: Text('Todos los estados'),
              ),
              DropdownMenuItem(
                value: 'Operativo',
                child: Text('Operativo'),
              ),
              DropdownMenuItem(
                value: 'Mantenimiento',
                child: Text('Mantenimiento'),
              ),
              DropdownMenuItem(
                value: 'Fuera de servicio',
                child: Text('Fuera de servicio'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedStatus = value;
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFDCE5EF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.secondary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddVehicleDialog(context),
              icon: const Icon(Icons.local_shipping_outlined, size: 18),
              label: const Text('Agregar vehiculo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddVehicleDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const _AddVehicleDialog(),
    );
  }
}

class _AddVehicleDialog extends StatefulWidget {
  const _AddVehicleDialog();

  @override
  State<_AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<_AddVehicleDialog> {
  final _plateController = TextEditingController(text: 'ABC-1234');
  final _capacityController = TextEditingController(text: '5,000 kg');
  final _yearController = TextEditingController(text: '2024');
  final _maintenanceController = TextEditingController(text: '');

  String _vehicleType = 'Seleccionar tipo';
  String _status = 'Operativo';

  @override
  void dispose() {
    _plateController.dispose();
    _capacityController.dispose();
    _yearController.dispose();
    _maintenanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useSingleColumn = constraints.maxWidth < 360;

          return Container(
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Agregar nuevo vehiculo',
                            style: textTheme.headlineSmall?.copyWith(
                              color: AppColors.text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                          color: AppColors.gray500,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFDCE5EF)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    child: Column(
                      children: [
                        _DialogResponsiveRow(
                          singleColumn: useSingleColumn,
                          children: [
                            _DialogField(
                              label: 'Matricula *',
                              child: TextField(
                                controller: _plateController,
                                decoration: _dialogInputDecoration('ABC-1234'),
                              ),
                            ),
                            _DialogField(
                              label: 'Tipo de vehiculo *',
                              child: DropdownButtonFormField<String>(
                                value: _vehicleType,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Seleccionar tipo',
                                    child: Text('Seleccionar tipo'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Camion de carga',
                                    child: Text('Camion de carga'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Trailer',
                                    child: Text('Trailer'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Camioneta',
                                    child: Text('Camioneta'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Furgoneta',
                                    child: Text('Furgoneta'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _vehicleType = value;
                                  });
                                },
                                decoration: _dialogInputDecoration(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _DialogResponsiveRow(
                          singleColumn: useSingleColumn,
                          children: [
                            _DialogField(
                              label: 'Capacidad *',
                              child: TextField(
                                controller: _capacityController,
                                decoration: _dialogInputDecoration('5,000 kg'),
                              ),
                            ),
                            _DialogField(
                              label: 'Ano *',
                              child: TextField(
                                controller: _yearController,
                                keyboardType: TextInputType.number,
                                decoration: _dialogInputDecoration('2024'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _DialogResponsiveRow(
                          singleColumn: useSingleColumn,
                          children: [
                            _DialogField(
                              label: 'Estado *',
                              child: DropdownButtonFormField<String>(
                                value: _status,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Operativo',
                                    child: Text('Operativo'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Mantenimiento',
                                    child: Text('Mantenimiento'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Fuera de servicio',
                                    child: Text('Fuera de servicio'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _status = value;
                                  });
                                },
                                decoration: _dialogInputDecoration(),
                              ),
                            ),
                            _DialogField(
                              label: 'Ultimo mantenimiento *',
                              child: TextField(
                                controller: _maintenanceController,
                                decoration: _dialogInputDecoration('dd/mm/aaaa'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFDCE5EF)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    child: _DialogActions(
                      singleColumn: useSingleColumn,
                      onCancel: () => Navigator.of(context).pop(),
                      onConfirm: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _dialogInputDecoration([String? hintText]) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.gray400),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDCE5EF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.secondary),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _DialogResponsiveRow extends StatelessWidget {
  const _DialogResponsiveRow({
    required this.singleColumn,
    required this.children,
  });

  final bool singleColumn;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (singleColumn) {
      return Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 14),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i != children.length - 1) const SizedBox(width: 14),
        ],
      ],
    );
  }
}

class _DialogActions extends StatelessWidget {
  const _DialogActions({
    required this.singleColumn,
    required this.onCancel,
    required this.onConfirm,
  });

  final bool singleColumn;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final cancel = OutlinedButton(
      onPressed: onCancel,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        side: const BorderSide(color: Color(0xFFDCE5EF)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: const Text('Cancelar'),
    );

    final confirm = ElevatedButton(
      onPressed: onConfirm,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
      child: const Text('Agregar vehiculo'),
    );

    if (singleColumn) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          confirm,
          const SizedBox(height: 12),
          cancel,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        cancel,
        const SizedBox(width: 12),
        confirm,
      ],
    );
  }
}

class _SimpleDataTable extends StatelessWidget {
  const _SimpleDataTable({
    required this.headers,
    required this.rows,
  });

  final List<String> headers;
  final List<List<Widget>> rows;

  @override
  Widget build(BuildContext context) {
    final table = Table(
      columnWidths: {
        for (var i = 0; i < headers.length; i++) i: const IntrinsicColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FBFF),
          ),
          children: headers
              .map(
                (header) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Text(
                    header,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.gray600,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              )
              .toList(),
        ),
        for (final row in rows)
          TableRow(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFDCE5EF)),
              ),
            ),
            children: row
                .map(
                  (cell) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    child: cell,
                  ),
                )
                .toList(),
          ),
      ],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFDCE5EF)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 760),
            child: table,
          ),
        ),
      ),
    );
  }
}

class _TableTextCell extends StatelessWidget {
  const _TableTextCell(this.value, {this.emphasized = false});

  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: emphasized ? AppColors.text : AppColors.gray600,
            fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
            height: 1.45,
          ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _ActionButtonsCell extends StatelessWidget {
  const _ActionButtonsCell();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.edit_outlined, size: 18, color: AppColors.gray500),
        const SizedBox(width: 14),
        Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
      ],
    );
  }
}

class _SupervisorPlaceholderView extends StatelessWidget {
  const _SupervisorPlaceholderView({
    super.key,
    required this.section,
    required this.textTheme,
  });

  final _SupervisorSection section;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFDCE5EF)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(section.icon, color: AppColors.secondary, size: 32),
              ),
              const SizedBox(height: 18),
              Text(
                section.label,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Vista preparada para seguimiento operativo.',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.gray600,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupervisorMenuSheet extends StatelessWidget {
  const _SupervisorMenuSheet({
    required this.selectedSection,
    required this.onSelected,
  });

  final _SupervisorSection selectedSection;
  final ValueChanged<_SupervisorSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              for (final section in _SupervisorSection.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: selectedSection == section
                        ? AppColors.secondaryLight
                        : AppColors.gray50,
                    borderRadius: BorderRadius.circular(16),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onTap: () => onSelected(section),
                      leading: Icon(
                        section.icon,
                        color: selectedSection == section
                            ? AppColors.secondary
                            : AppColors.gray700,
                      ),
                      title: Text(
                        section.label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE3EBF5)
      ..strokeWidth = 1;
    final accentPaint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x3320C997), Color(0x00FFFFFF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final chartRect = Rect.fromLTWH(36, 18, size.width - 54, size.height - 48);

    for (var i = 0; i <= 4; i++) {
      final y = chartRect.top + (chartRect.height / 4) * i;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
    }

    for (var i = 0; i <= 3; i++) {
      final x = chartRect.left + (chartRect.width / 3) * i;
      canvas.drawLine(
        Offset(x, chartRect.top),
        Offset(x, chartRect.bottom),
        gridPaint,
      );
    }

    final points = [
      Offset(chartRect.left, chartRect.top + chartRect.height * 0.22),
      Offset(chartRect.left + chartRect.width * 0.22, chartRect.top + chartRect.height * 0.15),
      Offset(chartRect.left + chartRect.width * 0.42, chartRect.top + chartRect.height * 0.28),
      Offset(chartRect.left + chartRect.width * 0.6, chartRect.top + chartRect.height * 0.1),
      Offset(chartRect.right, chartRect.top + chartRect.height * 0.04),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final controlX = (previous.dx + current.dx) / 2;
      path.cubicTo(
        controlX,
        previous.dy,
        controlX,
        current.dy,
        current.dx,
        current.dy,
      );
    }

    final fillPath = Path.from(path)
      ..lineTo(chartRect.right, chartRect.bottom)
      ..lineTo(chartRect.left, chartRect.bottom)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BarChartPainter extends CustomPainter {
  const _BarChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE3EBF5)
      ..strokeWidth = 1;
    final barPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.primary, Color(0xFF1D4ED8)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final chartRect = Rect.fromLTWH(36, 18, size.width - 54, size.height - 44);

    for (var i = 0; i <= 4; i++) {
      final y = chartRect.top + (chartRect.height / 4) * i;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
    }

    const values = [440.0, 510.0, 470.0, 500.0, 485.0, 370.0, 310.0];
    const maxValue = 600.0;
    final barWidth = chartRect.width / 10;
    final spacing = chartRect.width / 30;

    for (var i = 0; i < values.length; i++) {
      final left = chartRect.left + i * (barWidth + spacing);
      final height = chartRect.height * (values[i] / maxValue);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, chartRect.bottom - height, barWidth, height),
        const Radius.circular(10),
      );
      canvas.drawRRect(rect, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 34.0;
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final background = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFF1F5F9);
    canvas.drawArc(rect, 0, math.pi * 2, false, background);

    final segments = [
      (0.65, const Color(0xFF10B981)),
      (0.25, const Color(0xFFF59E0B)),
      (0.10, const Color(0xFFEF4444)),
    ];

    var start = -math.pi * 0.92;
    for (final segment in segments) {
      final sweep = math.pi * 2 * segment.$1 - 0.08;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = segment.$2;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep + 0.08;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
