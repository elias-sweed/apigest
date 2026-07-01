import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/reportes/reporte_diario.dart';

class ReporteDiarioCard extends StatelessWidget {
  final ReporteDiario data;
  const ReporteDiarioCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen del día',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _Row(
              icon: Icons.add_circle,
              label: 'Préstamos creados',
              value: '${data.prestamosCreadosHoy}',
              color: AppTheme.primaryColor,
            ),
            _Row(
              icon: Icons.replay,
              label: 'Devoluciones',
              value: '${data.devolucionesHoy}',
              color: AppTheme.successColor,
            ),
            _Row(
              icon: Icons.pending,
              label: 'Pendientes',
              value: '${data.prestamosPendientes}',
              color: AppTheme.warningColor,
            ),
            const Divider(height: 24),
            Text('Equipos',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _Row(
              icon: Icons.check_circle,
              label: 'Disponibles',
              value: '${data.equiposDisponibles}',
              color: AppTheme.successColor,
            ),
            _Row(
              icon: Icons.sync,
              label: 'Prestados',
              value: '${data.equiposPrestados}',
              color: AppTheme.primaryColor,
            ),
            _Row(
              icon: Icons.build,
              label: 'Mantenimiento',
              value: '${data.equiposMantenimiento}',
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
