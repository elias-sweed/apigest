class ReporteRangoFechas {
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int totalPrestamos;
  final int totalDevoluciones;
  final List<EquipoUso> equiposMasUsados;
  final List<DocentePrestamos> docentesConMasPrestamos;

  const ReporteRangoFechas({
    required this.fechaInicio,
    required this.fechaFin,
    required this.totalPrestamos,
    required this.totalDevoluciones,
    required this.equiposMasUsados,
    required this.docentesConMasPrestamos,
  });
}

class EquipoUso {
  final String equipoId;
  final String codigoPatrimonial;
  final String nombre;
  final int cantidadPrestamos;

  const EquipoUso({
    required this.equipoId,
    required this.codigoPatrimonial,
    required this.nombre,
    required this.cantidadPrestamos,
  });
}

class DocentePrestamos {
  final String docenteId;
  final String nombreCompleto;
  final int cantidadPrestamos;

  const DocentePrestamos({
    required this.docenteId,
    required this.nombreCompleto,
    required this.cantidadPrestamos,
  });
}
