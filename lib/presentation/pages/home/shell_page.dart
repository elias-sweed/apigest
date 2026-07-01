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
    final role = ref.watch(currentUserRoleProvider).valueOrNull ?? UserRole.practicante;
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
      _TabConfig(label: 'Inicio', icon: Icons.dashboard, route: RouteNames.dashboard),
      _TabConfig(label: 'Préstamos', icon: Icons.assignment, route: RouteNames.prestamos),
      _TabConfig(label: 'Equipos', icon: Icons.devices, route: RouteNames.equipos),
      _TabConfig(label: 'Docentes', icon: Icons.school, route: RouteNames.docentes),
      _TabConfig(label: 'Reportes', icon: Icons.bar_chart, route: RouteNames.reportes),
      _TabConfig(label: 'Historial', icon: Icons.history, route: RouteNames.historial),
      _TabConfig(label: 'Perfil', icon: Icons.person, route: RouteNames.perfil),
    ];
  }
  return const [
    _TabConfig(label: 'Inicio', icon: Icons.dashboard, route: RouteNames.dashboard),
    _TabConfig(label: 'Préstamos', icon: Icons.assignment, route: RouteNames.prestamos),
    _TabConfig(label: 'Historial', icon: Icons.history, route: RouteNames.historial),
    _TabConfig(label: 'Perfil', icon: Icons.person, route: RouteNames.perfil),
  ];
}

int _tabIndex(String location, List<_TabConfig> tabs) {
  for (var i = 0; i < tabs.length; i++) {
    if (location.startsWith(tabs[i].route)) return i;
  }
  return 0;
}

class _MobileShell extends ConsumerWidget {
  final Widget child;
  final UserRole role;

  const _MobileShell({required this.child, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = _tabsForRole(role);
    final user = ref.watch(currentUserProvider);
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabIndex(location, tabs);
    final currentTab = tabs[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentTab.label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => context.go(RouteNames.perfil),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  _initials(user?.email ?? '?'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: NavigationDrawer(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          Navigator.pop(context);
          context.go(tabs[index].route);
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
            child: Row(
              children: [
                Icon(Icons.school, color: Theme.of(context).colorScheme.primary, size: 28),
                const SizedBox(width: 16),
                Text(
                  'AIP Gest',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          ...tabs.map((t) => NavigationDrawerDestination(
                icon: Icon(t.icon),
                label: Text(t.label),
              )),
        ],
      ),
      body: child,
    );
  }

  String _initials(String email) {
    if (email.isEmpty) return '?';
    final atIndex = email.indexOf('@');
    if (atIndex <= 0) return email[0].toUpperCase();
    final name = email.substring(0, atIndex);
    final parts = name.split('.');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
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
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Icon(Icons.school, size: 28, color: Theme.of(context).colorScheme.primary),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: IconButton(
                onPressed: () => context.go(RouteNames.perfil),
                icon: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                tooltip: 'Perfil',
              ),
            ),
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
