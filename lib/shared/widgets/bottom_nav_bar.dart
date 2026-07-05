import 'package:flutter/material.dart';

enum AppTab {
  home(0, 'Inicio', Icons.home_outlined, Icons.home_rounded),
  planning(1, 'Planificaci\u00f3n', Icons.calendar_month_outlined, Icons.calendar_month_rounded),
  routes(2, 'Rutas', Icons.route_outlined, Icons.route_rounded),
  orders(3, '\u00d3rdenes', Icons.inventory_2_outlined, Icons.inventory_2_rounded),
  incidents(4, 'Incidentes', Icons.warning_amber_outlined, Icons.warning_amber_rounded),
  profile(5, 'Perfil', Icons.person_outline, Icons.person);

  const AppTab(this.tabIndex, this.label, this.icon, this.activeIcon);

  final int tabIndex;
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    this.unreadCount = 0,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return NavigationBar(
      selectedIndex: currentTab.tabIndex,
      onDestinationSelected: (index) {
        final tab = AppTab.values.firstWhere((t) => t.tabIndex == index);
        onTabSelected(tab);
      },
      indicatorColor: colorScheme.secondaryContainer,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      animationDuration: const Duration(milliseconds: 300),
      destinations: [
        for (final tab in AppTab.values)
          NavigationDestination(
            icon: _buildWidget(tab, false, colorScheme),
            selectedIcon: _buildWidget(tab, true, colorScheme),
            label: tab.label,
          ),
      ],
    );
  }

  Widget _buildWidget(AppTab tab, bool isSelected, ColorScheme colorScheme) {
    final Widget widget;
    if (tab == AppTab.profile && isSelected) {
      widget = CircleAvatar(
        backgroundColor: colorScheme.secondaryContainer,
        child: Icon(tab.activeIcon, color: colorScheme.onSecondaryContainer),
      );
    } else {
      final icon = isSelected ? tab.activeIcon : tab.icon;
      final color = isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant;
      widget = Icon(icon, color: color);
    }

    if (tab == AppTab.home && unreadCount > 0) {
      return Badge(
        label: Text(
          unreadCount > 99 ? '99+' : unreadCount.toString(),
          style: const TextStyle(fontSize: 10),
        ),
        child: widget,
      );
    }

    return widget;
  }
}
