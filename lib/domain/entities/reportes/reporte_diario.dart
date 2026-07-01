class ReporteDiario {
  final int prestamosCreadosHoy;
  final int devolucionesHoy;
  final int prestamosPendientes;
  final int equiposDisponibles;
  final int equiposPrestados;
  final int equiposMantenimiento;

  const ReporteDiario({
    required this.prestamosCreadosHoy,
    required this.devolucionesHoy,
    required this.prestamosPendientes,
    required this.equiposDisponibles,
    required this.equiposPrestados,
    required this.equiposMantenimiento,
  });
}
