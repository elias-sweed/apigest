class ReporteEquipo {
  final String equipoId;
  final String codigoPatrimonial;
  final String nombre;
  final String estadoActual;
  final int cantidadPrestamos;
  final Duration? tiempoPromedioUso;
  final List<UsoEquipo> historialUsos;

  const ReporteEquipo({
    required this.equipoId,
    required this.codigoPatrimonial,
    required this.nombre,
    required this.estadoActual,
    required this.cantidadPrestamos,
    this.tiempoPromedioUso,
    required this.historialUsos,
  });
}

class UsoEquipo {
  final String prestamoId;
  final String docenteNombre;
  final DateTime fechaInicio;
  final DateTime? fechaDevolucion;
  final String? observaciones;

  const UsoEquipo({
    required this.prestamoId,
    required this.docenteNombre,
    required this.fechaInicio,
    this.fechaDevolucion,
    this.observaciones,
  });
}
