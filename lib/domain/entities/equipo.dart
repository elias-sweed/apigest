class Equipo {
  final String id;
  final String codigoPatrimonial;
  final String tipo;
  final String? marca;
  final String? modelo;
  final String? numeroSerie;
  final String estado;
  final String? observaciones;
  final String? imagenUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Equipo({
    required this.id,
    required this.codigoPatrimonial,
    required this.tipo,
    this.marca,
    this.modelo,
    this.numeroSerie,
    required this.estado,
    this.observaciones,
    this.imagenUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  String get nombre {
    if (marca != null && modelo != null) return '$marca $modelo';
    if (marca != null) return marca!;
    if (modelo != null) return modelo!;
    return codigoPatrimonial;
  }

  static const Map<String, String> estadoLabels = {
    'disponible': 'Disponible',
    'prestado': 'Prestado',
    'mantenimiento': 'Mantenimiento',
    'dado_de_baja': 'Dado de baja',
  };

  static const Map<String, String> tipoLabels = {
    'laptop_dell': 'Laptop Dell',
    'laptop_hp': 'Laptop HP',
    'cargador': 'Cargador',
    'extension': 'Extensión',
    'otro_accesorio': 'Otro accesorio',
  };

  String get estadoLabel => estadoLabels[estado] ?? estado;
  String get tipoLabel => tipoLabels[tipo] ?? tipo;
}
