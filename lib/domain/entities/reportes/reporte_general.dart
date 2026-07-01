class ReporteGeneral {
  final int totalDocentes;
  final int totalEquipos;
  final int equiposDisponibles;
  final int equiposPrestados;
  final int equiposMantenimiento;
  final int prestamosActivos;
  final int prestamosDevueltos;
  final int prestamosDelMes;
  final int devolucionesDelMes;
  final String? equipoMasUtilizado;
  final String? docenteMayorPrestamos;

  const ReporteGeneral({
    required this.totalDocentes,
    required this.totalEquipos,
    required this.equiposDisponibles,
    required this.equiposPrestados,
    required this.equiposMantenimiento,
    required this.prestamosActivos,
    required this.prestamosDevueltos,
    required this.prestamosDelMes,
    required this.devolucionesDelMes,
    this.equipoMasUtilizado,
    this.docenteMayorPrestamos,
  });
}
