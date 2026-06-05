class ActivityItem {
  final String id;
  final String tipo;
  final String descripcion;
  final DateTime fecha;
  final String? prestamoId;

  const ActivityItem({
    required this.id,
    required this.tipo,
    required this.descripcion,
    required this.fecha,
    this.prestamoId,
  });
}
