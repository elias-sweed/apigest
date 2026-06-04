import 'dart:convert';
import '../../domain/entities/docente.dart';

class DocenteModel extends Docente {
  const DocenteModel({
    required super.id,
    required super.nombres,
    required super.apellidos,
    super.grado,
    super.seccion,
    super.turno,
    required super.activo,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DocenteModel.fromJson(Map<String, dynamic> json) {
    final nombreCompleto = json['nombre_completo'] as String? ?? '';
    final parts = nombreCompleto.trim().split(' ');
    final nombres = parts.isNotEmpty ? parts.first : '';
    final apellidos = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    String? grado;
    String? seccion;
    String? turno;
    final depto = json['departamento'] as String?;
    if (depto != null && depto.startsWith('{')) {
      try {
        final meta = jsonDecode(depto) as Map<String, dynamic>;
        grado = meta['grado'] as String?;
        seccion = meta['seccion'] as String?;
        turno = meta['turno'] as String?;
      } catch (_) {}
    }

    return DocenteModel(
      id: json['id'] as String,
      nombres: nombres,
      apellidos: apellidos,
      grado: grado,
      seccion: seccion,
      turno: turno,
      activo: json['activo'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final meta = <String, String>{};
    if (grado != null) meta['grado'] = grado!;
    if (seccion != null) meta['seccion'] = seccion!;
    if (turno != null) meta['turno'] = turno!;

    return {
      'id': id,
      'nombre_completo': '$nombres $apellidos',
      'departamento': meta.isNotEmpty ? jsonEncode(meta) : null,
      'activo': activo,
    };
  }
}
