class Prestamo {
  final String id;
  final String docenteId;
  final String docenteNombre;
  final String encargadoId;
  final String encargadoNombre;
  final DateTime fechaHoraInicio;
  final DateTime? fechaHoraFinEstimada;
  final String estado;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<EquipoPrestamoInfo> equipos;

  const Prestamo({
    required this.id,
    required this.docenteId,
    required this.docenteNombre,
    required this.encargadoId,
    required this.encargadoNombre,
    required this.fechaHoraInicio,
    this.fechaHoraFinEstimada,
    required this.estado,
    this.observaciones,
    required this.createdAt,
    required this.updatedAt,
    this.equipos = const [],
  });

  int get cantidadEquipos => equipos.length;
  int get equiposDevueltos => equipos.where((e) => e.devuelto).length;
  int get equiposPendientes =>
      equipos.where((e) => !e.devuelto).length;

  static const Map<String, String> estadoLabels = {
    'activo': 'Activo',
    'parcial': 'Parcial',
    'devuelto': 'Devuelto',
  };

  String get estadoLabel => estadoLabels[estado] ?? estado;
}

class EquipoPrestamoInfo {
  final String id;
  final String equipoId;
  final String equipoCodigo;
  final String equipoNombre;
  final String equipoTipo;
  final DateTime? fechaDevolucionReal;
  final String? observacionesDevolucion;

  const EquipoPrestamoInfo({
    required this.id,
    required this.equipoId,
    required this.equipoCodigo,
    required this.equipoNombre,
    required this.equipoTipo,
    this.fechaDevolucionReal,
    this.observacionesDevolucion,
  });

  bool get devuelto => fechaDevolucionReal != null;
}
