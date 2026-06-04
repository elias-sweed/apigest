class Docente {
  final String id;
  final String nombres;
  final String apellidos;
  final String? grado;
  final String? seccion;
  final String? turno;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Docente({
    required this.id,
    required this.nombres,
    required this.apellidos,
    this.grado,
    this.seccion,
    this.turno,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  String get nombreCompleto => '$nombres $apellidos';
}
