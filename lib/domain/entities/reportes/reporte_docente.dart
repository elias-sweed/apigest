class ReporteDocente {
  final String docenteId;
  final String nombreCompleto;
  final int cantidadPrestamos;
  final List<EquipoUtilizado> equiposUtilizados;
  final List<PrestamoResumen> prestamos;

  const ReporteDocente({
    required this.docenteId,
    required this.nombreCompleto,
    required this.cantidadPrestamos,
    required this.equiposUtilizados,
    required this.prestamos,
  });
}

class EquipoUtilizado {
  final String equipoId;
  final String codigoPatrimonial;
  final String nombre;
  final int vecesPrestado;

  const EquipoUtilizado({
    required this.equipoId,
    required this.codigoPatrimonial,
    required this.nombre,
    required this.vecesPrestado,
  });
}

class PrestamoResumen {
  final String prestamoId;
  final DateTime fecha;
  final String? observaciones;

  const PrestamoResumen({
    required this.prestamoId,
    required this.fecha,
    this.observaciones,
  });
}
