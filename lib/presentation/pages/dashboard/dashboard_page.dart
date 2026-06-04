import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _MetricRow(),
            const SizedBox(height: 24),
            Text(
              'Préstamos activos hoy',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            _ActiveLoanCard(
              teacher: 'Lucía Fernández',
              time: '09:15',
              count: 3,
              deliveredBy: 'Carlos Mendoza',
            ),
            _ActiveLoanCard(
              teacher: 'Ricardo Gutiérrez',
              time: '08:00',
              count: 2,
              deliveredBy: 'Carlos Mendoza',
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(RouteNames.prestamos),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ver todos →'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Acción rápida',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            _QuickActionButton(
              icon: Icons.add_circle_outline,
              label: 'NUEVO PRÉSTAMO',
              color: AppTheme.primaryColor,
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _QuickActionButton(
              icon: Icons.replay,
              label: 'REGISTRAR DEVOLUCIÓN',
              color: AppTheme.successColor,
              onTap: () {},
            ),
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

class _MetricRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 16) / 3;
        return Row(
          children: [
            _MetricCard(
              width: width,
              icon: Icons.assignment,
              count: '12',
              label: 'Activos',
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            _MetricCard(
              width: width,
              icon: Icons.devices,
              count: '8',
              label: 'Disponibles',
              color: AppTheme.successColor,
            ),
            const SizedBox(width: 8),
            _MetricCard(
              width: width,
              icon: Icons.warning_amber,
              count: '3',
              label: 'Mantenimiento',
              color: AppTheme.warningColor,
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final String count;
  final String label;
  final Color color;

  const _MetricCard({
    required this.width,
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
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
      ),
    );
  }
}

class _ActiveLoanCard extends StatelessWidget {
  final String teacher;
  final String time;
  final int count;
  final String deliveredBy;

  const _ActiveLoanCard({
    required this.teacher,
    required this.time,
    required this.count,
    required this.deliveredBy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          teacher,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text('$count equipos · $deliveredBy entregó'),
        trailing: Text(
          time,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {},
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
