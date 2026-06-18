import 'package:flutter/material.dart';
import 'package:cobox_sv_mobile/shared/models/user_model.dart';

enum DrawerItem {
  home('Inicio', Icons.home_rounded),
  planning('Planificación', Icons.calendar_month_rounded),
  routes('Rutas', Icons.route_rounded),
  orders('Pedidos', Icons.inventory_2_rounded),
  incidents('Incidencias', Icons.warning_rounded),
  profile('Perfil', Icons.person_rounded),
  notifications('Notificaciones', Icons.notifications_rounded),
  logout('Cerrar Sesión', Icons.logout_rounded);

  const DrawerItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.user,
    this.activeItem = DrawerItem.home,
    this.onItemSelected,
    this.onLogout,
  });

  final UserModel user;
  final DrawerItem activeItem;
  final ValueChanged<DrawerItem>? onItemSelected;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          _buildHeader(context, colorScheme, textTheme),
          Expanded(child: _buildMenuItems(context, colorScheme, textTheme)),
          _buildLogoutItem(context, colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 24,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: colorScheme.primary,
            backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null
                ? Text(
                    _initials(user.name),
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user.role.label,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    final menuItems = DrawerItem.values.where((item) => item != DrawerItem.logout);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: menuItems.map((item) {
        final isActive = item == activeItem;
        return _buildMenuItem(item, isActive, colorScheme, textTheme);
      }).toList(),
    );
  }

  Widget _buildMenuItem(DrawerItem item, bool isActive, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isActive ? colorScheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onItemSelected?.call(item),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 22,
                  color: isActive ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                Text(
                  item.label,
                  style: textTheme.bodyLarge?.copyWith(
                    color: isActive ? colorScheme.onSecondaryContainer : colorScheme.onSurface,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onLogout,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    DrawerItem.logout.icon,
                    size: 22,
                    color: colorScheme.error,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    DrawerItem.logout.label,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
