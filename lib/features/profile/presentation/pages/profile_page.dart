import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cobox_sv_mobile/app/colors.dart';
import 'package:cobox_sv_mobile/app/providers.dart';
import 'package:cobox_sv_mobile/features/authentication/presentation/providers/auth_provider.dart';
import 'package:cobox_sv_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:cobox_sv_mobile/features/profile/domain/entities/vehicle_entity.dart';
import 'package:cobox_sv_mobile/features/profile/presentation/providers/profile_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileProvider.notifier).loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final profile = state.profile;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: _DriverHeader(
        title: 'Perfil',
        subtitle: profile?.vehicle?.plate ?? _displayRole(profile?.role) ?? 'Sin vehiculo',
        initial: profile?.name.isNotEmpty == true
            ? profile!.name[0].toUpperCase()
            : 'U',
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(profileProvider.notifier).loadProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: profile == null
              ? Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Center(
                    child: state.status == ProfileStateStatus.error
                        ? Text(
                            state.error ?? 'No se pudo cargar el perfil',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.danger,
                                ),
                          )
                        : const CircularProgressIndicator(),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileHero(profile: profile),
                    const SizedBox(height: 16),
                    _ProfileStats(profile: profile),
                    const SizedBox(height: 16),
                    _InfoSection(
                      title: 'Informacion personal',
                      items: [
                        _InfoItemData(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: profile.email,
                        ),
                        _InfoItemData(
                          icon: Icons.call_outlined,
                          label: 'Telefono',
                          value: profile.phone ?? '-',
                        ),
                        _InfoItemData(
                          icon: Icons.badge_outlined,
                          label: 'Licencia de conducir',
                          value: profile.licenseNumber ?? '-',
                        ),
                        _InfoItemData(
                          icon: Icons.calendar_today_outlined,
                          label: 'Vencimiento licencia',
                          value: _formatDate(profile.licenseExpiry),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoSection(
                      title: 'Vehiculo asignado',
                      items: [
                        _InfoItemData(
                          icon: Icons.local_shipping_outlined,
                          label: 'Placa',
                          value: profile.vehicle?.plate ?? '-',
                        ),
                        _InfoItemData(
                          icon: Icons.inventory_2_outlined,
                          label: 'Modelo',
                          value: _vehicleModel(profile.vehicle),
                        ),
                        _InfoItemData(
                          icon: Icons.local_shipping_outlined,
                          label: 'Tipo',
                          value: profile.vehicle?.type ?? '-',
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          await ref.read(authNotifierProvider.notifier).logout();
                          ref.read(authStatusProvider.notifier).state =
                              AuthStatus.unauthenticated;
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cerrar sesion'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  String _vehicleModel(VehicleEntity? vehicle) {
    if (vehicle == null) return '-';
    return '${vehicle.brand} ${vehicle.model}';
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '-';
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String? _displayRole(String? role) {
    switch (role) {
      case 'ROLE_MANAGER':
        return 'Supervisor';
      case 'ROLE_DRIVER':
        return 'Conductor';
      case 'ROLE_CLIENT':
        return 'Cliente';
      default:
        return role;
    }
  }
}

class _DriverHeader extends StatelessWidget implements PreferredSizeWidget {
  const _DriverHeader({
    required this.title,
    required this.subtitle,
    required this.initial,
  });

  final String title;
  final String subtitle;
  final String initial;

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
            initial,
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
            subtitle,
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

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.secondary, AppColors.primary],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'C',
                style: textTheme.displaySmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  profile.employeeId ?? profile.id,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
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

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.05,
      children: [
        _StatBox(
          icon: Icons.inventory_2_outlined,
          value: profile.vehicle != null ? '1' : '0',
          label: 'Vehiculos asignados',
          iconColor: AppColors.secondary,
          iconBackground: Color(0xFFE8F6F4),
        ),
        _StatBox(
          icon: Icons.access_time_rounded,
          value: profile.isActive ? 'Activo' : 'Inactivo',
          label: 'Estado',
          iconColor: Color(0xFF22C55E),
          iconBackground: Color(0xFFE8F8EF),
        ),
        _StatBox(
          icon: Icons.location_on_outlined,
          value: profile.vehicle?.plate ?? '-',
          label: 'Placa',
          iconColor: AppColors.primary,
          iconBackground: Color(0xFFEAF2FF),
        ),
        _StatBox(
          icon: Icons.calendar_month_outlined,
          value: _roleLabel(profile.role),
          label: 'Rol',
          iconColor: Color(0xFFF97316),
          iconBackground: Color(0xFFFFF1E8),
        ),
      ],
    );
  }
}

String _roleLabel(String role) {
  switch (role) {
    case 'ROLE_MANAGER':
      return 'Supervisor';
    case 'ROLE_DRIVER':
      return 'Conductor';
    case 'ROLE_CLIENT':
      return 'Cliente';
    default:
      return role;
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.iconBackground,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: _surfaceDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.gray500),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_InfoItemData> items;

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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _InfoRow(item: items[i]),
                  if (i != items.length - 1) const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.item});

  final _InfoItemData item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F6F4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.icon, color: AppColors.secondary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.gray500),
              ),
              const SizedBox(height: 2),
              Text(
                item.value,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoItemData {
  const _InfoItemData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
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
