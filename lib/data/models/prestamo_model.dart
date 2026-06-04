import '../../domain/entities/prestamo.dart';

class PrestamoModel extends Prestamo {
  const PrestamoModel({
    required super.id,
    required super.docenteId,
    required super.docenteNombre,
    required super.encargadoId,
    required super.encargadoNombre,
    required super.fechaHoraInicio,
    super.fechaHoraFinEstimada,
    required super.estado,
    super.observaciones,
    required super.createdAt,
    required super.updatedAt,
    super.equipos,
  });

  factory PrestamoModel.fromJson(Map<String, dynamic> json) {
    final docente = json['docentes'] as Map<String, dynamic>?;
    final encargado = json['usuarios'] as Map<String, dynamic>?;
    final equiposRaw = json['prestamo_equipos'] as List<dynamic>?;

    return PrestamoModel(
      id: json['id'] as String,
      docenteId: json['docente_id'] as String,
      docenteNombre: (docente?['nombre_completo'] as String?) ?? '',
      encargadoId: json['encargado_id'] as String,
      encargadoNombre: (encargado?['nombre_completo'] as String?) ?? '',
      fechaHoraInicio: DateTime.parse(json['fecha_hora_inicio'] as String),
      fechaHoraFinEstimada: json['fecha_hora_fin_estimada'] != null
          ? DateTime.parse(json['fecha_hora_fin_estimada'] as String)
          : null,
      estado: json['estado'] as String,
      observaciones: json['observaciones'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      equipos: (equiposRaw ?? [])
          .map((e) => _parseEquipo(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static EquipoPrestamoInfo _parseEquipo(Map<String, dynamic> json) {
    final equipo = json['equipos'] as Map<String, dynamic>?;
    return EquipoPrestamoInfo(
      id: json['id'] as String,
      equipoId: json['equipo_id'] as String,
      equipoCodigo: (equipo?['codigo_patrimonial'] as String?) ?? '',
      equipoNombre: _equipoNombre(equipo),
      equipoTipo: (equipo?['tipo'] as String?) ?? '',
      fechaDevolucionReal: json['fecha_devolucion_real'] != null
          ? DateTime.parse(json['fecha_devolucion_real'] as String)
          : null,
      observacionesDevolucion: json['observaciones_devolucion'] as String?,
    );
  }

  static String _equipoNombre(Map<String, dynamic>? equipo) {
    if (equipo == null) return '';
    final marca = equipo['marca'] as String?;
    final modelo = equipo['modelo'] as String?;
    if (marca != null && modelo != null) return '$marca $modelo';
    if (marca != null) return marca;
    if (modelo != null) return modelo;
    return (equipo['codigo_patrimonial'] as String?) ?? '';
  }
}
