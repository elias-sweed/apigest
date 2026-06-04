import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';

class ShellPage extends StatelessWidget {
  final Widget child;

  const ShellPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        if (isDesktop) return _DesktopShell(child: child);
        return _MobileShell(child: child);
      },
    );
  }
}

class _MobileShell extends StatelessWidget {
  final Widget child;
  const _MobileShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onTab(context, index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.assignment), label: 'Préstamos'),
          NavigationDestination(icon: Icon(Icons.devices), label: 'Equipos'),
          NavigationDestination(icon: Icon(Icons.school), label: 'Docentes'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historial'),
        ],
      ),
    );
  }
}

class _DesktopShell extends StatelessWidget {
  final Widget child;
  const _DesktopShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabIndex(location);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => _onTab(context, index),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment),
                label: Text('Préstamos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.devices),
                label: Text('Equipos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.school),
                label: Text('Docentes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history),
                label: Text('Historial'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

int _tabIndex(String location) {
  if (location.startsWith(RouteNames.prestamos)) return 1;
  if (location.startsWith(RouteNames.equipos)) return 2;
  if (location.startsWith(RouteNames.docentes)) return 3;
  if (location.startsWith(RouteNames.historial)) return 4;
  return 0;
}

void _onTab(BuildContext context, int index) {
  switch (index) {
    case 0:
      context.go(RouteNames.dashboard);
    case 1:
      context.go(RouteNames.prestamos);
    case 2:
      context.go(RouteNames.equipos);
    case 3:
      context.go(RouteNames.docentes);
    case 4:
      context.go(RouteNames.historial);
  }
}
