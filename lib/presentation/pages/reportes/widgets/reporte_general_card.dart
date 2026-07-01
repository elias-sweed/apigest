import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/reportes/reporte_general.dart';

class ReporteGeneralCard extends StatelessWidget {
  final ReporteGeneral data;
  const ReporteGeneralCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estadísticas del sistema',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Text('Docentes',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            _RowStat(
                label: 'Total', value: '${data.totalDocentes}', color: Colors.grey),
            const SizedBox(height: 12),
            Text('Equipos',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            _RowStat(
                label: 'Total',
                value: '${data.totalEquipos}',
                color: Colors.grey),
            _RowStat(
                label: 'Disponibles',
                value: '${data.equiposDisponibles}',
                color: AppTheme.successColor),
            _RowStat(
                label: 'Prestados',
                value: '${data.equiposPrestados}',
                color: AppTheme.primaryColor),
            _RowStat(
                label: 'Mantenimiento',
                value: '${data.equiposMantenimiento}',
                color: Colors.orange),
            const SizedBox(height: 12),
            Text('Préstamos',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            _RowStat(
                label: 'Activos',
                value: '${data.prestamosActivos}',
                color: AppTheme.primaryColor),
            _RowStat(
                label: 'Devueltos',
                value: '${data.prestamosDevueltos}',
                color: AppTheme.successColor),
            _RowStat(
                label: 'Del mes',
                value: '${data.prestamosDelMes}',
                color: Colors.grey),
            _RowStat(
                label: 'Devoluciones del mes',
                value: '${data.devolucionesDelMes}',
                color: Colors.grey),
            if (data.equipoMasUtilizado != null ||
                data.docenteMayorPrestamos != null) ...[
              const Divider(height: 24),
              if (data.equipoMasUtilizado != null)
                _RowStat(
                    label: 'Equipo más utilizado',
                    value: data.equipoMasUtilizado!,
                    color: AppTheme.warningColor),
              if (data.docenteMayorPrestamos != null)
                _RowStat(
                    label: 'Docente con más préstamos',
                    value: data.docenteMayorPrestamos!,
                    color: AppTheme.warningColor),
            ],
          ],
        ),
      ),
    );
  }
}

class _RowStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _RowStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
