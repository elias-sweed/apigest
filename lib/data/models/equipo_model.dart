import '../../domain/entities/equipo.dart';

class EquipoModel extends Equipo {
  const EquipoModel({
    required super.id,
    required super.codigoPatrimonial,
    required super.tipo,
    super.marca,
    super.modelo,
    super.numeroSerie,
    required super.estado,
    super.observaciones,
    super.imagenUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  factory EquipoModel.fromJson(Map<String, dynamic> json) {
    return EquipoModel(
      id: json['id'] as String,
      codigoPatrimonial: json['codigo_patrimonial'] as String,
      tipo: json['tipo'] as String,
      marca: json['marca'] as String?,
      modelo: json['modelo'] as String?,
      numeroSerie: json['numero_serie'] as String?,
      estado: json['estado'] as String,
      observaciones: json['observaciones'] as String?,
      imagenUrl: json['imagen_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo_patrimonial': codigoPatrimonial,
      'tipo': tipo,
      'marca': marca,
      'modelo': modelo,
      'numero_serie': numeroSerie,
      'estado': estado,
      'observaciones': observaciones,
      'imagen_url': imagenUrl,
    };
  }
}
