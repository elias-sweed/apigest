import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/activity_item.dart';
import '../../../domain/entities/dashboard_stats.dart';
import '../../providers/dashboard_providers.dart';
import '../../providers/prestamo_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final activityAsync = ref.watch(recentActivityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _formattedTime(),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(recentActivityProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            statsAsync.when(
              loading: () => const _StatsSkeleton(),
              error: (_, _) => const _StatsSkeleton(),
              data: (stats) => _StatsGrid(stats: stats),
            ),
            const SizedBox(height: 24),
            Text(
              'Préstamos activos hoy',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _ActiveLoansSection(),
            const SizedBox(height: 24),
            Text(
              'Actividad reciente',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            activityAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Text('No se pudo cargar la actividad.'),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(child: Text('Sin actividad reciente.'));
                }
                return Column(
                  children: items.map((item) => _ActivityTile(item: item)).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Acción rápida',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _QuickActionButton(
              icon: Icons.add_circle_outline,
              label: 'NUEVO PRÉSTAMO',
              color: AppTheme.primaryColor,
              onTap: () => context.push(RouteNames.prestamoNuevo),
            ),
            const SizedBox(height: 8),
            _QuickActionButton(
              icon: Icons.replay,
              label: 'REGISTRAR DEVOLUCIÓN',
              color: AppTheme.successColor,
              onTap: () {
                final prestamosActivos = ref.read(prestamoListProvider);
                prestamosActivos.whenData((lista) {
                  if (lista.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No hay préstamos activos')),
                    );
                    return;
                  }
                  context.push(
                    '${RouteNames.prestamos}/devolucion/${lista.first.id}',
                  );
                });
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formattedTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _StatsGrid extends StatelessWidget {
  final DashboardStats stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600;
        final crossAxisCount = isDesktop ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.2,
          children: [
            _MetricCard(
              icon: Icons.assignment,
              count: '${stats.prestamosActivos}',
              label: 'Activos',
              color: AppTheme.primaryColor,
            ),
            _MetricCard(
              icon: Icons.devices,
              count: '${stats.equiposDisponibles}',
              label: 'Disponibles',
              color: AppTheme.successColor,
            ),
            _MetricCard(
              icon: Icons.sync,
              count: '${stats.equiposPrestados}',
              label: 'Prestados',
              color: AppTheme.warningColor,
            ),
            _MetricCard(
              icon: Icons.build,
              count: '${stats.equiposMantenimiento}',
              label: 'Mantenimiento',
              color: Colors.orange,
            ),
          ],
        );
      },
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600;
        return GridView.count(
          crossAxisCount: isDesktop ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.2,
          children: List.generate(
            4,
            (_) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveLoansSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prestamosAsync = ref.watch(prestamoListProvider);

    return prestamosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Text('No se pudieron cargar los préstamos.'),
      data: (prestamos) {
        if (prestamos.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No hay préstamos activos')),
            ),
          );
        }
        return Column(
          children: [
            ...prestamos.take(5).map((p) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(p.docenteNombre,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                        '${p.cantidadEquipos} equipos · ${p.encargadoNombre}'),
                    trailing: Text(
                      '${p.fechaHoraInicio.hour.toString().padLeft(2, '0')}:'
                      '${p.fechaHoraInicio.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    onTap: () => context.push(
                        '${RouteNames.prestamos}/${p.id}'),
                  ),
                )),
            TextButton(
              onPressed: () => context.go(RouteNames.prestamos),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ver todos →'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityItem item;
  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final icon = item.tipo == 'prestamo_creado'
        ? Icons.add_circle
        : Icons.replay;
    final color = item.tipo == 'prestamo_creado'
        ? AppTheme.successColor
        : AppTheme.primaryColor;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(item.descripcion, style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          '${item.fecha.day.toString().padLeft(2, '0')}/'
          '${item.fecha.month.toString().padLeft(2, '0')} '
          '${item.fecha.hour.toString().padLeft(2, '0')}:'
          '${item.fecha.minute.toString().padLeft(2, '0')}',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        onTap: item.prestamoId != null
            ? () => context.push(
                '${RouteNames.prestamos}/${item.prestamoId}')
            : null,
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
