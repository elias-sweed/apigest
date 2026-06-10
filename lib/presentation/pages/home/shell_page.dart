import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/router/route_names.dart';
import '../../../core/auth/route_guard.dart';
import '../../../domain/entities/user_role.dart';

class ShellPage extends ConsumerWidget {
  final Widget child;

  const ShellPage({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    final location = GoRouterState.of(context).matchedLocation;

    final redirect = RouteGuard.checkRedirect(location, role, RouteNames.dashboard);
    if (redirect != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go(redirect));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        if (isDesktop) {
        return _DesktopShell(role: role, child: child);
      }
      return _MobileShell(role: role, child: child);
      },
    );
  }
}

class _TabConfig {
  final String label;
  final IconData icon;
  final String route;

  const _TabConfig({
    required this.label,
    required this.icon,
    required this.route,
  });
}

List<_TabConfig> _tabsForRole(UserRole role) {
  if (role.isEncargadoAip) {
    return const [
      _TabConfig(label: 'Dashboard', icon: Icons.dashboard, route: RouteNames.dashboard),
      _TabConfig(label: 'Préstamos', icon: Icons.assignment, route: RouteNames.prestamos),
      _TabConfig(label: 'Equipos', icon: Icons.devices, route: RouteNames.equipos),
      _TabConfig(label: 'Docentes', icon: Icons.school, route: RouteNames.docentes),
      _TabConfig(label: 'Historial', icon: Icons.history, route: RouteNames.historial),
    ];
  }
  return const [
    _TabConfig(label: 'Dashboard', icon: Icons.dashboard, route: RouteNames.dashboard),
    _TabConfig(label: 'Préstamos', icon: Icons.assignment, route: RouteNames.prestamos),
    _TabConfig(label: 'Historial', icon: Icons.history, route: RouteNames.historial),
  ];
}

int _tabIndex(String location, List<_TabConfig> tabs) {
  for (var i = 0; i < tabs.length; i++) {
    if (location.startsWith(tabs[i].route)) return i;
  }
  return 0;
}

class _MobileShell extends StatelessWidget {
  final Widget child;
  final UserRole role;

  const _MobileShell({required this.child, required this.role});

  @override
  Widget build(BuildContext context) {
    final tabs = _tabsForRole(role);
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabIndex(location, tabs);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => context.go(tabs[index].route),
        destinations: tabs
            .map((t) => NavigationDestination(icon: Icon(t.icon), label: t.label))
            .toList(),
      ),
    );
  }
}

class _DesktopShell extends StatelessWidget {
  final Widget child;
  final UserRole role;

  const _DesktopShell({required this.child, required this.role});

  @override
  Widget build(BuildContext context) {
    final tabs = _tabsForRole(role);
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabIndex(location, tabs);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => context.go(tabs[index].route),
            labelType: NavigationRailLabelType.all,
            destinations: tabs
                .map((t) => NavigationRailDestination(
                      icon: Icon(t.icon),
                      label: Text(t.label),
                    ))
                .toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
