class HistorialFilter {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final String? estado;
  final String? search;

  const HistorialFilter({
    this.fechaInicio,
    this.fechaFin,
    this.estado,
    this.search,
  });

  HistorialFilter copyWith({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? estado,
    String? search,
  }) {
    return HistorialFilter(
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      estado: estado ?? this.estado,
      search: search ?? this.search,
    );
  }
}
